#!/usr/bin/env bash
#
# epic-scan.sh — run the EPIC compliance gate locally (macOS / Linux).
#
#   Usage:  ./epic-scan.sh <path-to-app>
#   Example: ./epic-scan.sh ~/code/my-app
#
# Downloads the version-pinned epic-compliance binary from GitHub Releases (the
# same tool the EPIC pipeline runs), scans the given source tree, prints a
# summary, and writes a readable report + a SARIF file next to the app.
# Exit code is the gate:  0 = compliant   1 = a HARD control failed   2 = error
#
# Prereqs: the GitHub CLI (`gh`), logged in to the pgetech org
#          (run `gh auth login` once). No AWS access needed.

set -euo pipefail

REPO="pgetech/epic-compliance"
RELEASE="local"   # rolling release of always-latest, unversioned binaries

# --- 1. Validate the one argument --------------------------------------------
APP_PATH="${1:-}"
if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
  echo "Usage: epic-scan <path-to-app>   (a directory to scan)" >&2
  exit 2
fi
APP_PATH="$(cd "$APP_PATH" && pwd)"   # normalize to an absolute path

# --- 2. Pick the right binary for this machine -------------------------------
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)         ASSET="epic-compliance-darwin-arm64" ;;
  Darwin-x86_64)        ASSET="epic-compliance-darwin-amd64" ;;
  Linux-x86_64)         ASSET="epic-compliance-linux-amd64"  ;;
  *) echo "No epic-compliance binary published for $(uname -s)-$(uname -m)." >&2
     exit 2 ;;
esac

command -v gh >/dev/null 2>&1 || {
  echo "GitHub CLI (gh) not found. Install it, then run: gh auth login" >&2
  exit 2; }

# --- 3. Always fetch the latest binary (rolling release, never pinned) -------
BIN="${TMPDIR:-/tmp}/${ASSET}"
echo ">> Fetching latest epic-compliance from GitHub..."
if ! gh release download "$RELEASE" --repo "$REPO" --pattern "$ASSET" --output "$BIN" --clobber; then
  echo "Download failed. Make sure you're logged in: gh auth login" >&2
  exit 2
fi
chmod +x "$BIN"
[ "$(uname -s)" = "Darwin" ] && xattr -d com.apple.quarantine "$BIN" 2>/dev/null || true

# --- 4. Detect appType from the app's EPIC contract (optional) ---------------
APP_TYPE=""
CONTRACT="${APP_PATH}/.pipeline/epic.json"
if [ -f "$CONTRACT" ]; then
  APP_TYPE="$(grep -o '"appType"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONTRACT" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
fi

# --- 5. Scan ------------------------------------------------------------------
echo ">> Scanning ${APP_PATH}${APP_TYPE:+  (appType=$APP_TYPE)}"
echo ">> Reports: ${APP_PATH}/compliance.md  and  ${APP_PATH}/compliance.sarif"
echo

set +e
"$BIN" "$APP_PATH" \
  ${APP_TYPE:+--app-type "$APP_TYPE"} \
  --md    "${APP_PATH}/compliance.md" \
  --sarif "${APP_PATH}/compliance.sarif" \
  --fail-on hard-fail
CODE=$?
set -e

echo
case $CODE in
  0) echo ">> PASS — no gating findings. (details in compliance.md)" ;;
  1) echo ">> FAIL — a HARD control failed. This would block the EPIC pipeline. See compliance.md" ;;
  *) echo ">> ERROR — scan did not complete (exit $CODE)." ;;
esac
exit $CODE
