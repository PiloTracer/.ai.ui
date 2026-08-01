# UI Design OS — great UI for web & mobile (AI-assisted teams)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Ship **accessible, on-brand, responsive** interfaces — without generic AI chrome. Skills + standards + `.work.ui/` memory for UI design workflows.

**Platform:** Developed and verified on **Linux** (bash, git, rsync). Shell scripts and docs assume a POSIX environment. macOS, Windows (WSL2), and other OSes work when you adapt paths, line endings, and local tooling in your consumer repo — run `bash scripts/framework-verify.sh` to confirm the baseline toolchain on your host.

**Customization:** UI Design OS is a starting point, not a fixed contract. You are already working with a coding agent — use the same workflow to tailor skills, standards, `.cursorrules`, and `.work.ui/` to your repository, stack, and preferences. Fork, trim, or extend the framework in your consumer project (or in this repo when self-hosting) as your process evolves; after substantive changes to shared scripts, re-run `bash scripts/framework-verify.sh` to confirm the baseline still holds.

**Works with:** Cursor, Claude Code, Codex, and any agent that reads project files. OpenCode and other host configs are owned by your primary Agent OS (`.ai/`) when co-installed — this framework does not ship a local `opencode.json`.

**60-second start** (app repo root):

```bash
# 1. Copy .ai.ui/ beside your app (or clone this repo)
bash .ai.ui/templates/bootstrap.sh create-cursorrules   # .work.ui/ + .cursorrules

# 2. In chat
@ui-project-approach - B2B SaaS dashboard with sidebar
@ui-style-stack set - tailwind
@ui-design-foundation greenfield
@ui-design-foundation certify screen-spec-ready
@ui-design-system init
@ui-screen-spec create - dashboard-home
@ui-component-build plan - S0
@ui-component-build plan - S1
```

Full playbook: [`examples/INDEX.md`](examples/INDEX.md)

**Lost?** → [`START_HERE.md`](START_HERE.md) · **Don't know which UI skill to run?** → `@ui-director - <describe what you want>` · `@x-director - <describe what you want>` (cross-framework)

---

## What this is / isn't

| UI Design OS | Agent OS (`.ai/`) |
|--------------|-------------------|
| Screen SPECs, tokens, visual/a11y quality | Master plan, API SPECs, backend implementation |
| `.work.ui/` | `.work/` |
| `ui-*` skills | `plan-*`, `code-*`, `session-control` |
| UIS-01…10 concepts | MOD-01…06 |

**One session owner:** `@session-control` (Agent OS). Details: [`COHABITATION.md`](COHABITATION.md).

---

## Core assets (lean by design)

| Asset | Role |
|-------|------|
| [`APPROACH.md`](APPROACH.md) | **Which archetype & skill chain** (marketing, SaaS, dashboard, mobile, design-system) |
| [`standards/20260523-SURFACE-AND-CONTROL-CRAFT.md`](standards/20260523-SURFACE-AND-CONTROL-CRAFT.md) | Surfaces, controls, example→SPEC binding |
| [`standards/20260523-UI-PATTERNS.md`](standards/20260523-UI-PATTERNS.md) | Checklists: forms, nav, data, mobile — **not** 12 separate skills |
| [`style-stacks/`](style-stacks/README.md) | Tailwind, CSS Modules, vanilla CSS, styled-components |
| [`examples/INDEX.md`](examples/INDEX.md) | Annotated screenshots + value matrix |
| [`resources/control-platforms.md`](resources/control-platforms.md) | OSS behavior platforms (MIT/Apache) |
| [`resources/web-research-2026.md`](resources/web-research-2026.md) | Curated external references + agent apply rules (license §, static verify, browser opt-in §8.2) |
| [`resources/README.md`](resources/README.md) | External gallery URLs + resource index |
| **18 `ui-*` skills** | Bootstrap → foundation → spec → build → verify (+ plan audit + deploy + copy + python-desktop) |

See [`APPROACH.md` §6](APPROACH.md#6-skills-we-explicitly-did-not-add) for skills we did not add (coverage via UI-PATTERNS).

**Skills (18):** [`skills/README.md`](skills/README.md) · **Operator:** [`START_HERE.md`](START_HERE.md) · **Playbook:** [`examples/INDEX.md`](examples/INDEX.md)

---

## Project memory

All skill **outputs** go to **`<repo-root>/.work.ui/`** (sibling to `.ai.ui/`), not inside `.ai.ui/`.

Demo skeleton in this repo: [`.work.ui/`](.work.ui/README.md)

---

## Extending

See [`APPROACH.md` §7](APPROACH.md#7-extending-this-framework).

---

## Docs

| Doc | |
|-----|--|
| [START_HERE.md](START_HERE.md) | Decision tree |
| [COHABITATION.md](COHABITATION.md) | With Agent OS |
| [docs/adoption/FROM_AGENT_OS.md](docs/adoption/FROM_AGENT_OS.md) | What we copied from `.ai` |

---

## License

MIT — [LICENSE](LICENSE)
