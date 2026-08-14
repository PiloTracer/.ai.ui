---
name: ui-concept-run
description: >-
  Run UIS-01 through UIS-10 concept prompts from .ai.ui/concepts/. Attach output
  to screen SPEC, NEXT_UI, or PR. Use list, run - UIS-NN, status.
---

# ui-concept-run

**Parallel:** Agent OS `@concept-run` for MOD-* — independent; both may be required.

## Modes

| Mode | Action |
|------|--------|
| `list` | UIS index + trigger table summary |
| `run - UIS-NN` | Execute `concepts/<folder>/prompt.md` for UIS-01…10 |
| `status` | Pending UIS rows in active NEXT_UI |

## Hard rules

- Follow evidence tags in prompt outputs
- **UIS-06 required** for agent-assisted UI before `@ui-component-build complete`
- **UIS-07 required** when craft tier ≥ refined (foundation 01) at milestone verify
- **UIS-08 required** for all screens before `@ui-component-build complete`
- **UIS-09 required** for analytical dashboard screens at milestone verify
- **UIS-10 required** for marketing-site / hybrid marketing shell at milestone verify
- Do not write into `.ai/concepts/`
- **Operator handoff:** close every response per [`SKILL_DEPENDENCIES.md` § Operator handoff contract](../SKILL_DEPENDENCIES.md#operator-handoff-contract) — terse output; `**Needs your approval:**` with `path:L<n>` cites; `**Needs your answer:**`; one `**Next step:**`; Form A when nothing is needed; omit empty sections.

Trigger table: [`.ai.ui/concepts/README.md`](../../concepts/README.md)
