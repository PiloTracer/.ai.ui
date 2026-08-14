#!/usr/bin/env bash
# ui-session.sh — session carrier: start / status / context / add / commit / close / push
# (session-control parity, with a dual-scope model)
#
# SCOPE MODEL (auto-detected per repo):
#   - framework mode — the repo IS the UI Design OS source (repo root carries
#     COHABITATION.md + skills/ui-session/skill.md + templates/bootstrap.sh):
#     add/commit/push apply to ALL modified/added/new files in the repo.
#   - target mode — an adopter project repo (the framework lives in .ai.ui/):
#     every git write op touches ONLY <repo-root>/.work.ui/ (never app code,
#     .ai/, .ai.ui/, .work/, or .cursorrules).
#
# VERBS (any combination, order-independent; normalized start → close → add → commit → push):
#   - start:   mark the UI session open in .work.ui/context/HANDOFF_UI.md
#   - close:   mark the UI session closed in HANDOFF_UI.md
#   - add:     stage in-scope changes (incl. untracked files AND dirs), no commit
#   - commit:  add + git commit (default message carries a UIS-*/task ref when detectable)
#   - push:    git push of the current branch (target mode: .work.ui-only history enforced)
#   - status:  read-only compact report (default when no verb is given)
#   - context: read-only uncommitted-aware snapshot (counts + secrets flags; no writes)
#
# `scoped` limits add/commit staging to HANDOFF_UI.md + NEXT_UI.md (bookend files).
# `status` / `context` are read-only and standalone (cannot be combined with writes).
#
# Hard guards:
#   - target mode: `git add` restricted to .work.ui/ (or bookends when scoped);
#     pre/post-commit checks refuse staged paths outside .work.ui/;
#     push refuses when the to-be-pushed commits touch paths outside .work.ui/
#   - both modes: secrets scan refuses to stage/commit credential-shaped paths
#
# Usage:
#   bash scripts/ui-session.sh status
#   bash scripts/ui-session.sh context
#   bash scripts/ui-session.sh start [- goal text]
#   bash scripts/ui-session.sh close
#   bash scripts/ui-session.sh add [scoped]
#   bash scripts/ui-session.sh commit [-m "message"] [scoped]
#   bash scripts/ui-session.sh push
#   bash scripts/ui-session.sh close commit push      # any order / combination
#   bash scripts/ui-session.sh --self-test            # tmp-repo behavioral test
set -euo pipefail

# ── Self-test (behavioral, tmp repo, no network) ───────────────────────────
if [[ "${1:-}" == "--self-test" ]]; then
  T="$(mktemp -d)"
  trap 'rm -rf "$T" "$T-remote.git" 2>/dev/null; [ -n "${T2:-}" ] && rm -rf "$T2" 2>/dev/null; [ -n "${T3:-}" ] && rm -rf "$T3" "$T3-remote.git" 2>/dev/null; true' EXIT
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

  # 2. pre-existing staged path outside .work.ui must block commit (target mode).
  printf 'other\n' > "$T/outside.txt"
  git -C "$T" add outside.txt
  if ( cd "$T" && bash "$SCRIPT" commit -m "must fail" ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: commit allowed staged path outside .work.ui/"; exit 1
  fi
  git -C "$T" reset -q

  # 3. nothing-to-commit is a clean no-op.
  ( cd "$T" && bash "$SCRIPT" commit -m "noop" ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: empty commit should be a clean no-op"; exit 1; }

  # 4. push against a bare remote (target mode).
  git -C "$T" branch -M main
  git -C "$T" remote add origin "$T-remote.git"
  git init --bare -q "$T-remote.git"
  git -C "$T" config push.default current   # no upstream yet — push must still succeed
  ( cd "$T" && bash "$SCRIPT" push ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: push to bare remote"; exit 1; }
  git -C "$T-remote.git" rev-parse --verify main >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: remote main missing after push"; exit 1; }

  # 5. push scope guard: a commit touching a path outside .work.ui/ must block push (target mode).
  git -C "$T" branch -M main
  git -C "$T" checkout -q -b mixed main
  printf 'app code\n' > "$T/app.py"
  git -C "$T" add app.py && git -C "$T" commit -q -m "app change"
  if ( cd "$T" && bash "$SCRIPT" push ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: push allowed commits touching paths outside .work.ui/"; exit 1
  fi
  git -C "$T" checkout -q main

  # ── parity features (session-control) on a fresh target-mode repo ────────
  T2="$(mktemp -d)"
  git -C "$T2" init -q
  git -C "$T2" config user.email selftest@local
  git -C "$T2" config user.name selftest
  mkdir -p "$T2/.work.ui/context" "$T2/.work.ui/plans"
  printf '**Open:** -\n**Updated:** -\n**Closed:** -\n' > "$T2/.work.ui/context/HANDOFF_UI.md"
  printf '# next\n' > "$T2/.work.ui/plans/NEXT_UI.md"

  # 6. start marks the session open with goal + dates; Closed reset to '-'.
  ( cd "$T2" && bash "$SCRIPT" start - UIS-42 dashboard shell ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: start"; exit 1; }
  grep -qE '^\*\*Open:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2} - goal: UIS-42 dashboard shell$' \
    "$T2/.work.ui/context/HANDOFF_UI.md" \
    || { echo "SELFTEST FAIL: start did not write Open line with goal"; exit 1; }
  grep -qF '**Closed:** -' "$T2/.work.ui/context/HANDOFF_UI.md" \
    || { echo "SELFTEST FAIL: start did not reset Closed line"; exit 1; }

  # 7. add stages (incl. untracked) but never commits.
  printf 'screen spec\n' > "$T2/.work.ui/new-screen.md"
  BEFORE="$(git -C "$T2" rev-parse HEAD 2>/dev/null || echo none)"
  ( cd "$T2" && bash "$SCRIPT" add ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: add"; exit 1; }
  git -C "$T2" diff --cached --name-only | grep -qx '.work.ui/new-screen.md' \
    || { echo "SELFTEST FAIL: add did not stage untracked .work.ui file"; exit 1; }
  AFTER="$(git -C "$T2" rev-parse HEAD 2>/dev/null || echo none)"
  [[ "$BEFORE" == "$AFTER" ]] \
    || { echo "SELFTEST FAIL: add created a commit"; exit 1; }

  # 8. scoped commit stages bookend files only.
  printf 'scratch\n' > "$T2/.work.ui/scratch.md"
  ( cd "$T2" && bash "$SCRIPT" commit scoped ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: commit scoped"; exit 1; }
  SCOPED_PATHS="$(git -C "$T2" show --name-only --format= HEAD | grep -v '^$' || true)"
  echo "$SCOPED_PATHS" | grep -qx '.work.ui/context/HANDOFF_UI.md' \
    || { echo "SELFTEST FAIL: scoped commit missing HANDOFF_UI.md"; exit 1; }
  echo "$SCOPED_PATHS" | grep -qx '.work.ui/scratch.md' \
    && { echo "SELFTEST FAIL: scoped commit included non-bookend file"; exit 1; }
  echo "$SCOPED_PATHS" | grep -qx '.work.ui/new-screen.md' \
    && { echo "SELFTEST FAIL: scoped commit included previously staged file"; exit 1; }

  # 9. secrets scan: a credential-shaped path under .work.ui must block commit.
  printf 'secret\n' > "$T2/.work.ui/api.key"
  if ( cd "$T2" && bash "$SCRIPT" commit -m "must fail" ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: commit allowed secrets-pattern path"; exit 1
  fi
  git -C "$T2" diff --cached --name-only | grep -qx '.work.ui/api.key' \
    && { echo "SELFTEST FAIL: secrets path left staged after refusal"; exit 1; }
  rm "$T2/.work.ui/api.key"

  # 10. context is read-only (exit 0, HANDOFF_UI untouched).
  H_BEFORE="$(git -C "$T2" hash-object .work.ui/context/HANDOFF_UI.md)"
  ( cd "$T2" && bash "$SCRIPT" context ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: context"; exit 1; }
  H_AFTER="$(git -C "$T2" hash-object .work.ui/context/HANDOFF_UI.md)"
  [[ "$H_BEFORE" == "$H_AFTER" ]] \
    || { echo "SELFTEST FAIL: context modified HANDOFF_UI.md"; exit 1; }

  # 11. start + close in one call is contradictory and must fail.
  if ( cd "$T2" && bash "$SCRIPT" start close ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: start+close combination accepted"; exit 1
  fi

  # 12. default commit message carries the detected ref, else chore: fallback.
  ( cd "$T2" && bash "$SCRIPT" commit ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: default-message commit (ref)"; exit 1; }
  git -C "$T2" log -1 --format='%s' | grep -qE '^UIS-42: ' \
    || { echo "SELFTEST FAIL: default message did not use detected UIS ref"; exit 1; }

  # 12b. fallback: no ref in Open goal / branch / last subject → 'chore: ...'.
  sed -i 's/^\*\*Open:\*\* .*$/**Open:** open/' "$T2/.work.ui/context/HANDOFF_UI.md"
  printf 'more\n' >> "$T2/.work.ui/plans/NEXT_UI.md"
  git -C "$T2" add -A -- .work.ui && git -C "$T2" commit -q -m "docs: ref-free tip"
  printf 'even more\n' >> "$T2/.work.ui/plans/NEXT_UI.md"
  ( cd "$T2" && bash "$SCRIPT" commit ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: default-message commit (fallback)"; exit 1; }
  git -C "$T2" log -1 --format='%s' | grep -qE '^chore: ' \
    || { echo "SELFTEST FAIL: default message fallback is not 'chore: ...'"; exit 1; }

  # 12c. target mode is reported in status output.
  ST_T2="$( cd "$T2" && bash "$SCRIPT" status 2>/dev/null )"
  [[ "$ST_T2" == *'mode: target (.work.ui/ only)'* ]] \
    || { echo "SELFTEST FAIL: status did not report target mode"; exit 1; }

  # ── framework mode: the repo IS the UI Design OS source → whole-tree scope ─
  T3="$(mktemp -d)"
  git -C "$T3" init -q
  git -C "$T3" config user.email selftest@local
  git -C "$T3" config user.name selftest
  mkdir -p "$T3/skills/ui-session" "$T3/templates" "$T3/.work.ui/context" "$T3/.work.ui/plans" "$T3/src"
  echo x > "$T3/COHABITATION.md"
  echo x > "$T3/skills/ui-session/skill.md"
  echo x > "$T3/templates/bootstrap.sh"
  printf '**Open:** -\n**Updated:** -\n**Closed:** -\n' > "$T3/.work.ui/context/HANDOFF_UI.md"
  printf '# next\n' > "$T3/.work.ui/plans/NEXT_UI.md"

  # 13. framework-mode commit includes ALL modified/added/new files (not just .work.ui/).
  printf 'app code\n' > "$T3/app.py"
  printf 'component\n' > "$T3/src/widget.ts"
  printf 'note\n' > "$T3/.work.ui/note.md"
  ( cd "$T3" && bash "$SCRIPT" commit -m "framework batch" ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: framework-mode commit"; exit 1; }
  FW_PATHS="$(git -C "$T3" show --name-only --format= HEAD | grep -v '^$' || true)"
  for p in app.py src/widget.ts .work.ui/note.md; do
    echo "$FW_PATHS" | grep -qx "$p" \
      || { echo "SELFTEST FAIL: framework-mode commit missing '$p'"; exit 1; }
  done

  # 14. framework-mode status reports the whole tree + framework mode line.
  printf 'dirty\n' > "$T3/dirty.txt"
  ST_T3="$( cd "$T3" && bash "$SCRIPT" status 2>/dev/null )"
  [[ "$ST_T3" == *'mode: framework (whole repo)'* ]] \
    || { echo "SELFTEST FAIL: framework-mode status missing mode line"; exit 1; }
  [[ "$ST_T3" == *'dirty.txt'* ]] \
    || { echo "SELFTEST FAIL: framework-mode status did not list repo-wide change"; exit 1; }

  # 15. framework-mode secrets scan still refuses credential-shaped paths at repo root.
  printf 'secret\n' > "$T3/root.token"
  if ( cd "$T3" && bash "$SCRIPT" commit -m "must fail" ) >/dev/null 2>&1; then
    echo "SELFTEST FAIL: framework-mode commit allowed secrets-pattern path"; exit 1
  fi
  git -C "$T3" diff --cached --name-only | grep -qx 'root.token' \
    && { echo "SELFTEST FAIL: framework-mode secrets path left staged"; exit 1; }
  rm "$T3/root.token"

  # 16. framework-mode push does NOT apply the .work.ui-only history check.
  git -C "$T3" add -A && git -C "$T3" commit -q -m "app + ui mixed commit"
  git -C "$T3" branch -M main
  git init --bare -q "$T3-remote.git"
  git -C "$T3" remote add origin "$T3-remote.git"
  git -C "$T3" config push.default current
  ( cd "$T3" && bash "$SCRIPT" push ) >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: framework-mode push of mixed history"; exit 1; }
  git -C "$T3-remote.git" rev-parse --verify main >/dev/null 2>&1 \
    || { echo "SELFTEST FAIL: framework remote main missing after push"; exit 1; }

  echo "ok: ui-session self-test (scope guard, untracked inclusion, close, combination, push, start, add, scoped, secrets, context, ref message, framework whole-tree mode)"
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
NEXT_UI="${WORK_UI}/plans/NEXT_UI.md"

# ── Scope mode: framework source repo vs adopter target repo ───────────────
# Framework mode: this repo IS the UI Design OS source → whole-tree scope.
# Target mode:    an adopter project (framework under .ai.ui/) → .work.ui/ only.
if [[ -f "${REPO_ROOT}/COHABITATION.md" \
   && -f "${REPO_ROOT}/skills/ui-session/skill.md" \
   && -f "${REPO_ROOT}/templates/bootstrap.sh" ]]; then
  MODE="framework"
  MODE_DESC="framework (whole repo)"
else
  MODE="target"
  MODE_DESC="target (.work.ui/ only)"
fi

# ── Helpers ────────────────────────────────────────────────────────────────
# Credential-shaped paths (session-control C1 parity). Prints offending paths
# from stdin; .env.example/.env.sample/.env.template stay exempt.
secrets_scan() {
  grep -E '(^|/)credentials/|(^|/)\.env($|\.)|\.(pem|p12|key|pfx|p8|token|secret)$|id_rsa' \
    | grep -vE '(^|/)\.env\.(example|sample|template)$' || true
}

# Commit-subject ref detection (priority: HANDOFF_UI Open goal → branch → last
# commit subject). Framework git rule: '<REF>: description' when a ref is known,
# else 'type: description'.
detect_ref() {
  local ref=""
  if [[ -f "$HANDOFF_UI" ]]; then
    ref="$(sed -n 's/^\*\*Open:\*\* //p' "$HANDOFF_UI" | grep -oE '[A-Z][A-Z0-9]*-[0-9]+' | head -1 || true)"
  fi
  if [[ -z "$ref" ]]; then
    ref="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null | grep -oE '[A-Z][A-Z0-9]*-[0-9]+' | head -1 || true)"
  fi
  if [[ -z "$ref" ]]; then
    ref="$(git -C "$REPO_ROOT" log -1 --format='%s' 2>/dev/null | grep -oE '^[A-Z][A-Z0-9]*-[0-9]+' || true)"
  fi
  printf '%s' "$ref"
}

# Stage in-scope changes (default scope, incl. untracked files/dirs):
#   framework mode → whole repo (git add -A)
#   target mode    → .work.ui/ only
# scoped (both modes) → the two bookend files ONLY; any other staged path is
# unstaged first (left as a working-tree change, never lost), so the commit
# contains bookends only.
stage_scope() {
  if [[ $DO_SCOPED -eq 1 ]]; then
    local extra
    extra="$(git -C "$REPO_ROOT" diff --cached --name-only \
      | grep -vE '^\.work\.ui/(context/HANDOFF_UI\.md|plans/NEXT_UI\.md)$' || true)"
    if [[ -n "$extra" ]]; then
      echo "$extra" | xargs -r git -C "$REPO_ROOT" reset -q --
      echo "ui-session: scoped — unstaged non-bookend path(s) (kept as working-tree changes):"
      echo "$extra" | sed 's/^/  /'
    fi
    local paths=() p
    for p in .work.ui/context/HANDOFF_UI.md .work.ui/plans/NEXT_UI.md; do
      if [[ -f "${REPO_ROOT}/${p}" ]] || git -C "$REPO_ROOT" ls-files --error-unmatch "$p" >/dev/null 2>&1; then
        paths+=("$p")
      fi
    done
    [[ ${#paths[@]} -gt 0 ]] && git -C "$REPO_ROOT" add -A -- "${paths[@]}"
  elif [[ "$MODE" == "framework" ]]; then
    git -C "$REPO_ROOT" add -A
  else
    git -C "$REPO_ROOT" add -A -- .work.ui
  fi
}

# Guards on the staged set.
#   - target mode only: refuse staged paths outside .work.ui/
#   - both modes: refuse secrets-pattern paths (never leave them staged)
# $1 = "pre" (before our add — do not unstage) | "post" (after our add — roll back).
guard_staged() {
  local phase="$1" outside secrets
  if [[ "$MODE" == "target" ]]; then
    outside="$(git -C "$REPO_ROOT" diff --cached --name-only | grep -v '^\.work\.ui/' || true)"
    if [[ -n "$outside" ]]; then
      echo "ui-session: refuse — staged path(s) outside .work.ui/:" >&2
      echo "$outside" | sed 's/^/  /' >&2
      echo "unstage them or commit separately; target-mode ui-session only ever stages .work.ui/" >&2
      [[ "$phase" == "post" ]] && git -C "$REPO_ROOT" reset -q -- .work.ui >/dev/null 2>&1 || true
      exit 1
    fi
  fi
  secrets="$(git -C "$REPO_ROOT" diff --cached --name-only | secrets_scan)"
  if [[ -n "$secrets" ]]; then
    echo "ui-session: refuse — secrets-pattern path(s) must never be staged:" >&2
    echo "$secrets" | sed 's/^/  /' >&2
    echo "remove/gitignore them (see .cursorrules secrets rule); content is never committed" >&2
    # Never leave a secrets-pattern path staged.
    echo "$secrets" | xargs -r git -C "$REPO_ROOT" reset -q -- >/dev/null 2>&1 || true
    if [[ "$phase" == "post" ]]; then
      if [[ "$MODE" == "target" ]]; then
        git -C "$REPO_ROOT" reset -q -- .work.ui >/dev/null 2>&1 || true
      else
        git -C "$REPO_ROOT" reset -q >/dev/null 2>&1 || true
      fi
    fi
    exit 1
  fi
}

sed_escape() { printf '%s' "$1" | sed 's/[&/\]/\\&/g'; }

# ── Parse verbs (order-independent; normalize start → close → add → commit → push)
DO_START=0; DO_CLOSE=0; DO_ADD=0; DO_COMMIT=0; DO_PUSH=0
DO_STATUS=0; DO_CONTEXT=0; DO_SCOPED=0
MSG=""; GOAL=""
i=0
ARGS=("$@")
while [[ $i -lt ${#ARGS[@]} ]]; do
  a="${ARGS[$i]}"
  case "$a" in
    start|begin|open)  DO_START=1 ;;
    close|end|handoff) DO_CLOSE=1 ;;
    add|stage)         DO_ADD=1 ;;
    commit)            DO_COMMIT=1 ;;
    push)              DO_PUSH=1 ;;
    status)            DO_STATUS=1 ;;
    context)           DO_CONTEXT=1 ;;
    scoped)            DO_SCOPED=1 ;;
    -m)
      DO_COMMIT=1
      i=$((i + 1))
      [[ $i -lt ${#ARGS[@]} ]] && MSG="${ARGS[$i]}"
      ;;
    -m*)     DO_COMMIT=1; MSG="${a#-m}" ;;
    -)
      # Goal text: everything after a bare '-' (session-control parse parity).
      GOAL="${ARGS[*]:$((i + 1))}"
      break
      ;;
    *)
      echo "ui-session: unknown verb '${a}' — use status | context | start [- goal] | close | add [scoped] | commit [-m msg] [scoped] | push (any combination)" >&2
      exit 1
      ;;
  esac
  i=$((i + 1))
done

# Combination rules.
if [[ $DO_START -eq 1 && $DO_CLOSE -eq 1 ]]; then
  echo "ui-session: refuse — 'start' and 'close' are contradictory in one invocation" >&2
  exit 1
fi
if [[ $DO_STATUS -eq 1 || $DO_CONTEXT -eq 1 ]]; then
  if [[ $DO_START -eq 1 || $DO_CLOSE -eq 1 || $DO_ADD -eq 1 || $DO_COMMIT -eq 1 || $DO_PUSH -eq 1 ]]; then
    echo "ui-session: refuse — status/context are read-only and cannot be combined with write verbs" >&2
    exit 1
  fi
fi
if [[ -z "$MSG" ]]; then
  REF="$(detect_ref)"
  if [[ -n "$REF" ]]; then
    MSG="${REF}: update .work.ui session state"
  else
    MSG="chore: update .work.ui session state"
  fi
fi
if [[ $DO_START -eq 0 && $DO_CLOSE -eq 0 && $DO_ADD -eq 0 && $DO_COMMIT -eq 0 && $DO_PUSH -eq 0 && $DO_CONTEXT -eq 0 ]]; then
  DO_STATUS=1
fi

# In framework mode the default message talks about the repo, not just .work.ui.
if [[ "$MODE" == "framework" && ( "$MSG" == *"update .work.ui session state" ) ]]; then
  if [[ -n "${REF:-}" ]]; then
    MSG="${REF}: update framework session state"
  else
    MSG="chore: update framework session state"
  fi
fi

# ── status (read-only, compact) ────────────────────────────────────────────
if [[ $DO_STATUS -eq 1 ]]; then
  BRANCH="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo '?')"
  echo "ui-session status — repo: ${REPO_ROOT}"
  echo "  mode: ${MODE_DESC}"
  echo "  branch: ${BRANCH}"
  if [[ ! -d "$WORK_UI" ]]; then
    echo "  .work.ui/: MISSING (run @ui-bootstrap init first)"
    [[ "$MODE" == "target" ]] && exit 0
  else
    echo "  .work.ui/: present"
    if [[ -f "$HANDOFF_UI" ]] && grep -qF '**Open:** closed' "$HANDOFF_UI"; then
      echo "  session: closed"
    elif [[ -f "$HANDOFF_UI" ]] && grep -qE '^\*\*Open:\*\* [0-9]{4}-' "$HANDOFF_UI"; then
      echo "  session: open ($(sed -n 's/^\*\*Open:\*\* //p' "$HANDOFF_UI"))"
    else
      echo "  session: unknown"
    fi
  fi
  if [[ "$MODE" == "framework" ]]; then
    N_CHANGES="$(git -C "$REPO_ROOT" status --porcelain | wc -l | tr -d ' ')"
    echo "  tree (whole repo): $([[ "$N_CHANGES" == "0" ]] && echo clean || echo "dirty (${N_CHANGES} paths)")"
    echo "  changes (whole repo):"
    git -C "$REPO_ROOT" status --porcelain | sed 's/^/    /' || true
    echo "  last commit:"
    git -C "$REPO_ROOT" log -1 --format='    %h %s' 2>/dev/null || echo "    (none)"
  else
    N_CHANGES="$(git -C "$REPO_ROOT" status --porcelain -- .work.ui/ | wc -l | tr -d ' ')"
    echo "  tree (.work.ui/): $([[ "$N_CHANGES" == "0" ]] && echo clean || echo "dirty (${N_CHANGES} paths)")"
    echo "  changes under .work.ui/:"
    git -C "$REPO_ROOT" status --porcelain -- .work.ui/ | sed 's/^/    /' || true
    echo "  last commit touching .work.ui/:"
    git -C "$REPO_ROOT" log -1 --format='    %h %s' -- .work.ui/ 2>/dev/null || echo "    (none)"
  fi
  exit 0
fi

# ── context (read-only, uncommitted-aware) ─────────────────────────────────
if [[ $DO_CONTEXT -eq 1 ]]; then
  BRANCH="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo '?')"
  echo "ui-session context — repo: ${REPO_ROOT}"
  echo "  mode: ${MODE_DESC}"
  echo "  branch: ${BRANCH} · last commit: $(git -C "$REPO_ROOT" log -1 --format='%h %s' 2>/dev/null || echo '(none)')"
  if [[ ! -d "$WORK_UI" ]]; then
    echo "  .work.ui/: MISSING (run @ui-bootstrap init first)"
    [[ "$MODE" == "target" ]] && exit 1
  else
    if [[ -f "$HANDOFF_UI" ]] && grep -qF '**Open:** closed' "$HANDOFF_UI"; then
      echo "  session: closed"
    elif [[ -f "$HANDOFF_UI" ]] && grep -qE '^\*\*Open:\*\* [0-9]{4}-' "$HANDOFF_UI"; then
      echo "  session: open ($(sed -n 's/^\*\*Open:\*\* //p' "$HANDOFF_UI"))"
    else
      echo "  session: unknown"
    fi
  fi
  SCOPE_ARGS=()
  SCOPE_LABEL="whole repo"
  if [[ "$MODE" == "target" ]]; then
    SCOPE_ARGS=(-- .work.ui/)
    SCOPE_LABEL=".work.ui/"
  fi
  N_STAGED="$(git -C "$REPO_ROOT" diff --cached --name-only "${SCOPE_ARGS[@]}" | grep -c . || true)"
  N_UNSTAGED="$(git -C "$REPO_ROOT" diff --name-only "${SCOPE_ARGS[@]}" | grep -c . || true)"
  N_UNTRACKED="$(git -C "$REPO_ROOT" ls-files --others --exclude-standard "${SCOPE_ARGS[@]}" | grep -c . || true)"
  echo "  uncommitted (${SCOPE_LABEL}): staged ${N_STAGED} · unstaged ${N_UNSTAGED} · untracked ${N_UNTRACKED}"
  if [[ "$N_STAGED" == "0" && "$N_UNSTAGED" == "0" && "$N_UNTRACKED" == "0" ]]; then
    echo "  working tree (${SCOPE_LABEL}): clean"
  else
    echo "  paths (no content shown):"
    { git -C "$REPO_ROOT" diff --cached --name-only "${SCOPE_ARGS[@]}";
      git -C "$REPO_ROOT" diff --name-only "${SCOPE_ARGS[@]}";
      git -C "$REPO_ROOT" ls-files --others --exclude-standard "${SCOPE_ARGS[@]}"; } | sort -u | sed 's/^/    /'
    FLAGGED="$( { git -C "$REPO_ROOT" status --porcelain "${SCOPE_ARGS[@]}" | sed 's/^...//'; } | secrets_scan)"
    if [[ -n "$FLAGGED" ]]; then
      echo "  secrets scan: FLAGGED (paths only, content never shown):"
      echo "$FLAGGED" | sed 's/^/    /'
    else
      echo "  secrets scan: clean"
    fi
  fi
  if [[ "$MODE" == "target" ]]; then
    echo "  last commit touching .work.ui/:"
    git -C "$REPO_ROOT" log -1 --format='    %h %s' -- .work.ui/ 2>/dev/null || echo "    (none)"
  fi
  echo "  read-only: no files written (HANDOFF_UI / NEXT_UI untouched)"
  exit 0
fi

# ── Pre-flight ─────────────────────────────────────────────────────────────
if [[ "$MODE" == "target" && ! -d "$WORK_UI" ]]; then
  echo "ui-session: ${WORK_UI} missing — run @ui-bootstrap init first" >&2
  exit 1
fi
if [[ $DO_ADD -eq 1 || $DO_COMMIT -eq 1 ]]; then
  guard_staged pre
fi

# ── start: mark session open in HANDOFF_UI ─────────────────────────────────
if [[ $DO_START -eq 1 ]]; then
  if [[ ! -f "$HANDOFF_UI" ]]; then
    echo "ui-session: ${HANDOFF_UI} missing — nothing to open (run @ui-bootstrap init)" >&2
    exit 1
  fi
  TODAY="$(date +%Y-%m-%d)"
  OPEN_LINE="${TODAY}"
  [[ -n "$GOAL" ]] && OPEN_LINE="${TODAY} - goal: ${GOAL}"
  sed -i -e "s/^\*\*Open:\*\* .*\$/**Open:** $(sed_escape "$OPEN_LINE")/" \
         -e "s/^\*\*Updated:\*\* .*\$/**Updated:** ${TODAY}/" \
         -e "s/^\*\*Closed:\*\* .*\$/**Closed:** -/" "$HANDOFF_UI"
  echo "ui-session: opened — ${HANDOFF_UI} (Open: ${OPEN_LINE}) [mode: ${MODE_DESC}]"
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
  echo "ui-session: closed — ${HANDOFF_UI} (Open: closed, Updated/Closed: ${TODAY}) [mode: ${MODE_DESC}]"
fi

# ── add: stage in-scope changes (incl. untracked) without committing ───────
if [[ $DO_ADD -eq 1 && $DO_COMMIT -eq 0 ]]; then
  stage_scope
  guard_staged post
  if [[ "$MODE" == "framework" ]]; then
    N_STAGED="$(git -C "$REPO_ROOT" diff --cached --name-only | grep -c . || true)"
  else
    N_STAGED="$(git -C "$REPO_ROOT" diff --cached --name-only -- .work.ui/ | grep -c . || true)"
  fi
  if [[ "$N_STAGED" == "0" ]]; then
    echo "ui-session: nothing to stage [mode: ${MODE_DESC}]"
  else
    echo "ui-session: staged ${N_STAGED} path(s) (no commit) [mode: ${MODE_DESC}]:"
    if [[ "$MODE" == "framework" ]]; then
      git -C "$REPO_ROOT" diff --cached --name-only | sed 's/^/  /'
    else
      git -C "$REPO_ROOT" diff --cached --name-only -- .work.ui/ | sed 's/^/  /'
    fi
  fi
fi

# ── commit: stage in-scope changes (incl. untracked) + commit ──────────────
if [[ $DO_COMMIT -eq 1 ]]; then
  stage_scope
  if ! git -C "$REPO_ROOT" diff --cached --quiet; then
    guard_staged post
    git -C "$REPO_ROOT" commit -q -m "$MSG"
    echo "ui-session: committed — $(git -C "$REPO_ROOT" rev-parse --short HEAD) ($MSG) [mode: ${MODE_DESC}]"
  else
    guard_staged post   # still enforce guards on a pre-staged tree
    echo "ui-session: nothing to commit [mode: ${MODE_DESC}]"
  fi
fi

# ── push ──────────────────────────────────────────────────────────────────
if [[ $DO_PUSH -eq 1 ]]; then
  BRANCH="$(git -C "$REPO_ROOT" branch --show-current)"
  if [[ -z "$BRANCH" ]]; then
    echo "ui-session: detached HEAD — push skipped" >&2
    exit 1
  fi
  if [[ "$MODE" == "target" ]]; then
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
      echo "target-mode ui-session only pushes .work.ui/-scoped history; use git push yourself for other work" >&2
      exit 1
    fi
  fi
  if git -C "$REPO_ROOT" push >/dev/null 2>&1; then
    echo "ui-session: pushed ${BRANCH} [mode: ${MODE_DESC}]"
  else
    echo "ui-session: push failed for ${BRANCH} — set upstream (git push -u origin ${BRANCH}) and retry" >&2
    exit 1
  fi
fi

echo "ui-session: done"
