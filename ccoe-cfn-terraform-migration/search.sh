#!/usr/bin/env bash
set -euo pipefail

ORG="pgetech"
SEARCH="AWSTemplateFormatVersion"
OUTFILE="cfn-repos.txt"
TMPDIR="__scan_tmp"
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

# Load previously found repos so we can skip them and preserve results
declare -A ALREADY_FOUND=()
if [[ -f "$OUTFILE" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && ALREADY_FOUND["$line"]=1
  done < "$OUTFILE"
  log "Loaded ${#ALREADY_FOUND[@]} previously found repos from $OUTFILE"
fi

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
PROGRESS_FILE="$TMPDIR/.scan_progress"
declare -A SCANNED=()

# Load already-found repos as "already scanned"
for repo in "${!ALREADY_FOUND[@]}"; do
  SCANNED["$repo"]=1
done

# Load progress from any prior interrupted run
if [[ -f "$PROGRESS_FILE" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && SCANNED["$line"]=1
  done < "$PROGRESS_FILE"
  log "Resuming — ${#SCANNED[@]} repos already processed"
  echo
fi

###############################################################################
# STEP 3: Clone -> scan -> delete (incremental)
###############################################################################
count=0
found=${#ALREADY_FOUND[@]}
skipped=0

log "Beginning clone-and-scan phase"
echo

while read -r repo; do
  ((count++))

  if [[ -n "${SCANNED[$repo]+x}" ]]; then
    ((skipped++))
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
    ((found++))
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
