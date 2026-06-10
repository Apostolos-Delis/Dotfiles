---
name: fleet
description: "Use when the user says fleet, /skill:fleet, /fleet, codex fleet, agent fleet, or wants OpenClaw to spin up, supervise, babysit, monitor, or follow up on multiple parallel coding-agent sessions using Codex, Claude Code, or OpenCode; create one worktree/branch/PR per task; manage Workboard cards; run coding-agent workers; process GitHub issues into PRs; or keep an agent fleet moving with minimal user prompting."
user-invocable: true
metadata:
  short-description: "Run and monitor parallel worktree-to-PR agent lanes"
---

# Fleet

Turn short user requests into a supervised fleet of coding-agent lanes.

## Short User Prompts

Treat these as enough to start:

- "/skill:fleet repo `/path/repo`, harness codex, 6 lanes: ..."
- "Use fleet on `/path/repo` for these tasks: ..."
- "Fleet this repo: ..."
- "Run 6 Codexes against these issues."
- "Run 4 Claude Code lanes on this repo."
- "Babysit my coding-agent sessions and open PRs."
- "Use gh-issues on owner/repo for label X."

Infer missing details from repo state when reasonable. Ask only when the repo,
task list, target branch, or destructive decision cannot be inferred safely.

## Required Defaults

- Default concurrency: 5-8 active lanes.
- Hard cap: 10 active coding lanes unless the user explicitly asks.
- Default base branch: repository default branch.
- Default branch pattern: `openclaw/<task-slug>`.
- Default worktree path: `<repo>/.worktrees/openclaw/<task-slug>`.
- Default repo search root: `~/Documents/repos`.
- Default harness: `codex`.
- Supported harnesses: `codex`, `claude`, `opencode`.
- Default notification surface: OpenClaw Control UI and local chat until a chat channel is configured.
- Use Telegram/Discord/etc. as the worker notification route once configured.

## Harness Selection

Respect a user-provided harness/engine:

- `Harness: codex`, `use Codex`, or "Codexes" -> use `codex`.
- `Harness: claude`, `use Claude Code`, or "Claude lanes" -> use `claude`.
- `Harness: opencode`, `use OpenCode` -> use `opencode`.
- If not specified, always use `codex`.
- If the user names another harness, check whether `coding-agent` supports it before using it. If support is unclear, ask instead of guessing.

Use one harness for the whole fleet unless the user explicitly asks to mix them.
Record the selected harness on each Workboard card and in each worker prompt.

Launch rules from `coding-agent`:

- Codex: `pty:true`, `background:true`, command `codex exec - < "$PROMPT"`.
- Claude Code: `background:true`, no PTY, command `claude --permission-mode bypassPermissions --print < "$PROMPT"`.
- OpenCode: `pty:true`, `background:true`, command `opencode run < "$PROMPT"`.

## Mode Selection

- If the user gives a list of tasks, create one Workboard card and one worker lane per task.
- If the user gives GitHub issues or labels, use the `gh-issues` skill and mirror the lanes on Workboard.
- If Conductor already created workspaces, reuse those workspaces and do not create nested worktrees.
- If the user says "watch", "babysit", "monitor", or asks for 5+ lanes, create or reuse a supervisor lane/session.

## Preflight

Before launching workers:

1. Resolve the repo path and base branch.
2. If the user gives `owner/repo`, a repo name, or a GitHub URL, search local checkouts under `~/Documents/repos` and match git remotes before asking for a path.
3. Resolve the harness. Default to `codex` if unspecified.
4. Check that the selected harness binary exists before promising worker launch.
5. Check the source checkout for uncommitted changes. Do not incorporate them unless the user says to.
6. Check GitHub auth before promising PR creation.
7. Check Workboard and active tasks for duplicate branches, cards, PRs, or workers.
8. Partition tasks to avoid avoidable file overlap. If overlap is likely, tell the user the merge-conflict risk.

Useful checks:

```bash
git -C "$REPO" status --short
git -C "$REPO" remote get-url origin
command -v "$HARNESS"
gh auth status
openclaw workboard list
openclaw tasks list --status running
openclaw sessions --active 240 --all-agents
```

Repo lookup shape:

```bash
ROOT="$HOME/Documents/repos"
REF="owner/repo"

find "$ROOT" -type d -name .git -prune | while read -r gitdir; do
  repo="${gitdir%/.git}"
  url="$(git -C "$repo" remote get-url origin 2>/dev/null || true)"
  name="$(basename "$repo")"
  case "$url $name" in
    *"$REF"*|*"${REF##*/}"*) printf '%s\t%s\n' "$repo" "$url" ;;
  esac
done
```

Prefer exact remote matches over name-only matches. If multiple local checkouts match, ask which one to use.

## Lane Creation

One task equals one Workboard card, one branch, one worktree, one coding-agent worker session, and one PR.

The Workboard is the source of truth. Do not leave fleet cards in `todo` after
creating worktrees. A lane is not considered launched until the card has either:

- a linked Workboard-dispatched session/task, or
- an explicit fallback note saying the worker was launched outside Workboard and
  listing the process/session/log path that must be monitored.

Prefer Workboard-dispatched sessions for visibility. Create cards in `ready`
when the lane is prepared to run, then dispatch them:

```bash
openclaw workboard create \
  --status ready \
  --agent main \
  --labels "fleet,<repo-name>,<harness>,<task-slug>" \
  --notes "$CARD_NOTES" \
  "$CARD_TITLE"

openclaw workboard dispatch --json
```

Only launch the harness directly from the terminal if Workboard dispatch is
unavailable or insufficient for the requested workflow. When using that
fallback, immediately report reduced UI visibility and keep monitoring with
process, worktree, git, and session checks until the lane is blocked or PR-ready.

For each lane:

```bash
git -C "$REPO" fetch origin --prune
git -C "$REPO" worktree add -b "$BRANCH" "$WORKTREE" "origin/$BASE_BRANCH"
```

Record on the Workboard card:

- repo
- task
- harness
- base branch
- branch
- worktree
- worker session key or task id when available
- latest check command
- PR URL when opened
- current state

## Worker Prompt

Write a prompt file and launch a background worker with the `coding-agent` rules for the selected harness.

For normal fleet work, put the prompt into the Workboard card notes or linked
worker session and let `openclaw workboard dispatch` start the visible worker.
If direct launch is required, keep the card notes updated with the fallback
worker PID, command, worktree, branch, and latest observed status.

Every worker prompt must include:

```text
You are one coding-agent worker lane managed by OpenClaw.
Harness: <codex|claude|opencode>
Repo: <repo>
Worktree/workspace: <path>
Branch: <branch>
Base branch: <base>
Workboard card: <card-id or title>
Task: <task>

Work autonomously in the assigned workspace only.
Do not mutate the source checkout, OpenClaw state, or unrelated worktrees.
Do not ask for input unless blocked by missing requirements, credentials,
destructive approval, merge-conflict preference, or ambiguous product decision.

Implement the task with the smallest coherent diff.
Run relevant checks and report exact commands.
Inspect the final diff.
Run an adversarial self-review and fix accepted findings.
Commit with an imperative message.
Push the branch.
Open a PR unless explicitly told to stop at a prepared branch.

PR body must include:
- Summary
- Verification
- Risks/Notes
- Linked issue/card when available

Send exactly one blocked, failed, or PR-ready notification through the provided
OpenClaw notification route.
```

Append the real notification route from `coding-agent` when a chat channel or
reply target exists. If no route exists, say auto-notify is unavailable and rely
on Workboard plus local OpenClaw chat.

Launch examples:

```bash
# codex
codex exec - < "$PROMPT"

# claude
claude --permission-mode bypassPermissions --print < "$PROMPT"

# opencode
opencode run < "$PROMPT"
```

## Monitoring Loop

Actively monitor while lanes are running. Do not wait for the user to ask for every update.

For each pass:

1. Read Workboard cards for running, blocked, review, ready, and todo lanes.
2. Read active tasks and recent sessions.
3. Treat a fleet card in `todo` with an existing worktree as stale visibility; either dispatch/link it or report why it cannot be linked.
4. Refresh stale cards by inspecting linked worker/task/session state.
5. For fallback direct launches, map worker processes to worktrees with `lsof -a -p <pid> -d cwd` and inspect `git status`.
6. Nudge stuck workers with one concise follow-up prompt.
7. Move PR-ready lanes to review.
8. Mark genuinely blocked lanes with a concrete blocker.
9. Dispatch or launch more ready lanes only when this is part of the requested fleet.

Useful commands:

```bash
openclaw workboard list
openclaw workboard show <card-id>
openclaw workboard dispatch
openclaw tasks list --status running
openclaw tasks show <task-id-or-session-key>
openclaw sessions --active 240 --all-agents
git -C "$REPO" worktree list --porcelain
```

Use a supervisor cron only when the user asks for active unattended monitoring
or when a fleet has 5+ lanes and the user expects OpenClaw to keep watching:

```bash
openclaw cron add \
  --name codex-fleet-supervisor \
  --every 10m \
  --agent main \
  --session-key agent:main:codex-fleet-supervisor \
  --timeout-seconds 900 \
  --no-deliver \
  --message "Audit the Codex fleet. Check Workboard cards, active tasks, and active sessions. Update lane status, detect stale workers, nudge stuck workers with concise follow-up prompts, move PR-ready work to review, and mark genuinely blocked work with a concrete blocker. Do not start unrelated new work. Notify the user only for blockers or PR-ready status."
```

If Telegram or another channel is configured, use delivery flags instead of
`--no-deliver` so blockers and PR-ready status reach the user.

## User Interruptions

Interrupt the user only for:

- missing credentials or auth
- destructive or high-risk operation approval
- ambiguous product behavior
- merge-conflict preference
- checks that still fail after a focused retry
- PR ready for review
- notification channel setup decisions

## PR Follow-Up

For review comments on PRs created by this workflow:

- Reuse the same branch/worktree when possible.
- Spawn one follow-up worker per PR, not one per comment.
- Group actionable comments.
- Patch minimal changes.
- Run checks.
- Push normally; do not force-push unless explicitly told.
- Reply to addressed comments with concise evidence.

## Completion Summary

Report compactly:

- lane/card
- branch/worktree
- status
- tests/checks
- PR URL or blocker
- user action needed, if any
