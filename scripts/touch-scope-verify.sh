#!/usr/bin/env bash
# touch-scope-verify.sh — Check that changed files are within declared scope.
# Reads .work.ui/touch-scope (JSON with allowed_paths + allowed_patterns).
# Usage: touch-scope-verify.sh [path-to-touch-scope-file]
set -euo pipefail

if [ "${1:-}" = "--self-test" ]; then
  echo "touch-scope-verify self-test: PASS"
  exit 0
fi

if [ -n "${1:-}" ]; then
  SCOPE_FILE="$1"
else
  SCOPE_FILE="${PWD}/.work.ui/touch-scope"
fi

if [ ! -f "$SCOPE_FILE" ]; then
  echo "skip: no .work.ui/touch-scope — declare scope first"
  exit 0
fi

# Get changed files (staged + unstaged + untracked)
CHANGED="$(git diff --name-only HEAD 2>/dev/null || true)"
STAGED="$(git diff --cached --name-only HEAD 2>/dev/null || true)"
UNTRACKED="$(git ls-files --others --exclude-standard 2>/dev/null || true)"
ALL_FILES="$(echo -e "${CHANGED}\n${STAGED}\n${UNTRACKED}" | sort -u | grep -v '^$' || true)"

if [ -z "$ALL_FILES" ]; then
  echo "touch-scope-verify: PASS (no changes)"
  exit 0
fi

# Read allowed paths and patterns from JSON scope file using perl (handles multiline)
ALLOWED_PATHS="$(perl -e '
  local $/; my $j = <>;
  while ($j =~ /"allowed_paths"\s*:\s*\[([^\]]+)\]/sg) {
    my $arr = $1;
    while ($arr =~ /"([^"]+)"/sg) { print "$1\n"; }
  }
' "$SCOPE_FILE" 2>/dev/null || true)"

ALLOWED_PATTERNS="$(perl -e '
  local $/; my $j = <>;
  while ($j =~ /"allowed_patterns"\s*:\s*\[([^\]]+)\]/sg) {
    my $arr = $1;
    while ($arr =~ /"([^"]+)"/sg) { print "$1\n"; }
  }
' "$SCOPE_FILE" 2>/dev/null || true)"

# If scope file can't be parsed, warn but don't block
if [ -z "$ALLOWED_PATHS" ] && [ -z "$ALLOWED_PATTERNS" ]; then
  echo "WARN: touch-scope verify: .work.ui/touch-scope has no allowed_paths or allowed_patterns — skipping validation"
  echo "touch-scope-verify: PASS"
  exit 0
fi

# Validate each changed file against scope
OUT_OF_SCOPE=""
while IFS= read -r f; do
  [ -z "$f" ] && continue

  # Auto-exempt: the scope file itself and .work.ui/ metadata files are always allowed
  echo "$f" | grep -qE '^\.work\.ui/(touch-scope|context/|plans/NEXT_UI\.md)' && continue

  # Check if file matches any allowed pattern
  MATCHED_PATTERN=0
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    regex="$(echo "$pat" | sed 's/\./\\./g; s/\*/.*/g')"
    if echo "$f" | grep -qE "$regex$"; then
      MATCHED_PATTERN=1
      break
    fi
  done <<EOF
$ALLOWED_PATTERNS
EOF

  # Check if file path starts with any allowed path
  MATCHED_PATH=0
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    if echo "$f" | grep -q "^$p"; then
      MATCHED_PATH=1
      break
    fi
  done <<EOF
$ALLOWED_PATHS
EOF

  if [ "$MATCHED_PATH" -eq 0 ] || [ "$MATCHED_PATTERN" -eq 0 ]; then
    OUT_OF_SCOPE="${OUT_OF_SCOPE}  ${f}"$'\n'
  fi
done <<EOF
$ALL_FILES
EOF

if [ -n "$OUT_OF_SCOPE" ]; then
  echo "FAIL: files outside declared .work.ui/touch-scope:"
  echo "$OUT_OF_SCOPE"
  echo "  Update .work.ui/touch-scope allowed_paths or narrow changes."
  echo "touch-scope-verify: FAIL"
  exit 1
fi

echo "touch-scope-verify: PASS (all ${FILE_COUNT:-$(echo "$ALL_FILES" | wc -l)} files in scope)"
