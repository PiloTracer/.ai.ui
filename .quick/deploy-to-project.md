# Deploy .ai.ui (UI Design OS) Into a Target Project

Two modes: **fat-client** (`deploy-files` — vendored `.ai.ui/` in target) and **thin-client** (`deploy-basic` — only `.cursorrules` + `.work.ui/` + `DOCS_UI_STACK.md`; skills load from `$AI_UI_SOURCE` at runtime).

**No local `opencode.json`.** Register UI skills via parent Agent OS (`.ai/opencode.json`) when co-installed.

## Thin-client — share one source across many repos

```bash
# From source:
bash /path/to/.ai.ui/scripts/deploy-basic.sh /path/to/target

# From target:
bash /path/to/.ai.ui/scripts/deploy-basic.sh .

# Read-only status:
bash /path/to/.ai.ui/scripts/deploy-basic.sh --status /path/to/target
```

```text
@deploy-basic update    # re-sync AI_UI_SOURCE + merge candidates
```

## Fat-client — full vendored .ai.ui (works offline)

```bash
bash /path/to/.ai.ui/scripts/deploy-files.sh /path/to/target          # no-overwrite (default)
bash /path/to/.ai.ui/scripts/deploy-files.sh /path/to/target --update # merge candidates
bash /path/to/.ai.ui/scripts/deploy-files.sh /path/to/target --force  # legacy overwrite
```

In-place from target repo root (creates `.ai.ui/`, `.work.ui/`, `.cursorrules`):

```bash
cd /path/to/target && bash /path/to/.ai.ui/scripts/deploy-files.sh .
```

## Full repo — with .git and .github

```text
@deploy-repo clone - /absolute/path/to/destination
@deploy-repo archive - /absolute/path/to/destination
```

## Next steps in target

```text
@ui-bootstrap init merge-cursorrules   # if .cursorrules not created by deploy-files
@ui-project-approach - <describe project>
@ui-design-foundation greenfield
```

Verify toolchain: `bash .ai.ui/scripts/framework-verify.sh` (from source repo).
