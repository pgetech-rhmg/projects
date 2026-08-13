#!/usr/bin/env bash
#
# install.sh — add the `epic-scan` command to your shell profile (macOS / Linux).
#
# Run once:
#   gh api repos/pgetech/epic-compliance/contents/scripts/install.sh \
#     -H "Accept: application/vnd.github.raw" | bash
#
# Idempotent: re-running replaces the existing block instead of duplicating it.

set -euo pipefail

# Pick the profile file for the current shell.
case "$(basename "${SHELL:-bash}")" in
  zsh)  PROFILE="${ZDOTDIR:-$HOME}/.zshrc" ;;
  bash) PROFILE="$HOME/.bashrc" ;;
  *)    PROFILE="$HOME/.profile" ;;
esac

START="# >>> epic-scan >>>"
END="# <<< epic-scan <<<"

BLOCK="$START
# EPIC compliance gate — local shift-left runner (self-updating).
epic-scan() {
  gh api repos/pgetech/epic-compliance/contents/scripts/epic-scan.sh \\
    -H \"Accept: application/vnd.github.raw\" | bash -s -- \"\$@\"
}
$END"

touch "$PROFILE"

# Remove any prior block so re-running just refreshes it.
if grep -qF "$START" "$PROFILE"; then
  tmp="$(mktemp)"
  sed "/$START/,/$END/d" "$PROFILE" > "$tmp" && mv "$tmp" "$PROFILE"
fi

printf '\n%s\n' "$BLOCK" >> "$PROFILE"

echo "Installed 'epic-scan' into $PROFILE"
echo "Start a new terminal (or run: source \"$PROFILE\"), then:  epic-scan /path/to/your/app"
