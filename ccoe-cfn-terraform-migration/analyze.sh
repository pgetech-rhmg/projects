#!/usr/bin/env bash
set -euo pipefail

ORG="pgetech"
INPUT_FILE="cfn-repos.txt"
OUTFILE="cfn-repo-analysis.csv"
COMPLEXITY_FILE="cfn-migration-complexity.csv"
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
# MIGRATION COMPLEXITY EXTRACTION
###############################################################################
extract_complexity() {
  local files=("$@")

  # Total resource declarations (Type: AWS:: in YAML, "Type": "AWS:: in JSON)
  local total_resources
  total_resources=$(grep -RohE \
    '(Type:\s+AWS::[A-Za-z0-9:]+|"Type"\s*:\s*"AWS::[A-Za-z0-9:]+)' \
    "${files[@]}" 2>/dev/null | wc -l | tr -d ' ')

  # Unique resource types — pipe-delimited list
  local resource_types
  resource_types=$(grep -RohE \
    'AWS::[A-Za-z0-9]+::[A-Za-z0-9]+' \
    "${files[@]}" 2>/dev/null | sort -u | paste -sd '|' -)
  [[ -z "$resource_types" ]] && resource_types="none"

  # Nested stacks
  local nested_stacks
  nested_stacks=$(grep -Rc 'AWS::CloudFormation::Stack' \
    "${files[@]}" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')

  # Cross-stack references (Fn::ImportValue or !ImportValue)
  local cross_stack_refs
  cross_stack_refs=$(grep -RocE \
    '(Fn::ImportValue|!ImportValue)' \
    "${files[@]}" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')

  # Custom resources
  local custom_resources
  custom_resources=$(grep -RocE \
    '(AWS::CloudFormation::CustomResource|Custom::)' \
    "${files[@]}" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')

  # SAM transforms
  local sam_transforms="false"
  if grep -RqE '(AWS::Serverless::|Transform.*AWS::Serverless)' \
       "${files[@]}" 2>/dev/null; then
    sam_transforms="true"
  fi

  # Parameters count (top-level Parameters: sections)
  local parameters
  parameters=$(grep -Rc '^Parameters:' \
    "${files[@]}" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')

  # Conditions (Fn::If, Condition:, Conditions: section)
  local conditions
  conditions=$(grep -RocE \
    '(Fn::If|!If|^Conditions:)' \
    "${files[@]}" 2>/dev/null | awk -F: '{s+=$NF} END {print s+0}')

  # Total CFN lines across all template files
  local cfn_lines
  cfn_lines=$(cat "${files[@]}" 2>/dev/null | wc -l | tr -d ' ')

  echo "${total_resources},${resource_types},${nested_stacks},${cross_stack_refs},${custom_resources},${sam_transforms},${parameters},${conditions},${cfn_lines}"
}

###############################################################################
# CSV Headers — only write if file doesn't exist or is empty
###############################################################################
ANALYSIS_HEADER="repo_name,created_at,last_pushed_at,default_branch,cfn_file_count,platform_pct,application_pct,data_pct,other_pct"
COMPLEXITY_HEADER="repo_name,total_resources,resource_types,nested_stacks,cross_stack_refs,custom_resources,sam_transforms,parameters,conditions,has_terraform,cfn_lines"

if [[ ! -s "$OUTFILE" ]]; then
  echo "$ANALYSIS_HEADER" > "$OUTFILE"
fi

if [[ ! -s "$COMPLEXITY_FILE" ]]; then
  echo "$COMPLEXITY_HEADER" > "$COMPLEXITY_FILE"
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

  # Skip if repo already has a row in both CSVs
  if grep -qm1 "^${repo}," "$OUTFILE" 2>/dev/null && \
     grep -qm1 "^${repo}," "$COMPLEXITY_FILE" 2>/dev/null; then
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
      --include "*.json" \
      --include "*.template" \
      --exclude-dir "node_modules" \
      --exclude-dir "vendor" \
      --exclude-dir ".terraform" || true
  )

  cfn_count="${#cfn_files[@]}"

  #############################################################################
  # Check for existing Terraform in the repo
  #############################################################################
  has_terraform="false"
  if find "$workdir" -name "*.tf" -not -path "*/.terraform/*" -not -path "*/node_modules/*" \
       -print -quit 2>/dev/null | grep -q .; then
    has_terraform="true"
  fi

  #############################################################################
  # Write results
  #############################################################################
  if [[ "$cfn_count" -eq 0 ]]; then
    log "  No CloudFormation templates found"

    if ! grep -qm1 "^${repo}," "$OUTFILE" 2>/dev/null; then
      echo "$repo,$created_at,$pushed_at,$default_branch,0,0,0,0,100" >> "$OUTFILE"
    fi
    if ! grep -qm1 "^${repo}," "$COMPLEXITY_FILE" 2>/dev/null; then
      echo "$repo,0,none,0,0,0,false,0,0,$has_terraform,0" >> "$COMPLEXITY_FILE"
    fi

    rm -rf "$workdir"
    continue
  fi

  log "  CFN files: $cfn_count"

  # Category analysis
  if ! grep -qm1 "^${repo}," "$OUTFILE" 2>/dev/null; then
    IFS=',' read platform_pct application_pct data_pct other_pct \
      <<< "$(detect_category_percentages "${cfn_files[@]}")"

    echo "$repo,$created_at,$pushed_at,$default_branch,$cfn_count,$platform_pct,$application_pct,$data_pct,$other_pct" >> "$OUTFILE"
  fi

  # Migration complexity
  if ! grep -qm1 "^${repo}," "$COMPLEXITY_FILE" 2>/dev/null; then
    complexity=$(extract_complexity "${cfn_files[@]}")
    echo "$repo,$complexity,$has_terraform" >> "$COMPLEXITY_FILE"

    # Log key signals
    IFS=',' read total_resources resource_types nested cross custom sam params conds cfn_lines <<< "$complexity"
    log "  Resources: $total_resources | Nested stacks: $nested | Cross-stack refs: $cross | Custom: $custom | SAM: $sam | Terraform exists: $has_terraform"
  fi

  rm -rf "$workdir"

done < "$INPUT_FILE"

echo
log "Analysis complete"
log "Repos skipped (already analyzed): $skipped"
log "Analysis CSV: $OUTFILE"
log "Complexity CSV: $COMPLEXITY_FILE"
