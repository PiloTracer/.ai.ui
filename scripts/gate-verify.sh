#!/usr/bin/env bash
# gate-verify.sh — Verify gate quality for UI Design OS tasks.
# Checks that done tasks cite evidence (not empty Notes).
# Usage: gate-verify.sh [path-to-NEXT_UI.md]
set -u
fail=0

if [ -n "${1:-}" ]; then
  NEXT="$1"
else
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  NEXT="${REPO_ROOT}/.work.ui/plans/NEXT_UI.md"
fi

gate_fail() { echo "FAIL: $*" >&2; fail=1; }

if [ ! -f "$NEXT" ]; then
  echo "gate-verify: PASS (no NEXT_UI.md)"
  exit 0
fi

# Parse Done section: awk extracts task+notes from table rows between ## Done and ## Blocked,
# skipping the header (| Task | Notes |) and separator (|---|---|) lines.
# A valid row is `| <task> | <notes> |`. We check if notes (2nd field) is empty/whitespace.
awk -v fail_file="${NEXT}" '
  /^## Done/ { in_done = 1; next }
  /^## Blocked/ { in_done = 0; next }
  in_done && /^\|.+\|.+\|$/ {
    # Split on | and trim whitespace from each field
    n = split($0, f, "|")
    # f[1] = "" (before first |), f[2] = task, f[3] = notes, f[4] = "" (after last |)
    if (n >= 3) {
      task = f[2]
      notes = f[3]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", task)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", notes)
      # Skip header (Task/Notes) and separator (---) lines
      if (task ~ /^[-]+$/) next
      if (task == "Task" && notes == "Notes") next
      if (task == "") next
      if (notes == "") {
        print "FAIL: Done task \x27" task "\x27 has empty Notes - cite evidence" > "/dev/stderr"
        exit 1
      }
    }
  }
' "$NEXT" 2>&1 || fail=1

if [ "$fail" -eq 0 ]; then
  echo "gate-verify: PASS"
else
  echo "gate-verify: FAIL"
fi
exit "$fail"
