#!/usr/bin/env bash
# ===========================================================================
# JFrog Download — PGE ArcGIS Enterprise
# ===========================================================================
# Downloads all files and subfolders from a JFrog Artifactory path into
# a local directory.
#
# Usage:
#   sudo ./fetch-jfrog-artifacts.sh --jfrog-path <path> --local-dir <dir>
#
# Example:
#   sudo ./fetch-jfrog-artifacts.sh --jfrog-path esri/11.5 --local-dir /tmp/esri
# ===========================================================================

set -euo pipefail

# ===========================================================================
# Parse arguments
# ===========================================================================
JFROG_PATH=""
LOCAL_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --jfrog-path) JFROG_PATH="$2"; shift 2 ;;
        --local-dir)  LOCAL_DIR="$2";  shift 2 ;;
        --help|-h)
            echo "Usage: $(basename "$0") --jfrog-path <path> --local-dir <dir>"
            echo "Example: sudo $(basename "$0") --jfrog-path esri/11.5 --local-dir /tmp/esri"
            exit 0 ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Usage: $(basename "$0") --jfrog-path <path> --local-dir <dir>" >&2
            exit 1 ;;
    esac
done

if [[ -z "$JFROG_PATH" ]]; then
    echo "Error: --jfrog-path is required." >&2
    echo "Usage: $(basename "$0") --jfrog-path <path> --local-dir <dir>" >&2
    exit 1
fi

if [[ -z "$LOCAL_DIR" ]]; then
    echo "Error: --local-dir is required." >&2
    echo "Usage: $(basename "$0") --jfrog-path <path> --local-dir <dir>" >&2
    exit 1
fi

# Capture user intent before stripping slashes
if [[ "$JFROG_PATH" == */ ]]; then
    IS_FOLDER=true
else
    IS_FOLDER=false
fi


# Strip trailing slashes
JFROG_PATH="${JFROG_PATH%/}"
LOCAL_DIR="${LOCAL_DIR%/}"

# ===========================================================================
# Configuration
# ===========================================================================
AWS_REGION="us-west-2"
JFROG_PLATFORM_URL="https://jfrog.io.pge.com/"
JFROG_BASE_URL="https://jfrog.io.pge.com/artifactory/"
JFROG_REPO="giscoe-installers-generic-virtual"
JFROG_SERVER_ID="pge-prod"
JFROG_SECRET_NAME="jfrog/token"
JFROG_SECRET_KEY="Token"

JF_THREADS=4
JF_RETRIES=3
JF_RETRY_WAIT=10
JF_SPLIT_COUNT=4

# Disable interactive prompts in jf
export CI=true

# ===========================================================================
# Logging helper
# ===========================================================================
log() {
    local level="$1"; shift
    local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
    case "$level" in
        INFO)  echo "[${ts}] [INFO]  $*" ;;
        OK)    echo "[${ts}] [OK]    $*" ;;
        WARN)  echo "[${ts}] [WARN]  $*" ;;
        ERROR) echo "[${ts}] [ERROR] $*" >&2 ;;
    esac
}


# ===========================================================================
# Step 1 — Check prerequisites
# ===========================================================================
log "INFO" "Checking prerequisites..."

for cmd in aws jq jf; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR" "Required command not found: ${cmd}"
        exit 1
    fi
done

log "OK" "Prerequisites met (aws, jq, jf)."

# ===========================================================================
# Step 2 — Retrieve JFrog token from AWS Secrets Manager
# ===========================================================================
log "INFO" "Retrieving JFrog token from Secrets Manager..."

JFROG_TOKEN=$(
    aws secretsmanager get-secret-value \
        --secret-id "$JFROG_SECRET_NAME" \
        --region "$AWS_REGION" \
        --query 'SecretString' \
        --output text 2>/dev/null \
    | jq -r ".${JFROG_SECRET_KEY} // empty" 2>/dev/null
)

if [[ -z "$JFROG_TOKEN" ]]; then
    log "ERROR" "Failed to retrieve JFrog token from secret: ${JFROG_SECRET_NAME}"
    exit 1
fi

log "OK" "Token retrieved."

# ===========================================================================
# Step 3 — Configure JFrog CLI
# ===========================================================================
log "INFO" "Configuring JFrog CLI..."

jf config remove "$JFROG_SERVER_ID" --quiet 2>/dev/null || true

jf config add "$JFROG_SERVER_ID" \
    --url="$JFROG_PLATFORM_URL" \
    --artifactory-url="$JFROG_BASE_URL" \
    --access-token="$JFROG_TOKEN" \
    --interactive=false \
    --overwrite=true 2>/dev/null

jf config use "$JFROG_SERVER_ID" 2>/dev/null

log "OK" "JFrog CLI configured (server: ${JFROG_SERVER_ID})."

# ===========================================================================
# Step 4 — Ping JFrog
# ===========================================================================
log "INFO" "Testing connectivity..."

if ! jf rt ping --server-id="$JFROG_SERVER_ID" &>/dev/null; then
    log "ERROR" "Cannot reach JFrog at ${JFROG_BASE_URL}"
    exit 1
fi

log "OK" "JFrog Artifactory is reachable."

# ===========================================================================
# Step 5 — Create local directory
# ===========================================================================
mkdir -p "$LOCAL_DIR"

# ===========================================================================
# Step 6 — Download
# ===========================================================================
log "INFO" "Downloading ${JFROG_REPO}/${JFROG_PATH}/ -> ${LOCAL_DIR}/"
log "INFO" "  Threads: ${JF_THREADS} | Retries: ${JF_RETRIES} | Split: ${JF_SPLIT_COUNT}"

# Determine source pattern and flattening
if [ "$IS_FOLDER" = true ]; then
    # Folder mode: ensure trailing slash to target all contents
    SOURCE_PATTERN="${JFROG_REPO}/${JFROG_PATH}/"
    FLAT_MODE="false"
    log "INFO" "Mode: FOLDER download"
else
    # Single file mode: target specific artifact
    SOURCE_PATTERN="${JFROG_REPO}/${JFROG_PATH}"
    FLAT_MODE="true"
    log "INFO" "Mode: SINGLE FILE download"
fi

START_TIME=$(date +%s)

if jf rt download "$SOURCE_PATTERN" "${LOCAL_DIR}/" \
    --server-id="$JFROG_SERVER_ID" \
    --flat="$FLAT_MODE" \
    --threads="$JF_THREADS" \
    --retries="$JF_RETRIES" \
    --detailed-summary; then
    DOWNLOAD_OK=true
else
    DOWNLOAD_OK=false
fi

END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))

# ===========================================================================
# Step 7 — Summary
# ===========================================================================
echo ""
log "INFO" "========================================="
log "INFO" "  Source      : ${JFROG_REPO}/${JFROG_PATH}/"
log "INFO" "  Destination : ${LOCAL_DIR}/"
log "INFO" "  Duration    : $(( ELAPSED / 60 ))m $(( ELAPSED % 60 ))s"

if [[ "$DOWNLOAD_OK" == true ]]; then
    log "OK" "  Status      : SUCCESS"
    log "OK" "Download complete. Files saved to ${LOCAL_DIR}/"
else
    log "ERROR" "  Status      : FAILED"
    log "ERROR" "Download completed with errors. Check output above."
    exit 1
fi
