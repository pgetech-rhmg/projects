#!/usr/bin/env bash
###############################################################################
# Local dry-run of the epic-pipeline GitHub App token mint (common/gh-app-token.yml).
# Proves the App ID + private key resolve an installation and mint a token before
# the YAML is pushed. Uses the SAME JWT + exchange logic as the pipeline.
#
# Usage:
#   GITHUB_APP_ID=123456 ./gh-app-token-test.sh <path-to-app-key.pem> [owner] [repo]
#
# Example:
#   GITHUB_APP_ID=123456 ./gh-app-token-test.sh ~/epic-app.pem pgetech epic-web
###############################################################################
set -euo pipefail

PEM_PATH="${1:?path to App private-key .pem required}"
OWNER="${2:-pgetech}"
REPO="${3:-}"
HOST="github.com"
: "${GITHUB_APP_ID:?set GITHUB_APP_ID (numeric App ID, not the client id)}"

if [[ "$HOST" == "github.com" ]]; then API_BASE="https://api.github.com"; else API_BASE="https://${HOST}/api/v3"; fi

b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

NOW=$(date +%s)
HEADER=$(printf '%s' '{"alg":"RS256","typ":"JWT"}' | b64url)
PAYLOAD=$(printf '{"iat":%s,"exp":%s,"iss":"%s"}' "$((NOW-60))" "$((NOW+540))" "$GITHUB_APP_ID" | b64url)
SIG=$(printf '%s' "${HEADER}.${PAYLOAD}" | openssl dgst -sha256 -sign "$PEM_PATH" -binary | b64url)
JWT="${HEADER}.${PAYLOAD}.${SIG}"

if [[ -n "$REPO" ]]; then INST_URL="${API_BASE}/repos/${OWNER}/${REPO}/installation"; else INST_URL="${API_BASE}/orgs/${OWNER}/installation"; fi
echo ">> Resolving installation: $INST_URL"
INST_ID=$(curl -sS -H "Authorization: Bearer ${JWT}" -H "Accept: application/vnd.github+json" "$INST_URL" | jq -r '.id // empty')
[[ -z "$INST_ID" ]] && { echo "!! No installation found (app not installed on ${OWNER}, or JWT rejected). Check App ID / key / install."; exit 1; }
echo ">> Installation id: $INST_ID"

TOKEN=$(curl -sS -X POST -H "Authorization: Bearer ${JWT}" -H "Accept: application/vnd.github+json" \
  "${API_BASE}/app/installations/${INST_ID}/access_tokens" | jq -r '.token // empty')
[[ -z "$TOKEN" ]] && { echo "!! Token exchange failed."; exit 1; }
echo ">> Minted installation token: ${TOKEN:0:8}… (len ${#TOKEN})"
echo ">> SUCCESS — the App can mint tokens for ${OWNER}${REPO:+/$REPO}"
