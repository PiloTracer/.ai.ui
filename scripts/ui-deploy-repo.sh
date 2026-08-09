#!/usr/bin/env bash
# ui-deploy-repo.sh — Full git-based deploy of UI Design OS into a target
#
# Two modes:
#   clone   — git clone with full history into target dir (requires origin remote)
#   archive — git archive + extract into target dir (no git history, but includes
#             .github/, .gitignore, and root .cursorrules)
#
# "clone" is the default when the source has an origin remote and the target
# does not exist yet. "archive" is the fallback when there's no remote or the
# target exists and needs a partial update.
#
# Flag equivalence: verbs work WITH or WITHOUT the "--" prefix — these are
# identical:
#   bash scripts/ui-deploy-repo.sh clone   /absolute/path/to/target
#   bash scripts/ui-deploy-repo.sh --clone /absolute/path/to/target
# The agent-syntax separator "-" between verb and path is ignored.
#
# status / verify audit the target's wiring without deploying anything:
#   status — read-only report of source + optional target state (always exit 0)
#   verify — strict .cursorrules + asset audit of a deployed target
#            (via scripts/cursorrules-verify.sh); verify --fix fills
#            machine-fixable gaps (sister paths, missing Source-resolution).
#
# Usage:
#   bash scripts/ui-deploy-repo.sh status [target-path]
#   bash scripts/ui-deploy-repo.sh verify <target-path> [--fix]
#   bash scripts/ui-deploy-repo.sh clone    /absolute/path/to/target
#   bash scripts/ui-deploy-repo.sh archive  /absolute/path/to/target
#
set -euo pipefail

AI_UI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERIFY="${AI_UI_ROOT}/scripts/cursorrules-verify.sh"

# ── Argument parsing (verb == --verb, any position; "-" ignored) ──────
MODE=""
FIX=0
RAW_TARGET=""
for a in "$@"; do
  case "$a" in
    status|--status)   MODE="status" ;;
    verify|--verify)   MODE="verify" ;;
    clone|--clone)     MODE="clone" ;;
    archive|--archive) MODE="archive" ;;
    --fix)             FIX=1 ;;
    -)                 ;;  # agent-syntax separator
    --*)               echo "ERROR: unknown flag: $a" >&2; exit 1 ;;
    *)                 if [[ -z "$RAW_TARGET" ]]; then RAW_TARGET="$a"; else echo "ERROR: unexpected argument: $a" >&2; exit 1; fi ;;
  esac
done

# ── status (read-only) ────────────────────────────────────────────────
if [[ "$MODE" == "status" ]]; then
  TARGET="$RAW_TARGET"
  echo "=== ui-deploy-repo status (UI Design OS) ==="
  echo "  source: $AI_UI_ROOT"
  REMOTE="$(cd "$AI_UI_ROOT" && git remote get-url origin 2>/dev/null || true)"
  [[ -n "$REMOTE" ]] && echo "  origin: $REMOTE (clone available)" || echo "  origin: none (use archive mode)"
  echo "  branch: $(cd "$AI_UI_ROOT" && git branch --show-current 2>/dev/null || echo '?')"
  echo "  head: $(cd "$AI_UI_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo '?')"
  echo "  modes: clone | archive"
  if [[ -n "$TARGET" ]]; then
    T="$([ "$TARGET" = "." ] || [ "$TARGET" = "$PWD" ] && pwd || (cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET"))"
    echo ""
    echo "=== target: $T ==="
    [[ -e "$T" ]] && echo "  exists: yes" || echo "  exists: no"
    [[ -e "$T" ]] || exit 0
    [[ -d "$T/.git" ]] && echo "  .git/: present" || echo "  .git/: absent"
    [[ -f "$T/.cursorrules" ]] && echo "  .cursorrules: present" || echo "  .cursorrules: missing"
    [[ -d "$T/.github" ]] && echo "  .github/: present" || echo "  .github/: missing"
    [[ -d "$T/skills" ]] && echo "  skills/: present" || echo "  skills/: missing"
    echo ""
    bash "$VERIFY" "$T" --report || true
  fi
  exit 0
fi

# ── verify (strict .cursorrules audit of a deployed target) ───────────
if [[ "$MODE" == "verify" ]]; then
  TARGET="${RAW_TARGET:-.}"
  if [[ ! -d "$TARGET" ]]; then
    echo "ERROR: target directory does not exist: $TARGET" >&2
    exit 1
  fi
  echo "=== ui-deploy-repo verify → $(cd "$TARGET" && pwd) ==="
  if [[ "$FIX" -eq 1 ]]; then
    bash "$VERIFY" "$TARGET" --fix
  else
    bash "$VERIFY" "$TARGET"
  fi
  exit $?
fi

if [[ -z "$MODE" ]]; then
  echo "Usage: $0 [status [path] | verify <path> [--fix] | <clone|archive> <target-path>]" >&2
  exit 1
fi

RAW_TARGET="${RAW_TARGET:?Usage: $0 <clone|archive> <target-path>}"

# ── Resolve target ──────────────────────────────────────────────────
# Always use as-is (unlike ui-deploy-files, this is a full repo deploy)
DEST_DIR="$RAW_TARGET"

# Ensure parent exists
PARENT="$(dirname "$DEST_DIR")"
if [[ ! -d "$PARENT" ]]; then
  echo "ERROR: parent directory does not exist: $PARENT" >&2
  exit 1
fi

echo "=== ui-deploy-repo: $MODE → $DEST_DIR ==="

# ── Mode: clone ─────────────────────────────────────────────────────
if [[ "$MODE" == "clone" ]]; then
  if [[ -d "$DEST_DIR/.git" ]]; then
    echo "  exists: $DEST_DIR (already a git repo — use 'archive' for partial update)" >&2
    exit 1
  fi

  REMOTE="$(cd "$AI_UI_ROOT" && git remote get-url origin 2>/dev/null || true)"
  if [[ -z "$REMOTE" ]]; then
    echo "ERROR: no git remote 'origin' in source repo $AI_UI_ROOT" >&2
    echo "  Cannot clone without a remote URL. Use 'archive' mode instead." >&2
    exit 1
  fi

  if [[ -e "$DEST_DIR" ]]; then
    echo "ERROR: $DEST_DIR already exists. Clone requires a non-existent or empty target." >&2
    exit 1
  fi

  git clone "$REMOTE" "$DEST_DIR"
  echo ""
  echo "=== Done: full repo cloned to $DEST_DIR ==="
  echo "Branch: $(cd "$DEST_DIR" && git branch --show-current)"
  echo "Origin: $REMOTE"
  exit 0
fi

# ── Mode: archive ───────────────────────────────────────────────────

# --- Coexistence safety scan ---
CONFLICT_FILES=""
for candidate in .cursorrules .github/ .gitignore .gitattributes .editorconfig; do
  if [[ -e "${DEST_DIR}/${candidate}" ]]; then
    CONFLICT_FILES="${CONFLICT_FILES}  ${candidate}"$'\n'
  fi
done

SISTER_FRAMEWORKS=""
for sf in .ai .ai.biz .ai.soc .work; do
  if [[ -d "${DEST_DIR}/${sf}" ]]; then
    SISTER_FRAMEWORKS="${SISTER_FRAMEWORKS}  ${sf}"$'\n'
  fi
done

if [[ -n "$CONFLICT_FILES" ]]; then
  echo "WARN: The following existing files will be OVERWRITTEN:"
  echo "$CONFLICT_FILES"
  echo "  Recommend: backup the target first, or use ui-deploy-files instead"
  echo "  (ui-deploy-files respects existing files with no-overwrite default)."
  echo ""
fi

if [[ -n "$SISTER_FRAMEWORKS" ]]; then
  echo "INFO: Sister framework directories detected:"
  echo "$SISTER_FRAMEWORKS"
  echo "  ui-deploy-repo archive will NOT touch these directories — safe coexistence."
  echo ""
fi

# Confirm on overwrite when key project files exist
if [[ -n "$CONFLICT_FILES" ]]; then
  echo "Press Ctrl-C to cancel, or ENTER to proceed with archive deploy."
  read -r </dev/tty || true
fi

# --- End coexistence safety ---

mkdir -p "$DEST_DIR"
cd "$AI_UI_ROOT"

git archive --format=tar HEAD | tar xf - -C "$DEST_DIR"

echo ""
echo "=== Done: repo archive deployed to $DEST_DIR ==="
echo "Includes: .github/, .gitignore, .cursorrules (full tree, no .git history)"
echo ""
# Post-deploy wiring audit (read-only report — strict form: ui-deploy-repo verify).
bash "$VERIFY" "$DEST_DIR" --report || true
echo ""
echo "Next steps in target project:"
echo "  1. Review overwritten files (.cursorrules, .github/ may need merge)"
echo "  2. Initialize git: git init && git add . && git commit -m 'init: UI Design OS'"
echo "  3. Set origin remote if needed"
echo "  4. Run @ui-bootstrap init merge-cursorrules"
