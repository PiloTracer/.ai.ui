# `.ai.ui` (UI Design OS) — upgrade directions for the deploy skills

**Status:** Implemented 2026-08-19 (steps 1–6 + gap fixes) · **Repo:** `/mnt/work/Projects/.ai.ui` (shipped in v0.6.1)

Goal: make the deploy skills produce targets whose `.cursorrules` discover all six sisters under both namings — same as the current framework. `.ai.ui` is one of the two siblings (with cto) that already ships a Frameworks registry — but only in its template, legacy-only.

## Current state (measured 2026-08-19)

- `scripts/ui-deploy-basic.sh` (287 L): thin bootstrap; substitutes `AI_UI_SOURCE=REPLACE_BASICUI_SOURCE` (`:144`); its many `.ai.ui` mentions are about **its own source prefix**, not sisters; delegates verification to `cursorrules-verify.sh`.
- `scripts/cursorrules-verify.sh` (227 L): resolves `*source via <VAR>*` cells (`:181-191`); **auto-discovery is legacy-only** — checks only `${parent}/.ai`, `.ai.biz`, `.ai.soc` (`:153`); sister-pinning self-tests exist (`framework-verify.sh:564-587`).
- `.cursorrules`: **no registry** (natural insertion point: after the `**Free-text entry point:**` paragraph, `:58`).
- `templates/cursorrules.ui.template` `### Frameworks registry` at `:91-100` — **4 rows**: self (`.ai.ui` = *this directory*), `.ai` (Agent OS, `REPLACE:AGENT_OS_PATH`), `.ai.biz`, `.ai.soc`; resolution list at `:102+` (legacy-only: `${parent}/.ai`, `.ai.biz`, `.ai.soc`).
- `scripts/framework-verify.sh` (633 L): modern bits (sister-pinning proofs, source-cell resolution, framework-root self-audit).

## Steps

### 1. Copy the discovery lib
```bash
cp /mnt/work/Projects/pilo.ai.logicbison/scripts/sister-discovery.sh scripts/sister-discovery.sh
```

### 2. `.cursorrules` — add the Frameworks registry (Layer 1, required)
Insert after the `**Free-text entry point:** …` paragraph (line 58):

```markdown
### Frameworks registry (cross-framework discovery)

Sister frameworks are siblings on disk; `.ai.<fw>` (legacy) / `pilo.ai.<fw>.logicbison` (family) naming — see path resolution below. `.ai.ui` is this framework (self-hosted).

| Framework | Director | Path | Bootstrap artifact |
|-----------|----------|------|--------------------|
| `.ai.ui` (UI Design OS) | `@ui-director` | *this directory* | `skills/README.md` |
| `.ai` (Agent OS) | `@ai-director` | `../.ai` | `../.ai/skills/README.md` |
| `.ai.biz` (Business OS) | `@biz-director` | `../.ai.biz` | `../.ai.biz/skills/README.md` |
| `.ai.cto` (CTO Professor OS) | `@cto-director` | `../.ai.cto` | `../.ai.cto/skills/README.md` |
| `.ai.flutter` (Flutter Agent OS) | `@flutter-director` | `../.ai.flutter` | `../.ai.flutter/skills/README.md` |
| `.ai.mlt` (MLT Agent OS) | `@mlt-director` | `../.ai.mlt` | `../.ai.mlt/skills/README.md` |
| `.ai.soc` (Social OS) | `@soc-director` | `../.ai.soc` | `../.ai.soc/skills/README.md` |

**Path resolution:** (1) use a filled path cell; empty → fall through. (2) Auto-discover: parent = `S/..` with S = this repo (self-hosted) or `$AI_UI_SOURCE` (thin); sister = `<S basename with <fw> inserted before its last .segment>` (e.g. `pilo.ai.ui.logicbison` for a `pilo.ai.logicbison` source; `.ai`-prefixed sources resolve `.ai.<fw>` directly), else legacy `.ai.<fw>`; missing = "not installed". (3) Before routing, verify the framework dir + its `skills/README.md` exist; if absent, route with `[degraded: <framework> not installed]` — never route into the void. If your source dir name breaks discovery, fill the path cells manually.
```

### 3. Template registry — extend to seven rows + family-aware resolution (required for deploy parity)
In `templates/cursorrules.ui.template` (`:91-100`), after the `.ai.soc` row add (keep its `REPLACE:* (default: \`…\`)` cell style):
```markdown
| `.ai.cto` (CTO Professor OS) | `@cto-director` | REPLACE:AI_CTO_PATH (default: `../.ai.cto`) | `.ai.cto/skills/README.md` |
| `.ai.flutter` (Flutter Agent OS) | `@flutter-director` | REPLACE:AI_FLUTTER_PATH (default: `../.ai.flutter`) | `.ai.flutter/skills/README.md` |
| `.ai.mlt` (MLT Agent OS) | `@mlt-director` | REPLACE:AI_MLT_PATH (default: `../.ai.mlt`) | `.ai.mlt/skills/README.md` |
```
In the resolution list (`:102+`), replace the legacy-only discovery steps with: check family naming first (`<source basename with <fw> inserted before its last .segment>`, e.g. `pilo.ai.ui.logicbison`) then legacy `.ai.<fw>`, for the six slots.

### 4. `cursorrules-verify.sh` — extend the auto-discovery check (`:153`) to the six slots + family naming
Mirror `pilo.ai.logicbison/scripts/cursorrules-verify.sh`: source the lib; loop `$FRAMEWORK_SLOTS`; for each, resolve via `find_sister_dir` (family then legacy) instead of the hardcoded three-name check.

### 5. `ui-deploy-basic.sh` — wire the six-slot fill (Layer 2)
In the substitution step (after `AI_UI_SOURCE` is baked, `:144`), mirror `pilo.ai.logicbison/scripts/deploy-basic.sh` step 2: source the lib; loop `$FRAMEWORK_SLOTS`; `find_sister_dir "<source-root>" "$fw" "$(dirname "<source-root>")"`; fill the `REPLACE:AI_<FW>_PATH` cells → `<abs> (discovered at deploy time)`; else print checked candidates. (The template already carries the cells.)

### 6. Verify
```bash
source scripts/sister-discovery.sh
sister_names ui "$PWD"     # → .ai.ui
for s in biz cto flutter mlt soc ui; do test -d "../.ai.$s/skills/README.md" && echo "$s ok"; done
bash scripts/ui-deploy-basic.sh /tmp/smoke-ui      # inspect /tmp/smoke-ui/.cursorrules: AI_UI_SOURCE + sister cells
bash scripts/cursorrules-verify.sh /tmp/smoke-ui
bash scripts/framework-verify.sh                   # incl. sister-pinning self-tests
```

## Gaps — closed in this pass

- **Graceful degradation aligned**: template now routes with `[degraded: <framework> not installed]` instead of the one-line `framework not installed here`; the verifier reports uninstalled sisters as degraded (note/warn) instead of hard-failing on static registry cells.
- Auto-discovery is **family-aware** (`scripts/sister-discovery.sh` vendored; six slots loop in `cursorrules-verify.sh`, deploy-time fill in `ui-deploy-basic.sh`).
- `.cursorrules` ships the Layer-1 registry.
- Stale skill reference fixed: `skills/ui-copy/skill.md` now points at `@biz-writing` / `@biz-content` (`.ai.biz` ships `biz-content`/`biz-writing`).

## Gaps — resolved by design (owner decision 2026-08-19)

- **`.ai` (Agent OS) row stays `../.ai`, legacy-only — by design.** A child framework does **not** need to know how to contact the parent orchestrator: orchestration is top-down (the parent / `x-director` discovers and routes to children, not vice versa). No `pilo.ai.logicbison` fallback machinery in the child. A missing parent is a degraded-warn, never a failure; the cell is filled manually or by `verify --fix` only when a legacy `../.ai` is actually co-installed.
- **`@x-director` is referenced but not shipped** by `.ai.ui` — correct as-is: it lives in the parent orchestrator (`pilo.ai.logicbison`). Cross-framework routing delegates up when the parent is installed; otherwise the routing preflight degrades (`[degraded: framework not installed]`) instead of routing into the void. The child stays self-sufficient for its own six sisters.

## Checklist
- [x] `scripts/sister-discovery.sh` copied
- [x] `.cursorrules` registry + resolution (Layer 1)
- [x] Template registry extended (7 rows) + resolution family-aware
- [x] `cursorrules-verify.sh` six-slot auto-discovery
- [x] `ui-deploy-basic.sh` six-slot fill
- [x] Verify commands pass (incl. framework-verify sister-pinning self-tests)
- [x] Nothing committed/staged

## Next action
None — implemented. The two former follow-ups (vendor `x-director`; re-point the `.ai` row) were resolved as by-design non-goals (see "Gaps — resolved by design").
