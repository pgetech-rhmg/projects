#!/bin/bash
set -eu pipefail

# Constants
LAMBDA_DIR="lambdas"
TF_DIR="tf"

# Global variables
unique_pipelines=() # Array to store unique pipeline names
TF_CHANGED=false    # Flag to indicate if Terraform files have changed

# Logging functions
function log_info {
  echo "[INFO] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

# Check if a pipeline is unique
is_pipeline_unique() {
  local pipeline="$1"
  for existing_pipeline in "${unique_pipelines[@]}"; do
    if [[ "$existing_pipeline" == "$pipeline" ]]; then
      return 1 # Not unique
    fi
  done
  return 0 # Unique
}

# Add a unique pipeline
add_unique_pipeline() {
  local pipeline="$1"
  if is_pipeline_unique "$pipeline"; then
    unique_pipelines+=("$pipeline")
  fi
}

# Determine changed files
determine_changed_files() {
  if git rev-parse HEAD^ >/dev/null 2>&1; then
    log_info "Determining file changes from previous commit"
    local changed_files
    changed_files=$(git diff --name-only HEAD^ HEAD)
    log_info "CHANGED FILES:"
    log_info "$changed_files"
    process_changed_files "$changed_files"
  else
    handle_initial_commit
  fi
}

# Process changed files
process_changed_files() {
  local changed_files="$1"
  while IFS= read -r file; do
    if [[ "$file" =~ ^(${LAMBDA_DIR}|apps)/([^/]+)/ ]]; then
      add_unique_pipeline "${BASH_REMATCH[2]}"
    elif [[ "$file" == ${TF_DIR}/* ]]; then
      TF_CHANGED=true
    fi
  done <<<"$changed_files"
}

# Handle the initial commit case
handle_initial_commit() {
  log_info "No previous commits found, likely due to initial commit only."
  if [ -d "$LAMBDA_DIR" ]; then
    for d in "$LAMBDA_DIR"/*; do
      if [ -d "$d" ]; then
        unique_pipelines+=("$(basename "$d")")
      fi
    done
  fi
  if [ -d "$TF_DIR" ]; then
    TF_CHANGED=true
  fi
}

# Print pipelines
print_pipelines() {
  if [[ ${#unique_pipelines[@]} -eq 0 ]]; then
    log_info "No pipelines found. Exiting early."
    exit 0
  fi
  log_info "Lambdas found for pipelines:"
  for p in "${unique_pipelines[@]}"; do
    echo "$p"
  done
}

# Get the Terraform workspace name
get_terraform_workspace() {
  local repo_url
  if [[ -n "${CODEBUILD_SOURCE_REPO_URL:-}" ]]; then
    TFC_WS="$(basename -s .git "$CODEBUILD_SOURCE_REPO_URL")-$ENV"
  else
    repo_url=$(git config --get remote.origin.url)
    TFC_WS="$(basename -s .git "$repo_url")-$ENV"
  fi
  log_info "Terraform Workspace: $TFC_WS"
  log_info "Fetching workspace ID..."
  WORKSPACE_ID=$(curl -f \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/organizations/pgetech/workspaces/$TFC_WS" |
    jq -r '.data.id')
  log_info "Workspace ID: $WORKSPACE_ID"
}

# Wait for Terraform run completion
wait_for_terraform_run() {
  log_info "Waiting for Terraform run to complete..."
  local run_id
  run_id=$(curl \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/runs" |
    jq -r '.data[0].id')

  if [[ "$run_id" == "null" ]]; then
    log_info "No TFC run exists for this commit. Continuing with pipeline."
    return
  fi

  while true; do
    local run_status
    run_status=$(curl -f \
      --header "Authorization: Bearer $TFC_TOKEN" \
      --header "Content-Type: application/vnd.api+json" \
      "https://app.terraform.io/api/v2/runs/$run_id" |
      jq -r '.data.attributes.status')

    log_info "Status: $run_status"
    case "$run_status" in
    applied)
      log_info "Apply complete!"
      return
      ;;
    planned_and_finished)
      log_info "No changes."
      return
      ;;
    errored | discarded | canceled | force_canceled | policy_soft_failed)
      log_error "Run exited with error."
      exit 1
      ;;
    esac
    sleep 5
  done
}

# Start AWS CodePipeline execution for each unique pipeline
start_pipelines() {
  for pipeline in "${unique_pipelines[@]}"; do
    log_info "Starting execution for pipeline: $pipeline-pipeline"
    aws codepipeline start-pipeline-execution --name "$pipeline-pipeline"
  done
}

# Main function
main() {
  log_info "Finding files changed in latest push..."
  determine_changed_files
  print_pipelines

  if [[ "$TF_CHANGED" == "true" ]]; then
    log_info "Changes in '${TF_DIR}/' detected."
    get_terraform_workspace
    wait_for_terraform_run
  fi

  start_pipelines
}

# Run the main function
main
