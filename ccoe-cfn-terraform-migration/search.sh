#!/usr/bin/env bash
set -euo pipefail

ORG="pgetech"
SEARCH="AWSTemplateFormatVersion"
OUTFILE="cfn-repos.txt"
TMPDIR="__scan_tmp"
PROGRESS_FILE="__scan_progress.txt"
REPO_LIST="repos.txt"

###############################################################################
# LOGGING
###############################################################################
log() {
  echo ">> $*"
}

###############################################################################
# PREP
###############################################################################
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR"

# Ensure output file exists for grep lookups
touch "$OUTFILE"
ALREADY_FOUND=$(wc -l < "$OUTFILE" | tr -d ' ')
log "Loaded $ALREADY_FOUND previously found repos from $OUTFILE"

###############################################################################
# STEP 1: Fetch repo list (or reuse existing)
###############################################################################
log "Starting CloudFormation repo scan"
log "Org: $ORG"
log "Search string: $SEARCH"
echo

if [[ -s "$REPO_LIST" ]]; then
  log "Reusing existing repo list: $REPO_LIST"
else
  log "Fetching non-archived repositories..."
  gh repo list "$ORG" --limit 10000 --json name,isArchived \
    -q '.[] | select(.isArchived == false) | .name' > "$REPO_LIST"
fi

TOTAL=$(wc -l < "$REPO_LIST" | tr -d ' ')
log "Found $TOTAL active repositories"
echo

###############################################################################
# STEP 2: Load scan progress for resume support
###############################################################################
touch "$PROGRESS_FILE"

if [[ -s "$PROGRESS_FILE" ]]; then
  log "Resuming — $(wc -l < "$PROGRESS_FILE" | tr -d ' ') repos already processed"
  echo
fi

###############################################################################
# STEP 3: Clone -> scan -> delete (incremental)
###############################################################################
count=0
found=$ALREADY_FOUND
skipped=0

log "Beginning clone-and-scan phase"
echo

while read -r repo; do
  count=$((count + 1))

  # Skip if already in output file or progress file
  if grep -qxF "$repo" "$OUTFILE" "$PROGRESS_FILE" 2>/dev/null; then
    skipped=$((skipped + 1))
    continue
  fi

  log "[$count/$TOTAL] Scanning repo: $repo"

  workdir="$TMPDIR/$repo"

  if ! git clone --depth=1 "https://github.com/$ORG/$repo.git" "$workdir" \
       >/dev/null 2>&1; then
    log "  Clone failed — skipping"
    echo "$repo" >> "$PROGRESS_FILE"
    continue
  fi

  if rg "$SEARCH" "$workdir" >/dev/null 2>&1; then
    found=$((found + 1))
    log "  FOUND CloudFormation usage"
    echo "$repo" >> "$OUTFILE"
  else
    log "  Not found"
  fi

  rm -rf "$workdir"

  # Record progress so we can resume if interrupted
  echo "$repo" >> "$PROGRESS_FILE"

done < "$REPO_LIST"

echo
log "Scan complete"
log "Repositories scanned: $TOTAL"
log "Repositories skipped (already processed): $skipped"
log "Repositories with CloudFormation: $found"
log "Results written to: $OUTFILE"
