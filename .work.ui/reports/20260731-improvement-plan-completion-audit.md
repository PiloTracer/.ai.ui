# Improvement plan completion audit — 2026-07-31

**Plan:** `.work.ui/reports/20260731-framework-improvement-plan.md` (Phases 0–8)  
**Last commit:** `9aa9e63` — feat: implement improvement plan phases 0-8  
**Audit run:** post-commit verification + gap corrections (uncommitted fixes applied)  
**Verifier:** `bash scripts/framework-verify.sh` — see gate table below

---

## Phase gate summary

| Phase | Objective | Implementation status | Machine gate |
|-------|-----------|----------------------|--------------|
| **P0** License standard | `INTEGRATION_LICENSE_STANDARD` + license scan | ✅ Standard + `framework-verify` URL extraction + 3 self-tests | ✅ PASS |
| **P1** Vision-verify | `vision - <route>` + assertion catalog + self-revision loop | ✅ Skill + `reference.md`; live demo **Unverified** (BYOK/§8.2) | ✅ static PASS; vision demo report honest |
| **P2** Token pipeline | DTCG `tokens.json` + `token-schema-verify.sh` | ✅ Demo JSON + validator wired | ✅ PASS (demo + 3 self-tests) |
| **P3** Brand contract | `03-design-system.brand.template.md` (9 sections) | ✅ Template ships; bootstrap-test asserts | ✅ PASS |
| **P4** Image intake | `intake - <image>` + runbook | ✅ Skill mode + `reference-image-intake.md`; §6 runbook pointer | ✅ docs; scaffold smoke **Unverified** (BYOK backend) |
| **P5** Copy rubrics | `ui-copy/reference.md` + audit row | ✅ Reference + COPY_STANDARD pointer | ✅ PASS |
| **P6** Eval harness | `ui-eval.sh` + CI + `eval` mode + UIS-09 reject list | ✅ Script + workflow + concept prompt | ✅ PASS (synthetic JSON in `ui-eval-demo.json`) |
| **P7** MCP surface | `agent-mcp.md` + bootstrap pointer | ✅ Guide + ui-bootstrap link | ✅ PASS |
| **P8** Python desktop | `ui-python-desktop` + routing + runbook + token-lint `.py` | ✅ 18th skill; 3 skeleton proofs + py_compile self-tests | ✅ PASS |

**Overall:** Phases 0–8 **implemented**; Part G live-demo items that require adopter BYOK/browser are documented as **Unverified** with honest reports.

---

## Part G demo artifacts

| Required artifact | Path | Status |
|-------------------|------|--------|
| Vision-verify report | `.work.ui/reports/20260731-vision-verify-demo.md` | ✅ Honest partial (static verified; live BYOK Unverified) |
| DTCG token JSON | `.work.ui/design-system/tokens.json` | ✅ Validated by token-schema |
| Compiled CSS | `.work.ui/design-system/tokens.css` | ✅ Present (demo) |
| Brand doc → CATALOG | Template only (`03-design-system.brand.template.md`) | ⚠️ No filled demo brand doc → CATALOG walkthrough in repo |
| Image-intake scaffold | — | ⚠️ Unverified — requires screenshot-to-code backend (BYOK) |
| Eval report | `.work.ui/reports/ui-eval-demo.json` | ✅ Synthetic advisory JSON |
| MCP guide | `docs/guides/agent-mcp.md` | ✅ |

---

## `@ui-director` orchestration audit

| Check | Result |
|-------|--------|
| 18 skills in `skills/README.md` | ✅ |
| `framework-verify` derived count | ✅ 18 |
| `desktop` bucket in director skill + shortcut chain | ✅ |
| `ui-director/reference.md` §6 routing row | ✅ |
| `ui-process-router/reference.md` `desktop` bucket | ✅ |
| `SKILL_DEPENDENCIES.md` matrix + cheat sheet | ✅ |
| All buckets map to registered skills (no orphan handles) | ✅ |

---

## Skill efficiency (line counts — `skill.md` only)

| Skill | Lines | Assessment |
|-------|-------|------------|
| ui-process-router | 25 | Lean |
| ui-concept-run | 30 | Lean |
| ui-design-system | ~35 | Lean (after desktop row) |
| ui-python-desktop | 62 | Lean — modes + protocols only |
| ui-director | 212 | Orchestrator — appropriate size |
| ui-copy | 295 | Largest ui-* skill — rubrics moved to `reference.md`; body is workflow |

New skills (`ui-python-desktop` 62 lines, `reference.md` 25) are **not bloated**. Reference files hold catalogs (vision assertions, copy rubrics, desktop primitive map) — correct split.

---

## Corrections applied in this audit (uncommitted)

1. `APPROACH.md` §2 — added `desktop-app` skill chain row (was missing).
2. `ui-design-system/skill.md` — desktop primitive binding when `UI_DESKTOP_STACK` set.
3. `DESIGN_TOKENS_STANDARD` §7 — desktop token binding (tokens.py / FLET / Qt).
4. `ui-director/reference.md` — fixed stale skill-count prose (18 total).
5. `CHANGELOG.md` — 17/17 → 18/18 routing claim.
6. `bootstrap-test.sh` — asserts brand template ships.
7. `framework-verify.sh` — py_compile + token-lint on 3 desktop skeleton proofs.
8. `.work.ui/tmp/desktop-skeleton-proofs/{flet,pyside6,pyqt}/app.py` — moved to tracked `scripts/fixtures/python-desktop/` (gitignored `tmp/` broke CI).
9. Demo reports: vision-verify + ui-eval JSON.
10. `web-research-2026.md` §6 — reference-image-intake runbook pointer.

---

## Assumption ledger

| Class | Items |
|-------|-------|
| **Confirmed** | `framework-verify.sh` PASS after corrections; 18/18 skills; license scan; token-schema; ui-eval self-tests; desktop py_compile ×3 |
| **Inference** | Director routing complete for all registered skills including `desktop` |
| **Unknowns / Unverified** | Live Midscene vision assertions; screenshot-to-code scaffold smoke; filled brand doc → CATALOG demo |

---

## Residual risks

- PyQt6 license nuance — documented, not gated (by design).
- Eval metrics are directional only — must not become sole ship gate.
- DTCG 2025.10 preview drift — pin documented in foundation skill.

**No commit performed** (per operator request).
