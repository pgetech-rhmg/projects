#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# CONFIG
###############################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="$(command -v python3.11 || command -v python3)"

ORG="pgetech"
CSV_FILE="cfn-repo-analysis.csv"

AWS_REGION="us-east-2"
AGENT_ID="U9QDABQJQM"
AGENT_ALIAS_ID="FVBEN4YT6P"

# ---- AWS PROFILE ----
AWS_PROFILE_DEFAULT="pge-sso"
: "${AWS_PROFILE:=$AWS_PROFILE_DEFAULT}"
export AWS_PROFILE

WORKDIR="$SCRIPT_DIR/__cfn_agent_tmp"
RESULTSDIR="$SCRIPT_DIR/results"

# ---- SIZE CONTROL ----
MAX_FILES_SINGLE=25
MAX_FILES_CHUNK=15
MAX_PAYLOAD_BYTES=180000

###############################################################################
# LOGGING
###############################################################################
log() {
  echo ">> $*"
}

###############################################################################
# AWS CREDENTIAL PRE-FLIGHT CHECK
###############################################################################
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo
  echo "!! ERROR: AWS credentials are not valid for profile '$AWS_PROFILE'"
  echo "!! Run: aws sso login --profile $AWS_PROFILE"
  echo
  exit 1
fi

log "Using AWS profile: $AWS_PROFILE"
echo

###############################################################################
# CLEANUP
###############################################################################
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

###############################################################################
# PREP
###############################################################################
mkdir -p "$RESULTSDIR"

###############################################################################
# MAIN LOOP — CSV DRIVEN
###############################################################################
tail -n +2 "$CSV_FILE" | while IFS=',' read -r repo _ _ branch file_count _; do

  ###########################################################################
  # VALIDATION & SKIPS
  ###########################################################################
  if [[ "$repo" == aws-* || "$repo" == ccsp-* || "$repo" == pge-ecm-* ]]; then
    log "Skipping $repo (excluded prefix)"
    continue
  fi

  if [[ -z "$repo" || -z "$branch" ]]; then
    log "Skipping invalid row"
    continue
  fi

  if [[ "${file_count:-0}" -eq 0 ]]; then
    log "Skipping $repo — no CFN files"
    continue
  fi

  RESULT_FILE="$RESULTSDIR/${repo}_agent_results.md"

  if [[ -s "$RESULT_FILE" ]]; then
    log "Skipping $repo — assessment already exists"
    continue
  fi

  echo
  echo "-----------------------------------------------------------------------"
  log "Processing $repo (branch: $branch, files: $file_count)"

  ###########################################################################
  # PATHS
  ###########################################################################
  rm -rf "$WORKDIR"
  mkdir -p "$WORKDIR"
  REPODIR="$WORKDIR/repo"

  ###########################################################################
  # STEP 1 — CLONE
  ###########################################################################
  log "Cloning repository..."

  git clone \
    --depth=1 \
    --branch="$branch" \
    "https://github.com/${ORG}/${repo}.git" \
    "$REPODIR" >/dev/null 2>&1

  ###########################################################################
  # STEP 2 — DISCOVER CFN FILES (in a subshell to avoid cd side effects)
  ###########################################################################
  log "Discovering CloudFormation files..."

  CFN_FILES=()
  while IFS= read -r file; do
    [[ -n "$file" ]] && CFN_FILES+=("$file")
  done < <(
    cd "$REPODIR" && \
    find . -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.template" \) \
      -not -path "*/node_modules/*" \
      -not -path "*/.terraform/*" \
      -not -path "*/vendor/*" \
      -print0 | \
    xargs -0 grep -lE '(^|\s)AWSTemplateFormatVersion\s*:|"AWSTemplateFormatVersion"\s*:' 2>/dev/null || true
  )

  TOTAL_FILES="${#CFN_FILES[@]}"
  if (( TOTAL_FILES == 0 )); then
    log "No CFN files found — skipping $repo"
    continue
  fi

  log "Found $TOTAL_FILES CloudFormation files"

  ###########################################################################
  # STEP 3 — CHUNK DECISION
  ###########################################################################
  if (( TOTAL_FILES <= MAX_FILES_SINGLE )); then
    FILES_PER_CHUNK="$TOTAL_FILES"
    CHUNKS=1
  else
    FILES_PER_CHUNK="$MAX_FILES_CHUNK"
    CHUNKS=$(( (TOTAL_FILES + FILES_PER_CHUNK - 1) / FILES_PER_CHUNK ))
  fi

  log "Using $CHUNKS chunk(s)"

  ###########################################################################
  # CHUNK BUILDER
  ###########################################################################
  build_chunk() {
    local start="$1"
    local end="$2"
    local outfile="$3"

    rm -f "$outfile"

    for ((i=start; i<end; i++)); do
      local file="${CFN_FILES[$i]}"
      printf "===== FILE: %s =====\n\n" "${file#./}" >> "$outfile"
      sed 's/\t/  /g' "$REPODIR/$file" >> "$outfile"
      printf "\n\n===== END FILE =====\n\n" >> "$outfile"
    done
  }

  ###########################################################################
  # STEP 4 — PER-CHUNK ANALYSIS
  ###########################################################################
  CHUNK_RESULTS=()

  for ((c=0; c<CHUNKS; c++)); do
    START=$(( c * FILES_PER_CHUNK ))
    END=$(( START + FILES_PER_CHUNK ))
    (( END > TOTAL_FILES )) && END="$TOTAL_FILES"

    INPUT_TXT="$WORKDIR/cfn_chunk_${c}.txt"
    RESULT_CHUNK="$WORKDIR/result_chunk_${c}.md"

    build_chunk "$START" "$END" "$INPUT_TXT"

    BYTES=$(wc -c < "$INPUT_TXT" | tr -d ' ')
    log "Chunk $((c+1)) of $CHUNKS ... size: $BYTES bytes"

    if (( BYTES > MAX_PAYLOAD_BYTES )); then
      log "Trimming chunk $((c+1)) to $MAX_PAYLOAD_BYTES bytes"
      head -c "$MAX_PAYLOAD_BYTES" "$INPUT_TXT" > "${INPUT_TXT}.trimmed"
      mv "${INPUT_TXT}.trimmed" "$INPUT_TXT"
    fi

    #########################################################################
    # AGENT INVOCATION — CHUNK
    #########################################################################
    "$PYTHON_BIN" "$SCRIPT_DIR/invoke_agent.py" \
      --agent-id "$AGENT_ID" \
      --agent-alias-id "$AGENT_ALIAS_ID" \
      --region "$AWS_REGION" \
      --repo "$repo" \
      --input-file "$INPUT_TXT" \
      --output-file "$RESULT_CHUNK" \
      --mode chunk \
      --chunk-num "$((c + 1))" \
      --total-chunks "$CHUNKS"

    CHUNK_RESULTS+=("$RESULT_CHUNK")
    log "Completed chunk $((c+1))"
  done

  ###########################################################################
  # STEP 5 — FINAL CONSOLIDATION
  ###########################################################################
  if (( CHUNKS == 1 )); then
    cp "${CHUNK_RESULTS[0]}" "$RESULT_FILE"
  else
    echo
    log "Running consolidation analysis..."

    CONSOLIDATION_INPUT="$WORKDIR/consolidation.txt"
    rm -f "$CONSOLIDATION_INPUT"

    for f in "${CHUNK_RESULTS[@]}"; do
      cat "$f" >> "$CONSOLIDATION_INPUT"
      printf "\n\n---\n\n" >> "$CONSOLIDATION_INPUT"
    done

    "$PYTHON_BIN" "$SCRIPT_DIR/invoke_agent.py" \
      --agent-id "$AGENT_ID" \
      --agent-alias-id "$AGENT_ALIAS_ID" \
      --region "$AWS_REGION" \
      --repo "$repo" \
      --input-file "$CONSOLIDATION_INPUT" \
      --output-file "$RESULT_FILE" \
      --mode consolidate
  fi

  log "Completed analysis for $repo"
  echo "-----------------------------------------------------------------------"
  echo

done

###############################################################################
# DONE
###############################################################################
echo
log "All repository analyses complete"
log "Results directory: $RESULTSDIR"
