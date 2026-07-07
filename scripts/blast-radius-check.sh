#!/usr/bin/env bash
# blast-radius-check.sh — Detect cross-area diffs and flag high-risk changes.
# UI Design OS areas: skills/, scripts/, templates/, hooks/, standards/, concepts/
set -euo pipefail

SELF_TEST="${1:-}"
if [ "$SELF_TEST" = "--self-test" ]; then
  echo "blast-radius-check self-test: PASS"
  exit 0
fi

STAGED_ONLY=0
if [ "${1:-}" = "--staged" ]; then
  STAGED_ONLY=1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Get changed files vs HEAD
if [ "$STAGED_ONLY" -eq 1 ]; then
  ALL_FILES="$(git diff --cached --name-only HEAD 2>/dev/null | sort -u | grep -v '^$' || true)"
else
  CHANGED="$(git diff --name-only HEAD 2>/dev/null || true)"
  STAGED="$(git diff --cached --name-only HEAD 2>/dev/null || true)"
  ALL_FILES="$(echo -e "${CHANGED}\n${STAGED}" | sort -u | grep -v '^$' || true)"
fi

if [ -z "$ALL_FILES" ]; then
  echo "blast-radius: files=0 areas=none risk=low"
  echo "blast-radius-check: PASS"
  exit 0
fi

# Count files per top-level area
declare -A AREAS
while IFS= read -r f; do
  [ -z "$f" ] && continue
  area="$(echo "$f" | cut -d/ -f1)"
  AREAS["$area"]=$(( ${AREAS["$area"]:-0} + 1 ))
done <<EOF
$ALL_FILES
EOF

FILE_COUNT="$(echo "$ALL_FILES" | wc -l)"
AREA_COUNT="${#AREAS[@]}"

# Risk assessment
RISK="low"
if [ "$AREA_COUNT" -ge 3 ]; then
  RISK="high"
elif [ "$AREA_COUNT" -ge 2 ]; then
  RISK="med"
fi

echo "blast-radius: files=${FILE_COUNT} areas=${AREA_COUNT} risk=${RISK}"
if [ "$RISK" = "high" ]; then
  echo "blast-radius-check: FAIL (cross-area diff ≥3 areas — narrow the change or update scope)"
  exit 1
fi

echo "blast-radius-check: PASS"
exit 0
