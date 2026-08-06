# ui-process-router — operator guide

**Skill:** [`.ai.ui/skills/ui-process-router/skill.md`](skills/ui-process-router/skill.md) · **Routing table:** [`reference.md`](skills/ui-process-router/reference.md)

**Also in:** [`START_HERE.md`](START_HERE.md) §2 and §9

---

## What it is

Read-only signpost for **UI Design OS** questions. Routes to `ui-*` skills, UI standards, UIS concepts, or `.work.ui/` paths.

It does **not** replace `@process-router` (Agent OS). For backend, DB, master plans, or `@session-control`, use `.ai/PROCESS_ROUTER.md`.

> **Don't know which UI skill to run?** Use `@ui-director - <describe what you want>` and let it route for you. If the work spans `.ai` + `.ai.ui` + `.ai.biz`, use `@x-director - <describe what you want>`.

```text
UI question → @ui-process-router - <question> → "Run @ui-screen-spec create - …"
```

---

## How to invoke

```text
@ui-process-router - how do I create a screen SPEC?
@ui-process-router - which UIS prompt for contrast?
@ui-process-router - ready to build checkout UI?
@ui-process-router help
```

---

## When to use which router

| Situation | Router |
|-----------|--------|
| Tokens, screens, Storybook, a11y, design foundation | `@ui-process-router` |
| Free-text UI request / don't know the skill | `@ui-director - <describe what you want>` · `@x-director - <describe what you want>` (cross-framework) |
| Migrations, master plan, MOD concepts, session close | `@process-router` (`.ai/`) |
| `.work.ui`-scoped session commit / close / push | `@ui-session` (`.ai.ui/` — never stages outside `.work.ui/`) |
| "Where am I?" full repo | `@session-control status` + both HANDOFF files |

---

## UI readiness (quick reference)

See [`skills/SKILL_DEPENDENCIES.md`](skills/SKILL_DEPENDENCIES.md) for gates (`ui-foundation-complete` → `screen-spec-ready` → `ui-implementation-ready`).

---
