#!/usr/bin/env bash
# ui-session.sh — .work.ui-scoped session carrier: status / commit / close / push.
#
# SCOPE INVARIANT: every git write op touches ONLY <repo-root>/.work.ui/.
#   - commit: git add -A -- .work.ui (includes untracked files AND dirs) + git commit
#   - close:  mark the session closed in .work.ui/context/HANDOFF_UI.md
#   - push:   git push of the current branch (only meaningful after commit)
#   - status: read-only report (default)
#
# Any combination of commit / close / push is accepted, in any order; the script
# normalizes to dependency order: close → commit → push.
#
# Hard guard: `git add` is always restricted to .work.ui/, and a pre-commit check
# refuses to proceed if any already-staged path lies outside .work.ui/.
#
# Usage:
#   bash scripts/ui-session.sh status
#   bash scripts/ui-session.sh close
#   bash scripts/ui-session.sh commit [-m "message"]
#   bash scripts/ui-session.sh push
#   bash scripts/ui-session.sh close commit push      # any order / combination
#   bash scripts/ui-session.sh --self-test            # tmp-repo behavioral test
set -euo pipefail

# ── Self-test (behavioral, tmp repo, no network) ───────────────────────────
if [[ "${1:-}" == "--self-test" ]]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  git -C "$T" init -q
  git -C "$T" config user.email selftest@local
  git -C "$T" config user.name selftest
  mkdir -p "$T/.work.ui/context" "$T/.work.ui/plans"
  printf '**Open:** open\n**Updated:** -\n**Closed:** -\n' > "$T/.work.ui/context/HANDOFF_UI.md"
  printf '# x\n' > "$T/.work.ui/plans/NEXT_UI.md"
  printf 'untracked-note\n' > "$T/.work.ui/untracked.md"
  printf 'app code\n' > "$T/app.py"
  SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"

  # 1. close + commit in one call (order-independent), untracked file included.
  ( cd "$T" && bash "$SCRIPT" close commit -m "selftest close" ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: close commit"; exit 1; }
  STAGED="$(git -C "$T" show --name-only --format= HEAD | grep -v '^$' || true)"
  for p in .work.ui/context/HANDOFF_UI.md .work.ui/plans/NEXT_UI.md .work.ui/untracked.md; do
    echo "$STAGED" | grep -qx "$p" || { echo "SELFTEST FAIL: '$p' missing from commit"; exit 1; }
  done
  echo "$STAGED" | grep -qx "app.py" && { echo "SELFTEST FAIL: committed path outside .work.ui/"; exit 1; }
  grep -qF '**Open:** closed' "$T/.work.ui/context/HANDOFF_UI.md" \
    || { echo "SELFTEST FAIL: close did not mark session closed"; exit 1; }

  # 2. pre-existing staged path outside .work.ui must block commit.
  printf 'other\n' > "$T/outside.txt"
  git -C "$T" add outside.txt
  if ( cd "$T" && bash "$SCRIPT" commit -m "must fail" ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: commit allowed staged path outside .work.ui/"; exit 1
  fi
  git -C "$T" reset -q

  # 3. nothing-to-commit is a clean no-op.
  ( cd "$T" && bash "$SCRIPT" commit -m "noop" ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: empty commit should be a clean no-op"; exit 1; }

  # 4. push against a bare remote.
  git -C "$T" branch -M main
  git -C "$T" remote add origin "$T-remote.git"
  git init --bare -q "$T-remote.git"
  git -C "$T" config push.default current   # no upstream yet — push must still succeed
  ( cd "$T" && bash "$SCRIPT" push ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: push to bare remote"; exit 1; }
  git -C "$T-remote.git" rev-parse --verify main >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: remote main missing after push"; exit 1; }

  # 5. push scope guard: a commit touching a path outside .work.ui/ must block push.
  git -C "$T" branch -M main
  git -C "$T" checkout -q -b mixed main
  printf 'app code\n' > "$T/app.py"
  git -C "$T" add app.py && git -C "$T" commit -q -m "app change"
  if ( cd "$T" && bash "$SCRIPT" push ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: push allowed commits touching paths outside .work.ui/"; exit 1
  fi
  git -C "$T" checkout -q main

  echo "ok: ui-session self-test (scope guard, untracked inclusion, close, combination, push)"
  exit 0
fi

# ── Resolve repo root (cwd anywhere inside the target repo) ────────────────
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "ui-session: not inside a git repo — run from the target repo (or a subdir of it)" >&2
  exit 1
fi
WORK_UI="${REPO_ROOT}/.work.ui"
HANDOFF_UI="${WORK_UI}/context/HANDOFF_UI.md"

# ── Parse verbs (order-independent; normalize close → commit → push) ───────
DO_CLOSE=0; DO_COMMIT=0; DO_PUSH=0; DO_STATUS=0; MSG=""
i=0
ARGS=("$@")
while [[ $i -lt ${#ARGS[@]} ]]; do
  a="${ARGS[$i]}"
  case "$a" in
    close)   DO_CLOSE=1 ;;
    commit)  DO_COMMIT=1 ;;
    push)    DO_PUSH=1 ;;
    status)  DO_STATUS=1 ;;
    -m)
      DO_COMMIT=1
      i=$((i + 1))
      [[ $i -lt ${#ARGS[@]} ]] && MSG="${ARGS[$i]}"
      ;;
    -m*)     DO_COMMIT=1; MSG="${a#-m}" ;;
    *)
      echo "ui-session: unknown verb '${a}' — use status | close | commit [-m msg] | push (any combination)" >&2
      exit 1
      ;;
  esac
  i=$((i + 1))
done
[[ -z "$MSG" ]] && MSG="ui-session: .work.ui update"
if [[ $DO_CLOSE -eq 0 && $DO_COMMIT -eq 0 && $DO_PUSH -eq 0 ]]; then
  DO_STATUS=1
fi

# ── status ─────────────────────────────────────────────────────────────────
if [[ $DO_STATUS -eq 1 ]]; then
  echo "ui-session status — repo: ${REPO_ROOT}"
  if [[ ! -d "$WORK_UI" ]]; then
    echo "  .work.ui/: MISSING (run @ui-bootstrap init first)"
  else
    echo "  .work.ui/: present"
    if [[ -f "$HANDOFF_UI" ]] && grep -qF '**Open:** closed' "$HANDOFF_UI"; then
      echo "  session: closed"
    else
      echo "  session: open or unknown"
    fi
    echo "  changes under .work.ui/:"
    git -C "$REPO_ROOT" status --porcelain -- .work.ui/ | sed 's/^/    /' || true
    echo "  last commit touching .work.ui/:"
    git -C "$REPO_ROOT" log -1 --format='    %h %s' -- .work.ui/ 2>/dev/null || echo "    (none)"
  fi
  exit 0
fi

# ── Pre-flight ─────────────────────────────────────────────────────────────
if [[ ! -d "$WORK_UI" ]]; then
  echo "ui-session: ${WORK_UI} missing — run @ui-bootstrap init first" >&2
  exit 1
fi
if [[ $DO_COMMIT -eq 1 ]]; then
  STAGED_OUTSIDE="$(git -C "$REPO_ROOT" diff --cached --name-only | grep -v '^\.work\.ui/' || true)"
  if [[ -n "$STAGED_OUTSIDE" ]]; then
    echo "ui-session: refuse — staged path(s) outside .work.ui/:" >&2
    echo "$STAGED_OUTSIDE" | sed 's/^/  /' >&2
    echo "unstage them or commit separately; ui-session only ever stages .work.ui/" >&2
    exit 1
  fi
fi

# ── close: mark session closed in HANDOFF_UI ───────────────────────────────
if [[ $DO_CLOSE -eq 1 ]]; then
  if [[ ! -f "$HANDOFF_UI" ]]; then
    echo "ui-session: ${HANDOFF_UI} missing — nothing to close" >&2
    exit 1
  fi
  TODAY="$(date +%Y-%m-%d)"
  sed -i -e 's/^\*\*Open:\*\* .*$/**Open:** closed/' \
         -e "s/^\*\*Updated:\*\* .*\$/**Updated:** ${TODAY}/" \
         -e "s/^\*\*Closed:\*\* .*\$/**Closed:** ${TODAY}/" "$HANDOFF_UI"
  echo "ui-session: closed — ${HANDOFF_UI} (Open: closed, Updated/Closed: ${TODAY})"
fi

# ── commit: stage .work.ui/ (incl. untracked) + commit ─────────────────────
if [[ $DO_COMMIT -eq 1 ]]; then
  git -C "$REPO_ROOT" add -A -- .work.ui
  if ! git -C "$REPO_ROOT" diff --cached --quiet; then
    STAGED_OUTSIDE="$(git -C "$REPO_ROOT" diff --cached --name-only | grep -v '^\.work\.ui/' || true)"
    if [[ -n "$STAGED_OUTSIDE" ]]; then
      echo "ui-session: refuse — staged path(s) outside .work.ui/ after add:" >&2
      echo "$STAGED_OUTSIDE" | sed 's/^/  /' >&2
      git -C "$REPO_ROOT" reset -q -- .work.ui >/dev/null 2>&1 || true
      exit 1
    fi
    git -C "$REPO_ROOT" commit -q -m "$MSG"
    echo "ui-session: committed .work.ui/ changes — $(git -C "$REPO_ROOT" rev-parse --short HEAD) ($MSG)"
  else
    echo "ui-session: nothing to commit under .work.ui/"
  fi
fi

# ── push (scope-checked) ──────────────────────────────────────────────────
if [[ $DO_PUSH -eq 1 ]]; then
  BRANCH="$(git -C "$REPO_ROOT" branch --show-current)"
  if [[ -z "$BRANCH" ]]; then
    echo "ui-session: detached HEAD — push skipped" >&2
    exit 1
  fi
  # Scope check: refuse to push when the to-be-pushed commits contain any path
  # outside .work.ui/ (another tool's/human's commit would ride along).
  UPSTREAM="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [[ -n "$UPSTREAM" ]]; then
    RANGE="$(git -C "$REPO_ROOT" merge-base "$UPSTREAM" HEAD 2>/dev/null || true)..HEAD"
    OUTSIDE="$(git -C "$REPO_ROOT" diff --name-only "$RANGE" 2>/dev/null | grep -v '^\.work\.ui/' || true)"
  else
    # No upstream — cannot know remote state; at minimum the tip commit must be
    # .work.ui-only (covers the push.default=current case).
    OUTSIDE="$(git -C "$REPO_ROOT" show --name-only --format= HEAD 2>/dev/null | grep -v '^\.work\.ui/' | grep -v '^$' || true)"
  fi
  if [[ -n "$OUTSIDE" ]]; then
    echo "ui-session: refuse — commits to push touch paths outside .work.ui/:" >&2
    echo "$OUTSIDE" | sed 's/^/  /' >&2
    echo "ui-session only pushes .work.ui/-scoped history; use git push yourself for other work" >&2
    exit 1
  fi
  if git -C "$REPO_ROOT" push >/dev/null 2>&1; then
    echo "ui-session: pushed ${BRANCH}"
  else
    echo "ui-session: push failed for ${BRANCH} — set upstream (git push -u origin ${BRANCH}) and retry" >&2
    exit 1
  fi
fi

echo "ui-session: done"
