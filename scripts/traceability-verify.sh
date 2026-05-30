#!/usr/bin/env bash
# UI Design OS traceability-verify - machine-check that every screen in the screen
# map (foundation doc 04) is scheduled into at least one milestone. This is the UI
# analogue of Agent OS FR->task traceability: a screen left unscheduled is an orphan.
#
# Contract: in a screen-map doc, every slug in the "## Screens" table must also appear
# in the "## Milestones (UI)" table's Screens column.
#
# Usage:
#   bash traceability-verify.sh                 # scan .work.ui for screen-map docs
#   bash traceability-verify.sh path/to/04-screen-map.md [more...]
#
# Exit 0 = every screen scheduled (or no screen map); exit 1 = orphan screen(s).
set -euo pipefail

failures=0
note() { echo "==> $*"; }
ok()   { echo "    OK: $*"; }
die()  { echo "    FAIL: $*" >&2; failures=$((failures + 1)); }

files=()
if [[ $# -gt 0 ]]; then
  files=("$@")
else
  while IFS= read -r -d '' f; do files+=("$f"); done \
    < <(find .work.ui -name '*screen-map*.md' ! -name 'README*' -print0 2>/dev/null || true)
fi

if [[ ${#files[@]} -eq 0 ]]; then
  note "traceability-verify: no screen-map doc found - nothing to check"
  exit 0
fi

note "UI Design OS traceability-verify (${#files[@]} screen map(s))"

for f in "${files[@]}"; do
  if [[ ! -f "${f}" ]]; then die "${f}: not found"; continue; fi

  result="$(awk '
    function trim(s){ gsub(/^[ \t]+|[ \t]+$/, "", s); gsub(/`/, "", s); return s }
    BEGIN{ FS="|"; sec="" }
    /^##[ \t]+Screens/      { sec="screens"; next }
    /^##[ \t]+Milestones/   { sec="milestones"; next }
    /^##[ \t]/              { sec="other"; next }
    sec=="screens" && /^\|/ {
      slug=trim($2)
      if (slug=="" || slug=="Slug" || slug ~ /^-+$/) next
      declared[slug]=1
    }
    sec=="milestones" && /^\|/ {
      cell=trim($3)
      if (cell=="" || cell=="Screens" || cell ~ /^-+$/) next
      n=split(cell, arr, /[ ,]+/)
      for (i=1;i<=n;i++){ s=trim(arr[i]); if(s!="") scheduled[s]=1 }
    }
    END{
      total=0; orphans=0
      for (s in declared){ total++; if(!(s in scheduled)){ orphans++; print "ORPHAN:" s } }
      print "SUMMARY: screens=" total " orphans=" orphans
    }
  ' "${f}")"

  file_fail=0
  while IFS= read -r line; do
    case "${line}" in
      ORPHAN:*) die "${f}: screen '${line#ORPHAN:}' is not scheduled into any milestone (## Milestones)"; file_fail=1 ;;
      SUMMARY:*)
        # shellcheck disable=SC2086
        set -- ${line#SUMMARY: }
        screens="${1#screens=}"
        [[ "${file_fail}" -eq 0 ]] && ok "${f}: all ${screens} screen(s) scheduled into a milestone"
        ;;
    esac
  done <<< "${result}"
done

if [[ "${failures}" -gt 0 ]]; then
  echo ""
  echo "traceability-verify: ${failures} orphan screen(s)" >&2
  exit 1
fi

echo ""
echo "traceability-verify: every screen scheduled"
