---
name: ui-process-router
description: >-
  Read-only router for UI Design OS questions. Maps to ui-* skills, UI standards,
  UIS concepts, or .work.ui/ paths. Does not replace Agent OS process-router.
---

# ui-process-router

**Hard rules:** No file writes. Link canonical sources; ≤3 sentences in answer.

- **Operator handoff:** close every response per [`SKILL_DEPENDENCIES.md` § Operator handoff contract](../SKILL_DEPENDENCIES.md#operator-handoff-contract) — terse output; `**Needs your approval:**` with `path:L<n>` cites; `**Needs your answer:**`; one `**Next step:**`; Form A when nothing is needed; omit empty sections.

## Modes

| User says | Mode |
|-----------|------|
| `@ui-process-router - <question>` | route |
| `@ui-process-router help` | help |

## Route protocol

1. Classify the question into one bucket. **The authoritative bucket set is the row list in [`reference.md`](reference.md)** — match against it directly (e.g. `approach`, `style`, `foundation`, `screen-spec`, `screen-request`, `build`, `verify`, `a11y`, `concept`, `session`, `learn`, …). Do **not** keep a second canonical copy of the bucket list here; add new buckets as rows in `reference.md`.
2. Output format — see [`PROCESS_ROUTER.md`](../../PROCESS_ROUTER.md).
3. If the question matches **no** bucket, say so and route to [`START_HERE.md`](../../START_HERE.md) §1 — never invent a skill or path.

**Escalate:** If question is about `@session-control`, `@code-implementation`, MOD prompts, or `.work/plans/` → redirect to `@process-router` (`.ai/`).
