# UI Design OS — Improvement Plan (2026-07-07)

**Reference source:** `.ai` Agent OS v0.5.3 (commits c2a810d..cc25b3b, 2026-07-01 to 2026-07-06)

---

## Applied changes

### 1. Change-safety layer (NEW)

Added from reference's `[v0.4.4 / v0.5.3]` AIOS-1 change-safety and audit layers:

| Artifact | Source reference | Status |
|----------|-----------------|--------|
| `scripts/touch-scope-verify.sh` | `scripts/touch-scope-verify.sh` | ✅ Created |
| `scripts/blast-radius-check.sh` | `scripts/blast-radius-check.sh` | ✅ Created |
| `scripts/gate-verify.sh` | `scripts/gate-verify.sh` | ✅ Created |
| `.cursorrules` § Change safety | `.cursorrules` § Change safety | ✅ Updated |
| `templates/work.ui/touch-scope.template` | — | ✅ Created |

**Rationale:** The reference validated these gates through the v0.5.3 audit cycle. They prevent cross-area diffs, undeclared-scope edits, and empty-notes tasks from reaching commit.

### 2. Git hooks + hygiene (NEW)

Added from reference's `[v0.5.0 / v0.5.3]` Co-authored-by enforcement and structured commit messages:

| Artifact | Source reference | Status |
|----------|-----------------|--------|
| `hooks/prepare-commit-msg` | `hooks/prepare-commit-msg` | ✅ Created |
| `hooks/commit-msg` | `hooks/commit-msg` | ✅ Created |
| `hooks/pre-commit` | `hooks/pre-commit` | ✅ Created |
| `hooks/post-commit` | `hooks/post-commit` | ✅ Created |
| `scripts/install-git-hooks.sh` | `scripts/install-git-hooks.sh` | ✅ Created |
| `.cursorrules` § Git | `.cursorrules` § Git | ✅ Updated |

**Rationale:** Universal improvement — Co-authored-by enforcement prevents accidental AI attribution (verified by reference smoke-test). Structured commit refs enable cross-repo traceability.

### 3. Cursorrules optimization (REFINED)

Applied reference's token-optimization patterns without sacrificing clarity:

| Change | Source pattern | Status |
|--------|---------------|--------|
| Change-safety gate table with commands | § Change safety table | ✅ Added |
| Co-authored-by hard rule | § Git rules | ✅ Added |
| Commit message format rule | § Commit Message Format | ✅ Added |
| No-attribution wording | § No attribution | ✅ Refined |

**Rationale:** The reference's v0.5.0 cut 42% of tokens without losing enforcement. Same pattern applied here.

---

## Defects found & fixed during integration audit

| Defect | File | Fix |
|--------|------|-----|
| Writes to `.work/` (COHABITATION violation) | `hooks/post-commit` | Changed `.work/commit-ref-pending` → `.work.ui/commit-ref-pending` |
| Reads `.work/active-ref` (COHABITATION concern) | `hooks/prepare-commit-msg` | Removed `.work/active-ref` dependency (branch detection is sufficient) |
| touch-scope template missing | `templates/work.ui/touch-scope.template` | Created with JSON schema for `allowed_paths` + `allowed_patterns` |
| touch-scope-verify was a stub (always passed) | `scripts/touch-scope-verify.sh` | Implemented actual validation: checks changed files against scope file |
| gate-verify subshell pipe bug | `scripts/gate-verify.sh` | Rewrote to use pure awk (avoid IFS pipe subshell + header/separator parsing) |
| gate-verify parser didn't handle `\|` prefix | `scripts/gate-verify.sh` | awk-based field extraction correctly handles `\|field\|field\|` format |
| Deploy-repo archive overwrites without warning | `scripts/deploy-repo.sh` | Added coexistence safety scan (warns on `.cursorrules`/`.github` overwrite, detects sister framework dirs, prompts for confirmation) |
| pre-commit hook runs 2/4 gates | `hooks/pre-commit` | Added `gate-verify` to the change-safety check loop |
| New scripts untested | `scripts/framework-verify.sh` | Added self-tests for touch-scope-verify, blast-radius-check, gate-verify, install-git-hooks |
| Adopter templates lack change-safety section | `templates/cursorrules.ui.template` | Added change-safety gate table |
| Adopter snippet lacks change-safety section | `templates/cursorrules.ui.snippet.template` | Added change-safety gate table |
| blast-radius-check crashed on changes (unbound assoc-array key under `set -u`) | `scripts/blast-radius-check.sh` | Use `while read` + `${AREAS[$area]:-0}` to safely increment per area |
| blast-radius-check reported high risk but exited 0 | `scripts/blast-radius-check.sh` | Exit 1 when cross-area diff ≥3 areas (matches `.cursorrules` gate) |
| prepare-commit-msg used undefined `COMMIT_EDITMSG` for temp file | `hooks/prepare-commit-msg` | Use `$1.tmp` so the temp file is adjacent to the commit message |
| pre-commit hook reused failure status across checks | `hooks/pre-commit` | Reset `status` per iteration; capture and print script output on failure |
| pre-commit hook defaulted to warn-only despite gate spec | `hooks/pre-commit` | Default `WARN_ONLY=0` (block) with `WARN_ONLY=1` escape hatch |

---

## Deferred items (not applicable)

| Item | Reason |
|------|--------|
| `master-plan-verify.sh` | UI Design OS doesn't have master plans — not applicable |
| `install-opencode-config.sh` | No local `opencode.json` — intentionally delegated to `.ai` parent |
| `smoke-consumer.sh` | Only useful when releasing to consumer repos — add when CI release process is set up |
| `skill-functional-verify.py` | UI's skill set is structurally different (ui- prefix, no trimmed skills with reference.md) |

---

## Status

All 7 original audit issues fixed, plus 5 additional defects discovered during verification. All 4 change-safety scripts self-tested in `framework-verify.sh`. `bash scripts/framework-verify.sh` passes.

---

## Cross-validation notes

All changes are read-only on the reference `.ai` repo — the reference was analyzed but not modified. Each change is adapted to `.ai.ui`'s domain:
- Skill paths use `ui-` prefix and `.work.ui/` work tree
- Commit refs use `UIS-` prefix
- Verification scripts are standalone (no dependency on `.ai/` scripts)
