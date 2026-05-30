# Demo — UI probe ledger

**Scope:** foundation · **Updated:** 2026-05-29 · **Iterations:** 1 · **Coverage:** 83% (target 85%)

> Worked example shipped with the framework so `scripts/readiness-verify.sh` runs on real data. Engine: `.ai.ui/skills/probe-protocol.md`.
> Set **confirmed/high** only with a cited source or a same-session owner answer; an inference is **partial/med** at best.
> Coverage = ( Σ weight×conf ) / Σ weight · conf high=1.0 med=0.5 low=0.0 · weight gate-blocking(★)=2 else=1.

## Coverage

| Dim | Topic | Status | Conf | Evidence / source | Iter |
|-----|-------|--------|------|-------------------|------|
| D1 ★ | Product UI intent & users | confirmed | high | doc 01 §intent (saas-product, B2B operators) | 1 |
| D6 ★ | Screen map & IA | confirmed | high | `20260529-04-screen-map.md` | 1 |
| D4 ★ | Design tokens | partial | med | doc 02 draft; tokens not yet linked to `REPLACE:UI_TOKENS_FILE` | 1 |

Status: `confirmed` | `partial` | `unknown` · Conf: `high` | `med` | `low` · ★ = gate-blocking.

## Open probes (carried to next iteration)

- D4: confirm token file path + dark-theme inset/elevated values → blocks `screen-spec-ready` certify gate

## Deferred (→ UNKNOWNS.md)

- (none)

## Iteration log

| Iter | Date | Coverage | Dimensions touched | Notes |
|------|------|----------|--------------------|-------|
| 1 | 2026-05-29 | 83% | D1, D6, D4 | initial assessment; D4 (tokens) still mid-probe |
