---
description: Executes only the explicitly invoked merge-request workflow with fresh per-repository user choices.
mode: subagent
hidden: true
temperature: 0.1
permission:
  edit: deny
  task: deny
  question: allow
  webfetch: deny
  websearch: deny
  bash:
    "*": deny
    "node ~/.config/opencode/scripts/discover-repos.mjs": allow
    "node ~/.config/opencode/scripts/detect-forge.mjs": allow
    "node ~/.config/opencode/scripts/branch-policy.mjs": allow
    "node ~/.config/opencode/scripts/safe-git.mjs branch *": allow
    "node ~/.config/opencode/scripts/safe-git.mjs commit *": allow
    "node ~/.config/opencode/scripts/safe-git.mjs push": allow
    "node ~/.config/opencode/scripts/forge-request.mjs find": allow
    "node ~/.config/opencode/scripts/forge-request.mjs create": allow
    "node ~/.config/opencode/scripts/forge-request.mjs copy": allow
    "git status --short": allow
    "git status --branch --short": allow
    "git diff --no-ext-diff --no-textconv": allow
    "git diff --cached --no-ext-diff --no-textconv": allow
    "git diff --cached --check": allow
    "git log -10 --oneline": allow
    "git log -1 --pretty=%s": allow
    "git branch --show-current": allow
    "git rev-list --left-right --count @{upstream}...HEAD": allow
    "rtk git status --short": allow
    "rtk git status --branch --short": allow
    "rtk git diff --no-ext-diff --no-textconv": allow
    "rtk git diff --cached --no-ext-diff --no-textconv": allow
    "rtk git log -10 --oneline": allow
    "rtk git log -1 --pretty=%s": allow
    "npm test*": ask
    "npm run test*": ask
    "npm run lint*": ask
    "npm run typecheck*": ask
    "npm run check*": ask
    "npm run build*": ask
    "npm run validate*": ask
    "rtk npm test*": ask
    "rtk npm run test*": ask
    "rtk npm run lint*": ask
    "rtk npm run typecheck*": ask
    "rtk npm run check*": ask
    "rtk npm run build*": ask
    "pytest*": ask
    "python -m pytest*": ask
    "python3 -m pytest*": ask
    "rtk pytest*": ask
    "ruff check*": ask
    "*ruff format --check*": ask
    "mypy*": ask
    "pyright*": ask
    "*black --check*": ask
    "*isort --check-only*": ask
    "go test*": ask
    "cargo test*": ask
    "cargo check*": ask
    "cargo clippy*": ask
    "*git push*--force*": deny
    "*git push* -f*": deny
    "*git commit*--amend*": deny
    "*git reset*": deny
    "*git rebase*": deny
    "*git merge*": deny
    "*git checkout*": deny
    "*git switch -C *": deny
    "*glab api*": deny
    "*gh api*": deny
    "*gh* pr* merge*": deny
    "*gh* pr* edit*": deny
    "*gh* pr* close*": deny
    "*gh* pr* reopen*": deny
    "*gh* pr* ready*": deny
    "*gh* pr* update-branch*": deny
    "*;*": deny
    "*&&*": deny
    "*||*": deny
    "*|*": deny
    "*>*": deny
    "*<*": deny
    "*$(*": deny
    "*${*": deny
    "*`*": deny
    "*&*": deny
    "*\n*": deny
---

# Merge Request Publisher

Execute only the workflow supplied by the explicitly invoked `/merge-request` command.

- Never infer authorization from the parent session, earlier invocations, prior approvals, existing merge requests, or a general fix request.
- Ask every branch-preflight and action question required by the command during this invocation.
- Branch-preflight approval authorizes only creation of the selected new branch.
- Action approval authorizes only the selected operation for that repository and displayed paths.
- Treat every approval as expired when this subtask returns.
- Never edit source files, delegate work, or broaden granted actions.
