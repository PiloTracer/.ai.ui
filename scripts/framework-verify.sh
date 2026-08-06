#!/usr/bin/env bash
# Verify UI Design OS framework structure (run from .ai.ui root or repo with .ai.ui/)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

check() {
  if [[ -e "${ROOT}/$1" ]]; then
    echo "ok: $1"
  else
    echo "MISSING: $1"
    FAIL=1
  fi
}

echo "UI Design OS framework-verify"
echo "ROOT=${ROOT}"
echo ""

for p in \
  README.md START_HERE.md COHABITATION.md APPROACH.md \
  .work.ui/README.md .work.ui/context/HANDOFF_UI.md .work.ui/plans/NEXT_UI.md \
  skills/README.md skills/SKILL_DEPENDENCIES.md \
  concepts/README.md \
  templates/bootstrap.sh templates/cursorrules.ui.template templates/cursorrules.ui.snippet.template \
  templates/DOCS_UI_STACK.md.template scripts/cursorrules-ui.sh \
  scripts/ui-deploy-basic.sh scripts/ui-deploy-files.sh scripts/ui-deploy-repo.sh \
  scripts/ui-session.sh \
  scripts/token-lint.sh scripts/bootstrap-test.sh \
  scripts/token-schema-verify.sh scripts/ui-eval.sh \
  docs/adoption/FROM_AGENT_OS.md \
  style-stacks/README.md examples/INDEX.md resources/control-platforms.md \
  standards/20260523-SURFACE-AND-CONTROL-CRAFT.md \
  standards/20260523-UI-PATTERNS.md \
  standards/20260523-SCREEN_SPEC_STANDARD.md \
  standards/20260523-DESIGN_TOKENS_STANDARD.md \
  standards/20260523-COMPONENT_STANDARD.md \
  standards/20260523-ACCESSIBILITY_STANDARD.md \
  standards/20260523-UI-CONVENTIONS.md \
  standards/20260523-FRONTEND_DIRECTORY_MAP.md \
  standards/20260523-RESPONSIVE_STANDARD.md \
  standards/20260523-MOTION_STANDARD.md \
  standards/20260523-COPY_STANDARD.md \
  standards/20260523-INTEGRATION_LICENSE_STANDARD.md \
  examples/dashboards/manifest.md examples/mobile-controls/manifest.md \
  examples/mobile/manifest.md examples/websites/manifest.md examples/websites-tecnology/manifest.md; do
  check "$p"
done

# Derived skill count + registration cross-check (no hardcoded list - prevents drift).
SKILL_COUNT=0
while IFS= read -r d; do
  id="$(basename "$d")"
  SKILL_COUNT=$((SKILL_COUNT + 1))
  check "skills/${id}/skill.md"
  if ! grep -qE "^\| ${id} " "${ROOT}/skills/README.md"; then
    echo "UNREGISTERED: skills/${id} not in skills/README.md Registered skills table"
    FAIL=1
  fi
done < <(find "${ROOT}/skills" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort)
echo "ok: ${SKILL_COUNT} skills (derived) registered in skills/README.md"

# No Agent OS skill name collisions under .ai.ui/skills
FORBIDDEN="plan-foundation plan-master code-implementation session-control process-router concept-run project-bootstrap"
for name in $FORBIDDEN; do
  if [[ -d "${ROOT}/skills/${name}" ]]; then
    echo "COLLISION: skills/${name} must not exist in .ai.ui (use ui-* prefix)"
    FAIL=1
  fi
done

# UIS concepts present (UIS-01 through UIS-10)
for id in visual-hierarchy responsive-layout motion-design color-contrast interaction-patterns ai-visual-quality surface-control-craft intuitive-ux data-visualization-quality creative-direction; do
  check "concepts/${id}/prompt.md"
done

# S0 before S1 in onboarding templates
for f in README.md templates/work.ui/plans/NEXT_UI.md.template .work.ui/plans/NEXT_UI.md; do
  if [[ -f "${ROOT}/${f}" ]] && grep -q 'plan - S1' "${ROOT}/${f}" && ! grep -q 'plan - S0' "${ROOT}/${f}"; then
    echo "WARN: ${f} mentions S1 but not S0 (craft tier refined path)"
  fi
done

# Prose drift guard: skill-count mentions in landing docs must match derived count.
for doc in README.md START_HERE.md skills/README.md; do
  while IFS= read -r num; do
    [[ -z "$num" ]] && continue
    if [[ "$num" -ne "$SKILL_COUNT" ]]; then
      echo "PROSE DRIFT: ${doc} mentions '${num} skills' but ${SKILL_COUNT} skill dirs exist"
      FAIL=1
    fi
  done < <(sed 's/[*`]//g' "${ROOT}/${doc}" | grep -oiE '[0-9]+ (ui-? )?skills?|skills? \([0-9]+\)' | grep -oE '[0-9]+' || true)
done

# Probe engine present (referenced by both probe modes).
check "skills/probe-protocol.md"

# Intake contract guard: ui-screen-spec intake table must keep all 4 classes + force
# override (classification is agent-judged, so this is a structural contract guard).
INTAKE_MD="${ROOT}/skills/ui-screen-spec/skill.md"
intake_ok=1
for cls in local cross-cutting brownfield underspecified; do
  grep -qE "\*\*${cls}\*\*" "${INTAKE_MD}" || { echo "INTAKE: ui-screen-spec missing class '${cls}'"; FAIL=1; intake_ok=0; }
done
grep -qE 'force=<class>' "${INTAKE_MD}" || { echo "INTAKE: ui-screen-spec missing force=<class> override"; FAIL=1; intake_ok=0; }
[[ $intake_ok -eq 1 ]] && echo "ok: ui-screen-spec intake contract (4 classes + force override)"

# Self-tests: the new verifiers must not silently rot (cf. honesty rules).
tmpd="$(mktemp -d)"
trap 'rm -rf "${tmpd}"' EXIT

cat > "${tmpd}/honest.md" <<'EOF'
**Coverage:** 100% (target 85%)
| Dim | Topic | Status | Conf | Evidence / source | Iter |
|-----|-------|--------|------|-------------------|------|
| D1 ★ | intent | confirmed | high | doc 01 §intent | 1 |
| D2 | tokens | confirmed | high | doc 02 | 1 |
EOF
cat > "${tmpd}/uncited.md" <<'EOF'
**Coverage:** 100% (target 85%)
| Dim | Topic | Status | Conf | Evidence / source | Iter |
|-----|-------|--------|------|-------------------|------|
| D1 ★ | intent | confirmed | high | — | 1 |
EOF
cat > "${tmpd}/sm-ok.md" <<'EOF'
## Screens
| Slug | Route | Priority | Domain SPEC link | SPEC status |
|------|-------|----------|------------------|-------------|
| home | `/` | P0 | - | Draft |
## Milestones (UI)
| Milestone | Screens | Notes |
|-----------|---------|-------|
| S1 | home | shell |
EOF
cat > "${tmpd}/sm-orphan.md" <<'EOF'
## Screens
| Slug | Route | Priority | Domain SPEC link | SPEC status |
|------|-------|----------|------------------|-------------|
| home | `/` | P0 | - | Draft |
| settings | `/settings` | P1 | - | Draft |
## Milestones (UI)
| Milestone | Screens | Notes |
|-----------|---------|-------|
| S1 | home | shell |
EOF

selftest() { # desc expected_exit script args...
  local desc="$1" exp="$2"; shift 2
  if bash "$@" >/dev/null 2>&1; then got=0; else got=1; fi
  if [[ "$got" -eq "$exp" ]]; then
    echo "ok: selftest ${desc}"
  else
    echo "SELFTEST FAIL: ${desc} (expected exit ${exp}, got ${got})"; FAIL=1
  fi
}
selftest "readiness-verify accepts honest"   0 "${ROOT}/scripts/readiness-verify.sh"   "${tmpd}/honest.md"
selftest "readiness-verify rejects uncited"  1 "${ROOT}/scripts/readiness-verify.sh"   "${tmpd}/uncited.md"
selftest "traceability-verify accepts scheduled" 0 "${ROOT}/scripts/traceability-verify.sh" "${tmpd}/sm-ok.md"
selftest "traceability-verify rejects orphan"    1 "${ROOT}/scripts/traceability-verify.sh" "${tmpd}/sm-orphan.md"

# token-lint self-tests: the design-token gate must reject raw hex in component
# source and accept token usage (cf. DESIGN_TOKENS_STANDARD - no magic hex).
printf 'const c = "var(--color-accent)";\n' > "${tmpd}/tl-clean.tsx"
printf 'const c = "#2f6df6";\n' > "${tmpd}/tl-dirty.tsx"
selftest "token-lint accepts token usage" 0 "${ROOT}/scripts/token-lint.sh" "${tmpd}/tl-clean.tsx"
selftest "token-lint rejects raw hex"     1 "${ROOT}/scripts/token-lint.sh" "${tmpd}/tl-dirty.tsx"

# Python desktop skeleton proofs (Phase 8): stdlib py_compile only — no pip/Qt/FLET required.
desk_base="${ROOT}/scripts/fixtures/python-desktop"
for stack in flet pyside6 pyqt; do
  skel="${desk_base}/${stack}/app.py"
  if [[ -f "$skel" ]]; then
    if python3 -m py_compile "$skel" >/dev/null 2>&1; then
      echo "ok: desktop skeleton py_compile (${stack})"
    else
      echo "DESKTOP: py_compile failed for ${stack} skeleton"; FAIL=1
    fi
    if "${ROOT}/scripts/token-lint.sh" "$skel" >/dev/null 2>&1; then
      echo "ok: desktop skeleton token-lint (${stack})"
    else
      echo "DESKTOP: token-lint failed for ${stack} skeleton"; FAIL=1
    fi
  else
    echo "DESKTOP: missing skeleton ${skel}"; FAIL=1
  fi
done

# token-schema (DTCG) self-tests + demo validation (Phase 2 token pipeline).
cat > "${tmpd}/ts-ok.json" <<'EOF'
{ "color": { "accent": { "$type": "color", "$value": "#2f6df6" }, "page": { "$type": "color", "$value": "{color.accent}" } } }
EOF
cat > "${tmpd}/ts-bad-alias.json" <<'EOF'
{ "color": { "accent": { "$type": "color", "$value": "{color.missing}" } } }
EOF
cat > "${tmpd}/ts-bad-type.json" <<'EOF'
{ "color": { "accent": { "$type": "notatype", "$value": "#2f6df6" } } }
EOF
selftest "token-schema accepts DTCG tokens"       0 "${ROOT}/scripts/token-schema-verify.sh" "${tmpd}/ts-ok.json"
selftest "token-schema rejects unresolved alias"  1 "${ROOT}/scripts/token-schema-verify.sh" "${tmpd}/ts-bad-alias.json"
selftest "token-schema rejects unknown type"      1 "${ROOT}/scripts/token-schema-verify.sh" "${tmpd}/ts-bad-type.json"
if "${ROOT}/scripts/token-schema-verify.sh" "${ROOT}/.work.ui/design-system/tokens.json" >/dev/null 2>&1; then
  echo "ok: token-schema validates demo tokens.json"
else
  echo "TOKEN-SCHEMA: demo .work.ui/design-system/tokens.json invalid"; FAIL=1
fi

# ui-eval (advisory quality metrics) self-tests: metric math must not silently rot.
selftest "ui-eval metric core self-test" 0 "${ROOT}/scripts/ui-eval.sh" "--self-test"
cat > "${tmpd}/eval-cand.json" <<'EOF'
{"histogram": [3, 5, 2], "text": ["Save"], "width": 400, "height": 300}
EOF
cat > "${tmpd}/eval-ref.json" <<'EOF'
{"histogram": [3, 5, 2], "expected_text": ["Save"], "width": 400, "height": 300}
EOF
selftest "ui-eval accepts matching descriptors" 0 "${ROOT}/scripts/ui-eval.sh" "--json" "${tmpd}/eval-cand.json" "${tmpd}/eval-ref.json"

# Integration license scan (INTEGRATION_LICENSE_STANDARD): every numbered
# section of the research catalog must declare a **License:** line; §1–§6 must
# not carry forbidden markers (CC-BY-NC / GPL / LGPL) — those belong in §7
# exclusions only. Dynamic section detection keeps it drift-proof.
lic_scan() { # file — exit 0 = pass
  local f="$1" line sec n ok=1 bad
  local -A LIC
  sec=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\ ([0-9]+)\. ]]; then sec="${BASH_REMATCH[1]}"; fi
    if [[ -n "$sec" ]] && [[ "$line" == **License:** ]]; then LIC["$sec"]="$line"; fi
  done < "$f"
  for n in $(seq 1 20); do
    [[ -n "${LIC[$n]:-}" ]] && continue
    if grep -qE "^## ${n}\. " "$f"; then
      echo "LICENSE: §${n} missing **License:** line"; ok=0
    fi
  done
  bad="$(awk '/^## 7\./{exit} /^## 1\./{f=1} f && /http/ && /CC-BY-NC|GPL|LGPL/ {print NR": "$0}' "$f")"
  if [[ -n "$bad" ]]; then
    echo "LICENSE: forbidden marker in §1–§6:"; echo "$bad"; ok=0
  fi
  [[ "$ok" -eq 1 ]] && return 0 || return 1
}
cat > "${tmpd}/lic-ok.md" <<'EOF'
## 1. Tokens
**License:** MIT · W3C
## 2. A11y
**License:** MIT · W3C
## 3. Visual QA
**License:** © link-only
## 4. Systems
**License:** MIT
## 5. Copy
**License:** © link-only
## 6. Agent
**License:** MIT
## 7. Exclusions
**License:** CC-BY-NC · paid
## 8. Rules
**License:** none
## 9. Mapping
**License:** none
EOF
cat > "${tmpd}/lic-untagged.md" <<'EOF'
## 1. Tokens
https://example.com/x
## 2. A11y
**License:** MIT
## 3. Visual QA
**License:** © link-only
## 4. Systems
**License:** MIT
## 5. Copy
**License:** © link-only
## 6. Agent
**License:** MIT
## 7. Exclusions
**License:** CC-BY-NC
## 8. Rules
**License:** none
## 9. Mapping
**License:** none
EOF
cat > "${tmpd}/lic-forbidden.md" <<'EOF'
## 1. Tokens
**License:** MIT
https://example.com/cc-by-nc CC-BY-NC licensed guide
## 2. A11y
**License:** MIT
## 3. Visual QA
**License:** © link-only
## 4. Systems
**License:** MIT
## 5. Copy
**License:** © link-only
## 6. Agent
**License:** MIT
## 7. Exclusions
**License:** CC-BY-NC
## 8. Rules
**License:** none
## 9. Mapping
**License:** none
EOF
lic_selftest() { # desc expected_exit fixture
  local desc="$1" exp="$2" f="$3" got
  if lic_scan "$f" >/dev/null 2>&1; then got=0; else got=1; fi
  if [[ "$got" -eq "$exp" ]]; then
    echo "ok: selftest ${desc}"
  else
    echo "SELFTEST FAIL: ${desc} (expected exit ${exp}, got ${got})"; FAIL=1
  fi
}
lic_selftest "license scan accepts tagged catalog"    0 "${tmpd}/lic-ok.md"
lic_selftest "license scan rejects untagged section"  1 "${tmpd}/lic-untagged.md"
lic_selftest "license scan rejects CC-BY-NC in §1–§6" 1 "${tmpd}/lic-forbidden.md"
lic_scan "${ROOT}/resources/web-research-2026.md" \
  && echo "ok: integration license scan (catalog §1–§9 tagged, §1–§6 clean)" \
  || { echo "LICENSE: research catalog fails the license scan"; FAIL=1; }

# ui-session self-test: .work.ui-scoped commit/close/push must not silently rot
# (scope guard, untracked inclusion, combinations, push) — cf. honesty rules.
selftest "ui-session scope-guard self-test" 0 "${ROOT}/scripts/ui-session.sh" "--self-test"

# change-safety self-tests: touch-scope, blast-radius, gate-verify must not silently rot.
selftest "touch-scope-verify self-test"   0 "${ROOT}/scripts/touch-scope-verify.sh" "--self-test"
selftest "blast-radius-check self-test"   0 "${ROOT}/scripts/blast-radius-check.sh" "--self-test"

# gate-verify: create NEXT_UI.md with done tasks — one with notes (pass), one without (fail).
cat > "${tmpd}/NEXT_UI.md.with-notes" <<'EOF'
## Done
| Task | Notes |
|------|-------|
| T1 | Verified by test |
## Blocked
| Task | Notes |
|------|-------|
EOF
cat > "${tmpd}/NEXT_UI.md.empty-notes" <<'EOF'
## Done
| Task | Notes |
|------|-------|
| T1 |  |
## Blocked
| Task | Notes |
|------|-------|
EOF
mkdir -p "${tmpd}/.work.ui/plans"
cp "${tmpd}/NEXT_UI.md.with-notes" "${tmpd}/.work.ui/plans/NEXT_UI.md"
selftest "gate-verify accepts done task with notes" 0 "${ROOT}/scripts/gate-verify.sh" "${tmpd}/.work.ui/plans/NEXT_UI.md"
cp "${tmpd}/NEXT_UI.md.empty-notes" "${tmpd}/.work.ui/plans/NEXT_UI.md"
selftest "gate-verify rejects done task without notes" 1 "${ROOT}/scripts/gate-verify.sh" "${tmpd}/.work.ui/plans/NEXT_UI.md"

# install-git-hooks: smoke test on a throwaway .git repo.
mkdir -p "${tmpd}/hooks-test/.git/hooks"
pushd "${tmpd}/hooks-test" >/dev/null
AI_UI_ROOT="${ROOT}" bash "${ROOT}/scripts/install-git-hooks.sh" >/dev/null 2>&1
HOOK_COUNT="$(find .git/hooks -type f | wc -l)"
if [[ "$HOOK_COUNT" -ge 4 ]]; then
  echo "ok: selftest install-git-hooks copies hooks (${HOOK_COUNT} installed)"
else
  echo "SELFTEST FAIL: install-git-hooks (${HOOK_COUNT} hooks, expected ≥4)"; FAIL=1
fi
popd >/dev/null

# traceability SPEC-backing + rogue-SPEC self-tests (need a .work.ui/plans + screens
# layout so the screens dir is derivable from the map path).
mkdir -p "${tmpd}/.work.ui/plans/foundation" "${tmpd}/.work.ui/screens/home"
cat > "${tmpd}/.work.ui/plans/foundation/sm-approved.md" <<'EOF'
## Screens
| Slug | Route | Priority | Domain SPEC link | SPEC status |
|------|-------|----------|------------------|-------------|
| home | `/` | P0 | - | Approved |
## Milestones (UI)
| Milestone | Screens | Notes |
|-----------|---------|-------|
| S1 | home | shell |
EOF
SM_APPROVED="${tmpd}/.work.ui/plans/foundation/sm-approved.md"
selftest "traceability rejects approved-without-SPEC" 1 "${ROOT}/scripts/traceability-verify.sh" "${SM_APPROVED}"
echo "# spec" > "${tmpd}/.work.ui/screens/home/20260530-SCREEN-SPEC.md"
selftest "traceability accepts approved-with-SPEC"    0 "${ROOT}/scripts/traceability-verify.sh" "${SM_APPROVED}"
mkdir -p "${tmpd}/.work.ui/screens/rogue"; echo "# x" > "${tmpd}/.work.ui/screens/rogue/20260530-SCREEN-SPEC.md"
selftest "traceability rejects rogue SPEC dir"        1 "${ROOT}/scripts/traceability-verify.sh" "${SM_APPROVED}"

# Adopter first-run integration: bootstrap.sh must produce a usable .work.ui/.
# Only when ROOT is the git top-level (the test exports tracked files); skipped
# when .ai.ui/ is nested in an adopter repo.
if git -C "${ROOT}" rev-parse --show-toplevel >/dev/null 2>&1 \
   && [[ "$(git -C "${ROOT}" rev-parse --show-toplevel)" == "${ROOT}" ]]; then
  if bash "${ROOT}/scripts/bootstrap-test.sh" >/dev/null 2>&1; then
    echo "ok: bootstrap-test (adopter first-run produces usable .work.ui/)"
  else
    echo "BOOTSTRAP: scripts/bootstrap-test.sh failed - adopter first-run is broken"; FAIL=1
  fi
fi

# Markdown local-link scan: relative links in .md files must resolve. Skips
# external (http/mailto), anchors (#...), placeholders ({ < REPLACE:), and Agent
# OS cross-refs (.ai/ .work/ are sibling trees, not part of this repo).
link_breaks=0
while IFS= read -r md; do
  d="$(dirname "${md}")"
  while IFS= read -r tgt; do
    [[ -z "${tgt}" ]] && continue
    case "${tgt}" in
      http://*|https://*|mailto:*|\#*) continue ;;
      *REPLACE:*|*"{"*|*"<"*) continue ;;
      .ai/*|*/.ai/*|.work/*|*/.work/*) continue ;;
    esac
    path="${tgt%% *}"; path="${path%%#*}"
    [[ -z "${path}" ]] && continue
    if [[ "${path}" = /* ]]; then resolved="${path}"; else resolved="${d}/${path}"; fi
    if [[ ! -e "${resolved}" ]]; then
      echo "BROKEN LINK: ${md#"${ROOT}"/} → ${tgt}"
      FAIL=1; link_breaks=$((link_breaks + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "${md}" | sed -E 's/^\]\(//; s/\)$//')
done < <(find "${ROOT}" -name '*.md' -not -path '*/.git/*' | sort)
[[ "${link_breaks}" -eq 0 ]] && echo "ok: markdown local-link scan (no broken relative links)"

# --- ui-deploy-files in-place scaffold (fat-client) ---
note_deploy="ui-deploy-files in-place scaffold"
echo ""
echo "==> ${note_deploy}"
DF_SMOKE="$(mktemp -d)"
pushd "${DF_SMOKE}" >/dev/null
bash "${ROOT}/scripts/ui-deploy-files.sh" . >/dev/null
[[ -f .cursorrules ]] || { echo "FAIL: ui-deploy-files in-place did not create .cursorrules"; FAIL=1; }
[[ -f .work.ui/context/HANDOFF_UI.md ]] || { echo "FAIL: ui-deploy-files in-place did not create .work.ui/context/HANDOFF_UI.md"; FAIL=1; }
[[ -d .ai.ui/skills ]] || { echo "FAIL: ui-deploy-files in-place did not create .ai.ui/skills"; FAIL=1; }
popd >/dev/null
[[ $FAIL -eq 0 ]] && echo "ok: ui-deploy-files in-place creates .ai.ui/ + .work.ui/ + .cursorrules"

echo ""
echo "==> ui-deploy-repo --status"
bash "${ROOT}/scripts/ui-deploy-repo.sh" --status >/dev/null
bash "${ROOT}/scripts/ui-deploy-repo.sh" --status "${DF_SMOKE}" >/dev/null
[[ $FAIL -eq 0 ]] && echo "ok: ui-deploy-repo --status reports source + target"

rm -rf "${DF_SMOKE}"

# --- ui-deploy-basic thin-client smoke ---
echo ""
echo "==> ui-deploy-basic thin-client scaffold"
DB_SMOKE="$(mktemp -d)"
bash "${ROOT}/scripts/ui-deploy-basic.sh" "${DB_SMOKE}" >/dev/null
if [[ ! -f "${DB_SMOKE}/.cursorrules" ]] || ! grep -q 'AI_UI_SOURCE=' "${DB_SMOKE}/.cursorrules"; then
  echo "FAIL: ui-deploy-basic did not set AI_UI_SOURCE in .cursorrules"
  FAIL=1
else
  echo "ok: ui-deploy-basic creates thin-client .cursorrules + .work.ui/"
fi
rm -rf "${DB_SMOKE}"

# Lean invariant + count self-report. Example PNGs are gitignored (manifests are
# the agent source of truth), so this repo must track 0 binary images; an
# accidental commit is caught here instead of silently bloating the tree. The
# tracked-file count is printed so the "lean" claim in CHANGELOG/HANDOFF stays
# honest. No-op unless ROOT is the git top-level (skips when .ai.ui/ is nested
# inside an adopter repo, where image tracking is the app's concern).
if git -C "${ROOT}" rev-parse --show-toplevel >/dev/null 2>&1 \
   && [[ "$(git -C "${ROOT}" rev-parse --show-toplevel)" == "${ROOT}" ]]; then
  tracked_total="$(git -C "${ROOT}" ls-files | wc -l | tr -d ' ')"
  tracked_imgs="$(git -C "${ROOT}" ls-files | grep -ciE '\.(png|jpe?g|gif|webp|svg)$' || true)"
  if [[ "${tracked_imgs}" -ne 0 ]]; then
    echo "LEAN: ${tracked_imgs} tracked image(s) — example PNGs must stay gitignored (manifests are source of truth)"
    FAIL=1
  else
    echo "ok: lean (${tracked_total} tracked files, 0 tracked images)"
  fi
fi

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "framework-verify: PASS"
else
  echo "framework-verify: FAIL"
  exit 1
fi
