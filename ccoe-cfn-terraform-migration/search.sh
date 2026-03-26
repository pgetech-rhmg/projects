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
mkdir -p "$TMPDIR"
> "$OUTFILE"

###############################################################################
# STEP 1: Fetch repo list
###############################################################################
log "Starting CloudFormation repo scan"
log "Org: $ORG"
log "Search string: $SEARCH"
echo

log "Fetching non-archived repositories..."

gh repo list "$ORG" --limit 10000 --json name,isArchived \
  -q '.[] | select(.isArchived == false) | .name' > "$REPO_LIST"

TOTAL=$(wc -l < "$REPO_LIST" | tr -d ' ')
log "Found $TOTAL active repositories"
echo

###############################################################################
# STEP 2: Clone -> scan -> delete
###############################################################################
count=0
found=0

log "Beginning clone-and-scan phase"
echo

while read -r repo; do
  ((count++))
  log "[$count/$TOTAL] Scanning repo: $repo"

  workdir="$TMPDIR/$repo"

  if ! git clone --depth=1 "https://github.com/$ORG/$repo.git" "$workdir" \
       >/dev/null 2>&1; then
    log "  Clone failed — skipping"
    continue
  fi

  if rg "$SEARCH" "$workdir" >/dev/null; then
    ((found++))
    log "  FOUND CloudFormation usage"
    echo "$repo" >> "$OUTFILE"
  else
    log "  Not found"
  fi

  rm -rf "$workdir"

done < "$REPO_LIST"

###############################################################################
# CLEANUP
###############################################################################
rm -rf "$TMPDIR"

echo
log "Scan complete"
log "Repositories scanned: $TOTAL"
log "Repositories with CloudFormation: $found"
log "Results written to: $OUTFILE"

