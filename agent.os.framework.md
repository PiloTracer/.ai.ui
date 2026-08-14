# Agent OS Framework — source marker

This file marks the repository root as an **OS framework source repo** — here: the **UI Design OS** framework (self-hosted `.ai.ui`). The shared filename is the cross-framework convention, so generic tooling can detect any OS framework source repo uniformly.

- **Detection:** `ui-session` treats a repo as framework source when this file exists at the repo root (fallback heuristic: `COHABITATION.md` + `skills/ui-session/skill.md` + `templates/bootstrap.sh`). Absence ⇒ consumer/adopter project.
- **Never modify:** this file is a protected surface (`standards/PROTECTED_SURFACES.json`, `.cursorrules` §Protected Files). Do not edit, rename, or delete it.
- **Never deployed:** `ui-deploy-files` explicitly excludes it; `ui-deploy-basic` never writes root files; it must never appear in a consumer project.
