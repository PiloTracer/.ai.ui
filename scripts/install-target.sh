#!/usr/bin/env bash
# install-target.sh — Install .ai.ui into a target project
#
# Two modes:
#   copy      — rsync clean copy excluding .git, .github, .gitignore, root .cursorrules
#   submodule — git submodule add (requires target to be a git repo)
#
# Usage:
#   bash scripts/install-target.sh copy      /absolute/path/to/repo
#   bash scripts/install-target.sh copy      /absolute/path/to/repo/.ai.ui
#   bash scripts/install-target.sh submodule /absolute/path/to/repo
#   bash scripts/install-target.sh submodule /absolute/path/to/repo/.ai.ui
set -euo pipefail

MODE="${1:?Usage: $0 <copy|submodule> <target-path>}"
RAW_TARGET="${2:?Usage: $0 <copy|submodule> <target-path>}"
AI_UI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Resolve target ──────────────────────────────────────────────────
# If path ends with .ai.ui, use as-is; otherwise append .ai.ui
if [[ "$RAW_TARGET" == *.ai.ui ]]; then
  DEST_DIR="$RAW_TARGET"
else
  DEST_DIR="${RAW_TARGET}/.ai.ui"
fi

# Ensure parent exists
PARENT="$(dirname "$DEST_DIR")"
if [[ ! -d "$PARENT" ]]; then
  echo "ERROR: parent directory does not exist: $PARENT" >&2
  exit 1
fi

if [[ -e "$DEST_DIR" ]] && [[ ! -d "$DEST_DIR" ]]; then
  echo "ERROR: $DEST_DIR exists but is not a directory" >&2
  exit 1
fi

echo "=== ui-install: $MODE → $DEST_DIR ==="

# ── Mode: submodule ─────────────────────────────────────────────────
if [[ "$MODE" == "submodule" ]]; then
  if [[ -d "$DEST_DIR" ]]; then
    echo "  exists: $DEST_DIR (already installed)"
    exit 0
  fi

  # Determine remote from source
  REMOTE="$(cd "$AI_UI_ROOT" && git remote get-url origin 2>/dev/null || true)"
  if [[ -z "$REMOTE" ]]; then
    echo "ERROR: no git remote found in $AI_UI_ROOT" >&2
    echo "  Cannot add as submodule without a remote URL." >&2
    echo "  Use 'copy' mode instead." >&2
    exit 1
  fi

  cd "$PARENT"
  git submodule add "$REMOTE" "$(basename "$DEST_DIR")"
  echo "  submodule added: $REMOTE → $DEST_DIR"
  echo ""
  echo "Next: commit the .gitmodules change in the target repo."
  exit 0
fi

# ── Mode: copy ──────────────────────────────────────────────────────
if [[ "$MODE" != "copy" ]]; then
  echo "ERROR: unknown mode '$MODE'. Use 'copy' or 'submodule'." >&2
  exit 1
fi

if [[ -d "$DEST_DIR" ]]; then
  echo "  exists: $DEST_DIR — re-copying (overwrite)"
fi

mkdir -p "$DEST_DIR"

# Use git ls-files to copy only tracked files — this automatically
# respects .gitignore (.env, node_modules/, credentials/, dist/,
# examples/*.png, tmp/, .private/, etc.).
# Then filter out meta-files (.gitignore, .cursorrules, .github/)
# and the installer script itself.
cd "$AI_UI_ROOT"
git ls-files --cached \
  | grep -vE '(^\.gitignore$|^\.cursorrules$|^\.github/|^scripts/install-target.sh$)' \
  | rsync -a --files-from=- "$AI_UI_ROOT"/ "$DEST_DIR"/

echo "  copied: only git-tracked files from $AI_UI_ROOT → $DEST_DIR"
echo "  (respects .gitignore; excludes .git/, .github/, .gitignore, .cursorrules)"
echo ""
echo "=== Install complete ==="
echo ""
echo "Next steps in target project:"
echo "  1. Review $DEST_DIR/CHANGELOG.md for latest changes"
echo "  2. Run: @ui-bootstrap init merge-cursorrules"
echo "  3. Or:  bash $DEST_DIR/templates/bootstrap.sh"
