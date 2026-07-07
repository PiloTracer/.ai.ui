#!/usr/bin/env bash
# Install Agent OS UI hooks into a git repository.
# Detects self-hosted vs fat-client layout automatically.
set -euo pipefail

AI_UI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Determine git root — use PWD when repo-root, else AI_UI_ROOT parent
if [ -d "${PWD}/.git" ]; then
  HOOK_DEST="${PWD}/.git/hooks"
elif [ -d "${AI_UI_ROOT}/../.git" ]; then
  HOOK_DEST="$(cd "${AI_UI_ROOT}/.." && pwd)/.git/hooks"
else
  echo "ERROR: no .git directory found" >&2
  exit 1
fi

# Determine source
if [ -d "${AI_UI_ROOT}/hooks" ]; then
  HOOK_SRC="${AI_UI_ROOT}/hooks"
elif [ -d "${AI_UI_ROOT}/.ai.ui/hooks" ]; then
  HOOK_SRC="${AI_UI_ROOT}/.ai.ui/hooks"
else
  echo "ERROR: hooks directory not found at ${AI_UI_ROOT}/hooks" >&2
  exit 1
fi

count=0
for hook in prepare-commit-msg commit-msg pre-commit post-commit; do
  src="${HOOK_SRC}/${hook}"
  if [ ! -f "$src" ]; then
    echo "  skip (missing): $src"
    continue
  fi
  # Always install (overwrite) — hooks are idempotent
  cp "$src" "${HOOK_DEST}/${hook}"
  chmod +x "${HOOK_DEST}/${hook}"
  count=$((count + 1))
  echo "  installed: ${HOOK_DEST}/${hook} (from ${src})"
done

echo "UI Design OS git hooks: ${count} installed into ${HOOK_DEST}"
