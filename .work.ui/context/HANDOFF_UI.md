# HANDOFF_UI — UI design session boundary

> **Demo skeleton** in the UI Design OS framework repo. In an adopter repo, `ui-*` skills update this file; **`@session-control`** (Agent OS) owns session open/close and may cross-link § UI layer in `.work/context/HANDOFF.md`.

## Session status

**Open:** -

**Updated:** YYYY-MM-DD

**Closed:** -

**UI layer state:** Greenfield / foundation / spec / implementation — describe briefly.

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

## Fresh start — first actions (UI)

1. Run **`@session-control start`** (Agent OS) if `.ai/` is present.
2. Read **`.cursorrules`** UI block (`UI_DESIGN_OS_BEGIN`).
3. Read **this file** and `.work.ui/plans/NEXT_UI.md`.
4. If foundation missing: **`@ui-design-foundation greenfield`**.
5. End session with **`@session-control close`** (updates main HANDOFF + optional UI cross-link).

### Conditional reads

| If the task touches… | Read first |
|----------------------|------------|
| Tokens / theme | `.work.ui/plans/foundation/*-02-design-tokens.md` |
| Screen inventory | `.work.ui/plans/foundation/*-04-screen-map.md` |
| Implementing UI | Approved `.work.ui/screens/<slug>/*-SCREEN-SPEC.md` |
| Domain API behaviour | `.work/features/<slug>/*-SPEC.md` (Agent OS — link only) |

---

## Open owner actions (UI)

| # | Action | Blocks | Owner |
|---|--------|--------|-------|
| - | (none) | | |

---

## What this cycle produced (UI)

| Date | Session | Artifacts |
|------|---------|-----------|
| YYYY-MM-DD | bootstrap | `.work.ui/` skeleton |

---

## Repository UI state

- **Token file:** (set after foundation — `REPLACE:UI_TOKENS_FILE`)
- **Design system catalog:** `.work.ui/design-system/CATALOG.md`
- **ADR location:** `.work.ui/decisions/` (default) — or `.work/decisions/` per team choice

---

## Cross-link (Agent OS)

When `.work/` exists, keep **### UI layer** in `.work/context/HANDOFF.md` in sync on milestone complete:

- Active UI milestone, `screen-spec-ready`, last verify verdict
