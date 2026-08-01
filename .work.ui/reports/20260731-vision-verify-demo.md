# Vision-verify demo report — Phase 1 (2026-07-31)

**Route:** `examples/` (framework repo has reference manifests, not runnable app routes)  
**Tier attempted:** Static catalog + policy verification (vision tier requires BYOK + §8.2 authorization)  
**Verdict:** **Partial — static artifacts verified; live vision assertions Unverified**

## What was verified (machine-checked)

| Check | Result |
|-------|--------|
| `ui-visual-verify` ships `vision - <route>` mode | ✅ `skills/ui-visual-verify/skill.md` |
| Assertion catalog grouped (layout, contrast, state, behavior) | ✅ `skills/ui-visual-verify/reference.md` |
| Opt-in §8.2 + never auto-launch browser | ✅ skill hard rules |
| `ui-component-build` self-revision loop documented | ✅ generate → render → assert → fix (max 2) |
| Midscene referenced in `web-research-2026.md` §3/§6 | ✅ MIT, BYOK |

## What was not run (honest gap)

| Item | Reason |
|------|--------|
| Live `aiAssert` against a rendered route | Requires operator BYOK multimodal keys + explicit §8.2 browser authorization; no `examples/` runnable server in framework repo |
| Screenshot artifact | Not captured — no authorized browser session in audit environment |

## Recommended operator proof (adopter repo)

1. Operator authorizes browser tool + scope (§8.2).
2. `@ui-visual-verify vision - <route>` using assertions from `reference.md`.
3. Record pass/fail per assertion + attach screenshot to `.work.ui/reports/`.

**Audit note:** Phase 1 **documentation and policy** are complete; **live vision demo** remains an adopter-environment step.
