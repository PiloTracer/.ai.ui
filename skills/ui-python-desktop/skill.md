---
name: ui-python-desktop
description: >-
  Design, scaffold, and verify Python desktop UIs with FLET (Apache-2.0),
  PySide6 (LGPL-3.0), and PyQt6 (Riverbank — GPL/commercial, adopter's licensed
  choice) as equal first-class stacks. Use stack set, scaffold, component add,
  verify, status. The framework requires zero extra installations — it only
  generates code; running the app is a documented adopter-environment step.
---

# ui-python-desktop

**Output root (mandatory):** `{WORK_UI_ROOT}` = `<repo-root>/.work.ui/` — generated app skeleton goes to `REPLACE:UI_APP_ROOT` (application paths), spec/token docs to `.work.ui/`.

**Stack ownership:** desktop stack is recorded separately from the CSS style stack as `UI_DESKTOP_STACK` in `{HANDOFF_UI}` (`@ui-style-stack status` cross-reports it; it is not a CSS stack).

**Framework constraint (hard):** this skill is markdown + bash + **python3 stdlib only** (`py_compile`, `ast`). It must **never** require installing FLET/Qt/pip packages for the framework to function or generate code. Install commands for the generated app are user-environment runbook steps ([`docs/guides/python-desktop-runbook.md`](../../docs/guides/python-desktop-runbook.md)).

**Stacks (equal first-class):**

| Stack | License | Notes |
|-------|---------|-------|
| `flet` | Apache-2.0 ✓ | 150+ controls, Material/Cupertino, one codebase web/mobile/desktop; `pip install flet[all]` |
| `pyside6` | LGPL-3.0-only ✓ | Official Qt for Python; commercial + proprietary use without source disclosure (unmodified, dynamic linking); `pip install PySide6` |
| `pyqt` | GPL-3.0-only OR commercial ⚠ | Riverbank. **License note (not a gate):** free in development; for production or when protecting source, acquire Riverbank's commercial license or release under GPL. API-compatible with PySide6 (import-line swap). `pip install PyQt6` |

## Modes

| Mode | Action |
|------|--------|
| `stack set - flet \| pyside6 \| pyqt` | Record `UI_DESKTOP_STACK` in HANDOFF_UI; `pyqt` appends the license note (dev free; commercial license for production/protected source) to the operator record |
| `scaffold - <app-slug>` | Generate a runnable skeleton from tokens + approved screen SPEC (see protocol) |
| `component add - <name>` | Map a SPEC primitive to a FLET control / Qt widget (see `reference.md`), styled with tokens, no default chrome |
| `verify - <path>` | Static tier: `python3 -m py_compile` + `ast` parse + token-lint on `.py` (no raw hex) + UIS-06/07/08 rubric prompts |
| `status` | Report active desktop stack + catalog bindings |

## scaffold protocol

1. Require `screen-spec-ready` + a DTCG `tokens.json` (Phase 2) — or state the gate.
2. Generate `app.py` (+ `widgets/` for Qt) that: imports **only** the selected stack (`import flet as ft` / `from PySide6.QtWidgets import …` / `from PyQt6.QtWidgets import …`), consumes tokens (`ft.Theme` colors / Qt palette + QSS) — no raw hex.
3. `python3 -m py_compile` the skeleton (stdlib) — must pass **with no pip install**.
4. Token-lint the `.py` (no raw color literals).
5. Output the run command from the runbook (user environment).

## component add protocol

- Primitive map in [`reference.md`](reference.md): FLET controls (`ft.Button`, `ft.TextField`, `ft.DataTable`, `ft.NavigationRail`, `ft.AlertDialog`, …) / Qt widgets (`QPushButton`, `QLineEdit`, `QTableWidget`, `QListWidget`, `QDialog`, …).
- Style via tokens only; no platform default chrome (SURFACE-AND-CONTROL-CRAFT applies).
- `pyqt` components use the PySide6-compatible dialect; only the import line differs.

## verify protocol (static tier)

1. `python3 -m py_compile <files…>` and `ast.parse` — stdlib only.
2. `bash .ai.ui/scripts/token-lint.sh <app-root>` — `.py` included (no raw hex / `rgb(` / `hsl(`).
3. UIS rubric prompts: UIS-06 (agent-assisted), UIS-07 (craft ≥ refined), UIS-08 (all screens).
4. Visual verify is **user-environment**: run the app (`flet run app.py` / `python app.py`), screenshot, then (authorized) vision tier (§8.2). Never auto-launch a desktop app.

## Pairs with

- `@ui-design-foundation` (tokens) → `@ui-screen-spec` (SPECs) → this skill (scaffold/components) → `@ui-visual-verify` / `@ui-accessibility-audit` (gates)
- `@ui-design-system` — desktop primitives recorded in CATALOG when `UI_DESKTOP_STACK` is set
- `@ui-plan-verify audit` — readiness before `@ui-component-build complete`
