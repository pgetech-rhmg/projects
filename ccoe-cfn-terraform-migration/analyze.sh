#!/usr/bin/env bash
set -euo pipefail

ORG="pgetech"
INPUT_FILE="cfn-repos.txt"
OUTFILE="cfn-repo-analysis.csv"
TMPDIR="__repo_scan_tmp"

trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR"

###############################################################################
# LOGGING
###############################################################################
log() {
  echo ">> $*"
}

###############################################################################
# FORMATTING
###############################################################################
format_date() {
  local iso="$1"

  if [[ -z "$iso" || "$iso" == "null" ]]; then
    echo
    return
  fi

  date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso" "+%m/%d/%Y %H:%M"
}

###############################################################################
# CATEGORY DETECTION
###############################################################################
detect_category_percentages() {
  local files=("$@")

  local platform=0
  local application=0
  local data=0

  # ---- STRONG SIGNALS (weight = 4) ----

  platform=$((platform + 4 * $(grep -RohE \
    "AWS::CodePipeline|AWS::CodeBuild|AWS::CodeDeploy|AWS::CloudFormation::StackSet" \
    "${files[@]}" 2>/dev/null | wc -l | tr -d ' ')))

  application=$((application + 4 * $(grep -RohE \
    "AWS::ECS|AWS::EKS|AWS::Lambda|AWS::ElasticLoadBalancing|AWS::ApiGateway" \
    "${files[@]}" 2>/dev/null | wc -l | tr -d ' ')))

  data=$((data + 4 * $(grep -RohE \
    "AWS::RDS|AWS::DynamoDB|AWS::Glue|AWS::Redshift|AWS::Kinesis|AWS::Athena" \
    "${files[@]}" 2>/dev/null | wc -l | tr -d ' ')))

  # ---- SUPPORTING SIGNALS (weight = 1) ----

  platform=$((platform + $(grep -RohE \
    "AWS::IAM|AWS::SSM|AWS::Logs" \
    "${files[@]}" 2>/dev/null | wc -l | tr -d ' ')))

  # S3 is ambiguous — count lightly
  platform=$((platform + $(grep -RohE \
    "AWS::S3::Bucket" \
    "${files[@]}" 2>/dev/null | wc -l | tr -d ' ') / 2))

  local total=$((platform + application + data))

  if [[ "$total" -eq 0 ]]; then
    echo "0,0,0,0"
    return
  fi

  local platform_pct=$((platform * 100 / total))
  local application_pct=$((application * 100 / total))
  local data_pct=$((data * 100 / total))

  local other_pct=$((100 - platform_pct - application_pct - data_pct))
  if (( other_pct < 0 )); then other_pct=0; fi

  echo "$platform_pct,$application_pct,$data_pct,$other_pct"
}

###############################################################################
# CSV Header — only write if file doesn't exist or is empty
###############################################################################
CSV_HEADER="repo_name,created_at,last_pushed_at,default_branch,cfn_file_count,platform_pct,application_pct,data_pct,other_pct"

if [[ ! -s "$OUTFILE" ]]; then
  echo "$CSV_HEADER" > "$OUTFILE"
fi

TOTAL=$(wc -l < "$INPUT_FILE" | tr -d ' ')
count=0
skipped=0

# Count already-analyzed repos (CSV lines minus header)
already=0
if [[ -s "$OUTFILE" ]]; then
  already=$(( $(wc -l < "$OUTFILE" | tr -d ' ') - 1 ))
  if (( already < 0 )); then already=0; fi
fi

log "Starting CloudFormation repo analysis"
log "Repos: $TOTAL"
log "Already analyzed: $already"
echo

while read -r repo; do
  count=$((count + 1))

  # Skip if repo already has a row in the CSV
  if grep -qm1 "^${repo}," "$OUTFILE" 2>/dev/null; then
    skipped=$((skipped + 1))
    continue
  fi

  log "[$count/$TOTAL] Processing $repo"

  repo_json=$(gh api "repos/$ORG/$repo" 2>/dev/null || true)
  [[ -z "$repo_json" ]] && log "  Unable to fetch metadata — skipping" && continue

  created_at=$(format_date "$(echo "$repo_json" | jq -r '.created_at')")
  pushed_at=$(format_date "$(echo "$repo_json" | jq -r '.pushed_at')")
  default_branch=$(echo "$repo_json" | jq -r '.default_branch')

  workdir="$TMPDIR/$repo"
  rm -rf "$workdir"

  log "  Cloning default branch: $default_branch"

  git clone --depth=1 --branch "$default_branch" \
    "https://github.com/$ORG/$repo.git" "$workdir" >/dev/null 2>&1 || {
      log "  Clone failed — skipping"
      continue
    }

  #############################################################################
  # Find CloudFormation templates (YAML + JSON)
  #############################################################################
  cfn_files=()

  while IFS= read -r file; do
    cfn_files+=("$file")
  done < <(
    grep -RIl "AWSTemplateFormatVersion" "$workdir" \
      --include "*.yml" \
      --include "*.yaml" \
      --include "*.json" || true
  )

  cfn_count="${#cfn_files[@]}"

  if [[ "$cfn_count" -eq 0 ]]; then
    log "  No CloudFormation templates found"
    echo "$repo,$created_at,$pushed_at,$default_branch,0,0,0,0,100" >> "$OUTFILE"
    rm -rf "$workdir"
    continue
  fi

  IFS=',' read platform_pct application_pct data_pct other_pct \
    <<< "$(detect_category_percentages "${cfn_files[@]}")"

  log "  CFN files: $cfn_count"

  echo "$repo,$created_at,$pushed_at,$default_branch,$cfn_count,$platform_pct,$application_pct,$data_pct,$other_pct" >> "$OUTFILE"

  rm -rf "$workdir"

done < "$INPUT_FILE"

echo
log "Analysis complete"
log "Repos skipped (already analyzed): $skipped"
log "CSV written to: $OUTFILE"
