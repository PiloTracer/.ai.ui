# Integration License Standard — commercial-safe baseline

> Binding rules for which 3rd-party resources may be **used by, or bundled into**, UI Design OS standards, practices, and skills. Companion to [`resources/control-platforms.md`](../resources/control-platforms.md) (behavior platforms) and [`resources/web-research-2026.md`](../resources/web-research-2026.md) (research catalog + § License policy).

**Scope:** governs 3rd-party **source code, assets, and text incorporated into framework files** (`standards/`, `practices/`, `skills/`, `templates/`, `scripts/`, `resources/`). It does **not** govern libraries the framework's *generated code* depends on (e.g. FLET, PySide6, PyQt6) — those are installed and licensed by the adopter's project — nor does it restrict which UI libraries a skill may target.

---

## 1. License tiers

| Tier | What it means | Allowed licenses | Rules |
|------|---------------|------------------|-------|
| **Bundled / vendored** | Source, templates, or assets copied into framework files and shipped with it | **MIT, Apache-2.0, BSD, CC0, public domain** | Must permit commercial use + free distribution **without source disclosure**; keep attribution notices |
| **Dependency** | Referenced for installation/use in the adopter's project (never copied in) | Adds **MPL-2.0** (file-level copyleft) | MPL-2.0 only as **unmodified dependency** — never vendored; audit deps |
| **Reference / link-only** | Cited for principles, methods, or guidance | **© articles** (free-read; apply principles, never paste), **W3C TR / open standards**, **`§ account`** (free signup, revocable ToS — link only), **`SaaS`** (free tier exists; OSS baseline preferred) | No reproduction of copyrighted text into skills/standards |
| **Excluded** | Must not be used in §1–§6 implementable guidance | **CC-BY-NC, GPL/LGPL as baseline, paid books, required paid SaaS** | Documented under the catalog's exclusions only |

## 2. License tags (required on every URL in the research catalog)

Every external URL in `resources/web-research-2026.md` implementable sections (§1–§9) must be tagged with one of:

| Tag | Meaning |
|-----|---------|
| `MIT` · `Apache-2.0` · `BSD` · `CC0` | Permissive OSS — bundled-safe |
| `MPL-2.0` | Copyleft — dependency only, never vendored |
| `W3C` | Open standard / W3C TR — citable |
| `© link-only` | Copyrighted article — principles only, no paste |
| `§ account` | Free signup required; revocable ToS — link only |
| `SaaS` | Hosted product; OSS alternative listed first |
| `🌐 browser` | Launches/drives a live browser — **opt-in only** (browser policy §8.2) |
| `Unverified` · `docs-only` | Not fetched this session / JS-gated — re-verify (§8.1) before citing |

## 3. Enforcement

- `scripts/framework-verify.sh` runs a **license scan**: every numbered section (§1–§9) of `resources/web-research-2026.md` must declare a `**License:**` line; §1–§6 lines may contain only allowed tags; `CC-BY-NC` / `GPL` / `LGPL` / `paid` / `commercial` markers are rejected outside the §7 exclusions.
- Any resource failing the tier rules moves to §7 (exclusions) with the reason.
- Re-verify URL + license before citing (§8.1 of the catalog).

## 4. Decision shortcut

```text
Can I copy source/assets into the framework?  → MIT / Apache-2.0 / BSD / CC0 only
Can I instruct adopters to install/use it?   → + MPL-2.0 (unmodified dep)
Can I cite it for principles?                → © link-only / W3C / SaaS(free tier) / § account
No to all three?                             → §7 exclusions — do not use
```
