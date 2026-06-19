#!/usr/bin/env bash
# deploy-files.sh — Deploy .ai.ui (UI Design OS) files into a target project
#
# Copies ONLY files git considers (tracked + untracked-not-ignored): anything
# in .gitignore — node_modules, dist, credentials, tmp/, examples/*.png — is
# never deployed.  This makes "files excluded in .gitignore are never copied"
# an invariant enforced by construction, not a hand-maintained exclude list.
#
# Then strips skill-level intentional omissions (.github/, .gitignore,
# .gitattributes, .cursorrules, deploy scripts) — these ARE tracked but are
# omitted from files-only deploy; deploy-repo covers the full-repo case.
#
# Idempotent — re-copies safely without deleting unrelated files in target
# (no --delete): target-side customizations are preserved.
#
# Usage:
#   bash scripts/deploy-files.sh /absolute/path/to/target
#   bash scripts/deploy-files.sh /absolute/path/to/target/.ai.ui
#
set -euo pipefail

RAW_TARGET="${1:?Usage: $0 <target-path>}"
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

# ── Source must be a git repo so the tracked/not-ignored set is authoritative ──
if ! (cd "$AI_UI_ROOT" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
  echo "ERROR: source $AI_UI_ROOT is not a git repo." >&2
  echo "  deploy-files copies only git-tracked / non-ignored files (never .gitignored content)." >&2
  exit 1
fi

GIT_TOP="$(cd "$AI_UI_ROOT" && git rev-parse --show-toplevel)"
if [[ "$GIT_TOP" != "$AI_UI_ROOT" ]]; then
  echo "ERROR: $AI_UI_ROOT is not the git repo root (root is $GIT_TOP)." >&2
  echo "  deploy-files expects the .ai.ui directory to be the repository root." >&2
  exit 1
fi

echo "=== deploy-files → $DEST_DIR ==="

if [[ -d "$DEST_DIR" ]]; then
  echo "  exists: $DEST_DIR — re-copying (overwrite; preserves untracked target files)"
fi

# ── Build copy list: files git sees (tracked + untracked-not-ignored) ──
# --cached            : tracked files (committed + staged)
# --others            : untracked files
# --exclude-standard  : skip untracked files that .gitignore excludes
# Net set = every file not excluded by .gitignore → enforces the invariant.
# Skill-level excludes are intentional omissions of otherwise-tracked files.
SKILL_EXCLUDE_REGEX='^(\.github/|\.gitignore$|\.gitattributes$|\.cursorrules$|scripts/deploy-files\.sh$|scripts/deploy-repo\.sh$)'

TMP_LIST="$(mktemp)"
trap 'rm -f "$TMP_LIST"' EXIT

( cd "$AI_UI_ROOT" \
  && git ls-files --cached --others --exclude-standard \
  | grep -vE "$SKILL_EXCLUDE_REGEX" \
  | while IFS= read -r f; do test -f "$AI_UI_ROOT/$f" && echo "$f"; done \
) > "$TMP_LIST"

COUNT="$(wc -l < "$TMP_LIST" | tr -d ' ')"

mkdir -p "$DEST_DIR"
rsync -a --files-from="$TMP_LIST" "$AI_UI_ROOT"/ "$DEST_DIR"/

echo "  copied: $COUNT files (git-ignored content excluded by policy)"
echo ""
echo "=== Done: files deployed to $DEST_DIR ==="
echo ""
echo "Next steps in target project:"
echo "  1. Run @ui-bootstrap init merge-cursorrules"
echo "  2. Run @ui-project-approach - <describe project>"
echo "  3. Edit .cursorrules — fill every REPLACE: token"
