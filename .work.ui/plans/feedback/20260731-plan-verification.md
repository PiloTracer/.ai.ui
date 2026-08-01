# Plan verification feedback — 2026-07-31

**Source:** `.work.ui/reports/20260731-framework-improvement-plan.md`
**Verified against:** repo state at verification time (17 skills registered, `framework-verify.sh` PASS)
**Status:** Plan is sound after 12 gap fixes applied below.

---

## Gaps Found & Resolved

### G1 — High: Missing routing table updates (Phase 8, item 3)

Phase 8 adds a `desktop` bucket to `ui-director` but does not update the routing tables that other skills depend on.

**Fix:** Add rows to:
- `skills/ui-director/reference.md` §6 Common user request routing table
- `skills/ui-process-router/reference.md` bucket list
- `skills/SKILL_DEPENDENCIES.md` dependency matrix

### G2 — High: Skill registration details incomplete (Phase 8, item 4)

Phase 8 says to register in `skills/README.md` + `SKILL_DEPENDENCIES.md` but does not specify the exact rows (registry id, folder, modes, writes, deps) to add.

**Fix:** Specify exact rows for both files (see resolved plan below).

### G3 — Medium: Phase 0 URL-tagging scope mismatch

Phase 0 says "tag §1–§6" but `web-research-2026.md` has §1–§9. Sections §7–§9 contain URLs (exclusion entries, policy URLs, mapping) that also need license tags.

**Fix:** Change scope to "all URL-bearing sections (§1–§9)".

### G4 — Medium: Phase 0 self-test not broken into sub-steps

Scanning URLs and asserting license tiers is a significant script change but isn't broken into sub-steps or given its own self-test verification.

**Fix:** Break into (1) URL extraction step and (2) license assertion step, each with a self-test case in `framework-verify.sh`.

### G5 — Medium: Phase 8 acceptance count inconsistent

Phase 8 acceptance says "17+1 routing check" but after registration the count is 18. Should be "18/18 locatable".

**Fix:** Update acceptance criteria to "18/18 skills locatable (verified by `framework-verify.sh` skill-count derivation + `skills/README.md` row count)".

### G6 — Medium: Missing `ui-style-stack` update for desktop stacks

Phase 8 adds FLET (ft.Theme) and Qt (QSS/palette) desktop stacks but doesn't update `skills/ui-style-stack/skill.md`.

**Fix:** Add `flet` and `qt` stack options to `ui-style-stack/skill.md`; update `status` to report desktop stack binding when `UI_DESKTOP_STACK` is set in HANDOFF_UI.

### G7 — Medium: Missing `ui-design-system` update for desktop primitives

Phase 8 adds desktop primitives (FLET controls, Qt widgets) but doesn't update `skills/ui-design-system/skill.md` CATALOG seeding or `add` mode.

**Fix:** Add desktop primitive map to `ui-design-system/skill.md` `init` and `add` modes.

### G8 — Medium: Missing `ui-project-approach` update for `desktop-app` archetype

Phase 8 adds a `desktop-app` archetype but doesn't update `skills/ui-project-approach/skill.md` classification or `APPROACH.md` §1 archetype table.

**Fix:** Add `desktop-app` archetype to both `APPROACH.md` and `ui-project-approach/skill.md`.

### G9 — Low: Open CoDesign reference unused (Part A, gap note)

Part A gap note says Open CoDesign's Decompose-to-UI-Kit is "useful as a reference for handoff bundle shape, Phase 3/4" but no phase actually cites it.

**Fix:** Add cross-reference in Phase 3 (brand DESIGN.md §6 — component binding shape) and Phase 4 (image intake — handoff bundle structure).

### G10 — Low: `CONTRIBUTING.md` not updated for new skill

CONTRIBUTING.md says "Update SKILL_DEPENDENCIES.md when adding gates" but doesn't mention updating routing tables when adding a new skill.

**Fix:** Add line to CONTRIBUTING.md: "When adding a new `ui-*` skill, also update `skills/ui-director/reference.md` §6 routing table and `skills/ui-process-router/reference.md` bucket list."

### G11 — Low: No pre-populated CHANGELOG/HANDOFF_UI session notes

The plan's per-phase gates require CHANGELOG and HANDOFF_UI updates but doesn't pre-populate what those entries should say.

**Fix:** Add a pre-flight step before Phase 0: update `CHANGELOG.md` `[Unreleased]` with the planned entry and add a HANDOFF_UI session note template per phase.

### G12 — Low: Phase 6 "approx metric" not explicit enough

Phase 6 says "approximations of Design2Code" but doesn't clarify what "approx" means or when it's insufficient.

**Fix:** Change to "**approximate** metrics (bounding-box IoU, text match, position match, color histogram — **not** CLIP/semantic similarity; directional signal only, not a pass/fail gate; humans decide on flags)."

---

## Resolved Plan (corrected)

### Phase 0 — Integration license standard

- Scope: tag all URL-bearing sections (§1–§9) of `resources/web-research-2026.md`
- Self-test: break into URL extraction + license assertion sub-steps; add inject-fake-CC-BY-NC test case to `framework-verify.sh`

### Phase 1 — Vision-verify tier

- No changes from original plan (accurate)

### Phase 2 — Token truth pipeline

- No changes from original plan (accurate)

### Phase 3 — Brand design-system contract

- Add cross-reference to Open CoDesign Decompose-to-UI-Kit for handoff bundle shape (§6 component binding)

### Phase 4 — Reference-image intake

- Add cross-reference to Open CoDesign Decompose-to-UI-Kit for handoff bundle structure

### Phase 5 — Copy quality rubric

- No changes from original plan (accurate)

### Phase 6 — Eval harness + CI

- Clarify "approx metric" disclaimer (see G12 fix)

### Phase 7 — Agent MCP surface

- No changes from original plan (accurate)

### Phase 8 — Python desktop UI skills

- Add routing table updates to `ui-director/reference.md` §6, `ui-process-router/reference.md`, `SKILL_DEPENDENCIES.md` (G1)
- Specify exact registration rows for `skills/README.md` and `SKILL_DEPENDENCIES.md` (G2)
- Update acceptance criteria to "18/18 skills locatable" (G5)
- Add `flet` and `qt` stack options to `ui-style-stack/skill.md` (G6)
- Add desktop primitive map to `ui-design-system/skill.md` (G7)
- Add `desktop-app` archetype to `APPROACH.md` and `ui-project-approach/skill.md` (G8)
- Update `CONTRIBUTING.md` with routing table update rule (G10)

### Cross-phase

- Pre-flight: update `CHANGELOG.md` `[Unreleased]` and HANDOFF_UI session note template (G11)

---

## Assumption Ledger

| Class | Items |
|-------|-------|
| **Confirmed** | All 12 gaps verified against actual repo files; `framework-verify.sh` PASS at time of verification; 17 skills registered; `web-research-2026.md` has §1–§9; `feedback/` exists as empty directory |
| **Inference** | The plan's Phase sequencing is correct; the routing table updates in G1/G2 are necessary for the `desktop` bucket to be functional; the style-stack and design-system updates in G6/G7 are needed for desktop tokens to flow correctly |
| **Unknowns** | Whether the operator wants the feedback file to replace the original plan or coexist alongside it; whether Phase 0's license-scanning self-test should be a separate PR from the other Phase 0 changes |

---

## Completion Gate

- All 12 gaps documented with fixes
- Resolved plan provided with exact file paths and changes
- No files modified in the repo (recommendations only)
- `framework-verify.sh` PASS (unchanged)
- Operator must explicitly request before any commit or push

---

## Validation outcome (2026-07-31, applied)

Each recommendation validated against repo state; implementable fixes applied. Plan file: `.work.ui/reports/20260731-framework-improvement-plan.md`.

| Gap | Verdict | Where applied |
|-----|---------|---------------|
| G1 routing-table updates | ✅ Valid — plan now names all 3 tables (`ui-director/reference.md` §6, `ui-process-router/reference.md`, `SKILL_DEPENDENCIES.md`) | Plan Phase 8 item 3 |
| G2 exact registration rows | ✅ Valid — exact `skills/README.md` row + `SKILL_DEPENDENCIES.md` rows specified | Plan Phase 8 item 4 |
| G3 URL-tagging scope | ✅ Valid — doc has §1–§9; §7 carries exclusion/deprecation URLs | Plan Phase 0 items 2–3 |
| G4 self-test sub-steps | ✅ Valid — URL extraction (2a) + license assertion (2b) + inject-fake-CC-BY-NC test case | Plan Phase 0 item 2 |
| G5 acceptance count | ✅ Valid — corrected to 18/18 locatable (was "17+1") | Plan Phase 8 acceptance |
| G6 style-stack desktop binding | ✅ Valid (partial) — CSS-stack contract kept intact; `ui-style-stack` `status` now cross-reports `UI_DESKTOP_STACK`; hard-rule note added | Live: `skills/ui-style-stack/skill.md`; plan Phase 8 item 8 |
| G7 design-system desktop primitives | ✅ Valid — `ui-design-system` init/add accept desktop primitive map when `UI_DESKTOP_STACK` set | Plan Phase 8 item 8 |
| G8 desktop-app archetype | ✅ Valid — `APPROACH.md` §1 + `ui-project-approach` classification | Plan Phase 8 item 2 |
| G9 Open CoDesign reference | ✅ Valid — cross-referenced in Phase 3 (§6 binding) + Phase 4 (handoff structure) | Plan Phase 3 item 1, Phase 4 item 2 |
| G10 CONTRIBUTING rule | ✅ Valid + **applied live** — new rule #5 (routing tables on new skill) | Live: `CONTRIBUTING.md` |
| G11 CHANGELOG/HANDOFF pre-population | ✅ Valid — pre-flight step added before Phase 0 with per-phase placeholder template; CHANGELOG entries land per phase when shipped (kept out of CHANGELOG now — it records changes, not plans) | Plan Part C (pre-flight) |
| G12 "approx metric" clarity | ✅ Valid — Phase 6 metric wording now explicit (NOT CLIP; directional only, not a gate) | Plan Phase 6 item 1 |

**Result:** 12/12 validated; 10 plan-doc corrections applied, 2 live framework files updated (`CONTRIBUTING.md`, `skills/ui-style-stack/skill.md`); `framework-verify.sh` re-run → **PASS**. No commit performed.
