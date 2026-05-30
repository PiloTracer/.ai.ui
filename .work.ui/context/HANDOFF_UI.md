# HANDOFF_UI — UI design session boundary

> **Demo skeleton** in the UI Design OS framework repo. In an adopter repo, `ui-*` skills update this file; **`@session-control`** (Agent OS) owns session open/close and may cross-link § UI layer in `.work/context/HANDOFF.md`.

## Session status

**Open:** -

**Updated:** 2026-05-29

**Closed:** 2026-05-29 (framework-development session)

**UI layer state:** **Framework development.** This `.work.ui/` is the demo/dogfood skeleton; it now ships two **worked foundation examples** (`plans/foundation/20260529-04-screen-map.md`, `plans/foundation/PROBE_LEDGER.md`) so the verifiers run on real data — docs 01–03 remain skeleton (not a certified foundation). This session changed the **`.ai.ui` framework itself**, not a product UI.

**This session ported the `.ai` improvements into `.ai.ui` (domain-adapted, lean house style):**

1. **Probe** — new `skills/probe-protocol.md` (shared engine) + `probe` mode on `ui-design-foundation` (dims D1–D8 → `screen-spec-ready`) and `ui-component-build` (dims B1–B5 → `ui-implementation-ready`); `templates/work.ui/plans/foundation/PROBE_LEDGER.md.template`.
2. **Free-text intake** — `@ui-screen-spec intake - <sentence>` (CLASSIFY local/cross-cutting/brownfield/underspecified → ROUTE → RECORD to `NEXT_UI § Intake queue`, `; force=<class>` override); free-text `create` derives a slug.
3. **Verifiers** — `framework-verify.sh` rewritten to derive skill count, cross-check registration, guard prose-count drift, assert the intake contract, and **self-test** the new scripts; new `scripts/readiness-verify.sh`, `scripts/traceability-verify.sh` (screen→milestone), `scripts/release.sh`.
4. **Guidance** — fixed `ui-process-router` bucket drift (reference.md is now single source + no-match fallback); added `probe`/`screen-request` buckets; surfaced probe+intake in `START_HERE`, `SKILL_DEPENDENCIES`, `CONTRIBUTING`, `CHANGELOG [Unreleased]`.

**Verification (all green):** `bash scripts/framework-verify.sh` PASS (**12** skills derived & registered; 4 verifier self-tests pass; markdown link-scan clean); `readiness-verify` + `traceability-verify` no-op exit 0 (no live ledger/screen-map). All scripts pass `bash -n`. CI mirrors these (`.github/workflows/framework-verify.yml`).

**Follow-up session (2026-05-29, continued) — owner-action backlog cleared:** added `@ui-plan-verify` (read-only audit, registry now 12); CI workflow; wired `ui-component-build complete` → `@ui-plan-verify audit`; probe `- status` / `- until ready` sub-modes in Modes tables; command-vocabulary table; `ui-screen-spec/reference.md`; seeded `## Intake queue` in NEXT_UI (template + demo); markdown link-scan in `framework-verify` (fixed 2 pre-existing broken links in `resources/README.md`); `docs/guides/probe-and-intake.md`. Decision #1 resolved: **keep** `ui-component-build probe`.

**State of tree:** **`v0.5.0` released** (commit `22ad2ed`, tagged, pushed 2026-05-29). Post-release follow-up (demo worked examples + lean/usability audit) sits under CHANGELOG `[Unreleased]`.

**Post-release audit (2026-05-29):**
- **Verifiers now live:** `readiness-verify` validates the seeded `PROBE_LEDGER.md` (honest, 83%); `traceability-verify` validates the seeded screen-map (2/2 scheduled). No longer no-op.
- **Lean:** 119 tracked files / 524K, 0 tracked images — example PNGs, `tmp/`, `credentials/token` are gitignored & untracked; root `context|decisions|design-system|screens|plans` are tiny pointer stubs (intentional).
- **Usable:** adopter install simulated from a clean `git archive` — `bootstrap.sh` creates `.work.ui/` + `.cursorrules` + `DOCS_UI_STACK.md`; Intake queue propagates. README 60-second-start commands all map to real skill modes.

**Recommended pick-up:** `.work.ui/plans/NEXT_UI.md`

**Lost or new?** Read `.ai.ui/START_HERE.md`

---

## UI readiness

| State | Value | Date |
|-------|-------|------|
| ui-foundation-complete | no | |
| screen-spec-ready | no | |
| ui-implementation-ready | no | |

## Active UI milestone

- **Milestone:** (none)
- **NEXT_UI:** [.work.ui/plans/NEXT_UI.md](../plans/NEXT_UI.md)

---

## Fresh start — first actions (continue framework development)

1. Read **this file** and `.work.ui/plans/NEXT_UI.md` (§ Recommended next).
2. Re-run the gate before touching anything: **`bash scripts/framework-verify.sh`** (must PASS; includes the verifier self-tests).
3. Pick up an open decision/follow-up below (see **Open owner actions**).
4. When changing a skill: update `skills/SKILL_DEPENDENCIES.md` + `skills/README.md`, then re-run `framework-verify.sh`.
5. To ship a version: finalize `CHANGELOG.md [Unreleased]` → `## [x.y.z]`, then **`bash scripts/release.sh x.y.z`** (gates the tag).

*(If instead working on a real product UI in an adopter repo: `@session-control start` from `.ai/`, then `@ui-design-foundation greenfield`.)*

### Conditional reads

| If the task touches… | Read first |
|----------------------|------------|
| Tokens / theme | `.work.ui/plans/foundation/*-02-design-tokens.md` |
| Screen inventory | `.work.ui/plans/foundation/*-04-screen-map.md` |
| Implementing UI | Approved `.work.ui/screens/<slug>/*-SCREEN-SPEC.md` |
| Domain API behaviour | `.work/features/<slug>/*-SPEC.md` (Agent OS — link only) |

---

## Open owner actions (UI) — pending gaps, improvements, fixes

Backlog 1 + 3–10 cleared in the follow-up session; only the commit (#2) remains (held for explicit owner request per git rules). `framework-verify` is green.

| # | Type | Action | Status |
|---|------|--------|--------|
| 1 | decision | Keep the second probe target (`ui-component-build probe`) or reduce to foundation-only? | **Resolved — KEEP.** Roadmap completeness (B1 screen→milestone coverage, B2 primitive ordering) is a distinct gate from foundation understanding, and it now anchors the `ui-component-build complete` audit; low cost, reversible. |
| 2 | commit | Commit the session work (suggested: `feat: probe + intake + verifier hardening + plan-verify/CI for UI Design OS`). | **Pending** — held for explicit owner request (no auto-commit). |
| 3 | gap | No CI workflow. | **Done** — `.github/workflows/framework-verify.yml` (push/PR/tag). |
| 4 | gap | Verifiers not wired to a UI boundary. | **Done** — `ui-component-build complete` → `@ui-plan-verify audit`; documented in `COHABITATION.md`. |
| 5 | gap | Probe coverage not surfaced by an audit skill. | **Done** — new `@ui-plan-verify` (registry 12). |
| 6 | improvement | Probe sub-modes not in skill tables. | **Done** — `probe - status` / `- until ready` in both Modes tables. |
| 7 | improvement | No command-vocabulary table. | **Done** — `skills/SKILL_DEPENDENCIES.md` § Command vocabulary. |
| 8 | improvement | `ui-screen-spec` has no `reference.md`. | **Done** — added with good/wrong prompt examples + slug derivation. |
| 9 | optional | Probe tutorial doc. | **Done** — `docs/guides/probe-and-intake.md`. |
| 10 | optional | Markdown link-scan in `framework-verify.sh`. | **Done** — added; fixed 2 pre-existing broken links in `resources/README.md`. |

### Caveats on this session's work (truth-first)

- **`traceability-verify.sh` is the weakest-fit port** — `.ai.ui` had no FR→task convention, so it checks screen→milestone against the screen-map template's two tables. It only fires once a real `*-04-screen-map.md` exists; the demo has none, so it currently no-ops.
- **Negative/destructive tests ran on `/tmp` fixtures**, not in-place on `.ai.ui`, because the shell sandbox blocks writes outside the active workspace (`.ai`). The verifier **self-tests** inside `framework-verify.sh` do exercise the reject paths and pass.
- **`.ai` was deliberately left untouched** this session per owner instruction.

---

## What this cycle produced (UI)

| Date | Session | Artifacts |
|------|---------|-----------|
| 2026-05-23 | bootstrap | `.work.ui/` skeleton |
| 2026-05-29 | framework: probe + intake + verifiers | `skills/probe-protocol.md`, `templates/work.ui/plans/foundation/PROBE_LEDGER.md.template`, `scripts/{readiness-verify,traceability-verify,release}.sh`; edited `framework-verify.sh`, `ui-design-foundation`, `ui-component-build`, `ui-screen-spec`, `ui-process-router` (+reference), `SKILL_DEPENDENCIES.md`, `START_HERE.md`, `README` count prose, `CONTRIBUTING.md`, `CHANGELOG.md` |
| 2026-05-29 | framework: backlog clear (plan-verify, CI, link-scan) | `skills/ui-plan-verify/skill.md`, `.github/workflows/framework-verify.yml`, `skills/ui-screen-spec/reference.md`, `docs/guides/probe-and-intake.md`; edited `framework-verify.sh` (link-scan), `ui-component-build` (complete→audit), `COHABITATION.md`, `SKILL_DEPENDENCIES.md` (vocab + plan-verify), `ui-design-foundation`/`ui-component-build` (probe sub-modes), `ui-process-router/reference.md`, `START_HERE.md`, `README` (12), `skills/README.md`, NEXT_UI template+demo (Intake queue), `resources/README.md` (link fix), `CHANGELOG.md` |

---

## Repository UI state

- **Token file:** (set after foundation — `REPLACE:UI_TOKENS_FILE`)
- **Design system catalog:** `.work.ui/design-system/CATALOG.md`
- **ADR location:** `.work.ui/decisions/` (default) — or `.work/decisions/` per team choice

---

## Cross-link (Agent OS)

When `.work/` exists, keep **### UI layer** in `.work/context/HANDOFF.md` in sync on milestone complete:

- Active UI milestone, `screen-spec-ready`, last verify verdict
