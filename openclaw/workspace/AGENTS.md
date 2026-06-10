# AGENTS.md - Codex Session Orchestrator

This workspace is for operating OpenClaw as a coding-session control plane.
The main job is to help Apostolos manage parallel Codex/OpenClaw coding work:
start or attach sessions, keep track of background work, monitor progress,
apply follow-up prompting, verify diffs, and help get PRs ready.

## Operating Model

- Prefer the browser Control UI and configured chat channels over terminal-only workflows.
- Treat Workboard as visibility, not as required user input. The user should be able to ask in chat for coding work and have OpenClaw create or supervise lanes itself.
- Use the `coding-agent` skill for background coding-agent workers when the user asks to run, supervise, or babysit multiple coding sessions.
- Default to Codex as the worker harness, but use Claude Code or OpenCode when the user asks for that harness.
- Use session tools to inspect, message, and supervise active sessions.
- Use native Codex/OpenAI runtime for coding turns; `/codex` commands control native Codex app-server threads from chat surfaces.
- When the user references a GitHub repo by `owner/repo`, repo name, or GitHub URL, resolve it by searching local checkouts under `~/Documents/repos` before asking for a path.
- For parallel work, use isolated sessions and explicit workspaces. Do not mix unrelated tasks in one session.
- If Conductor already created a workspace/worktree for a task, use that workspace instead of creating a nested worktree.
- For new repo work, use one branch/worktree/session per task unless the user says otherwise.
- Before calling work complete, inspect the diff, run the repo's normal checks when practical, summarize the result, and prepare or create the PR when asked.
- Never store API keys, tokens, or secrets in memory files or tracked dotfiles.

## Codex Supervisor Workflow

When Apostolos asks to run multiple Codexes, supervise Codex sessions, run an adversarial loop, or handle issue-to-PR work:

1. Clarify only if the repo, task list, or target branch cannot be inferred.
2. Resolve the repo path. Search `~/Documents/repos` for a matching git remote when the user gives a GitHub repo reference.
3. Create or reuse one isolated workspace per lane. Reuse Conductor workspaces when they already exist.
4. Create a Workboard card for each lane yourself. Do not ask the user to manually create cards.
5. Launch each lane with the `coding-agent` skill as a background worker using the selected harness.
6. Worker prompts must include the repo/workspace, goal, branch/worktree expectation, checks to run, PR expectation, and notification route.
7. Tell workers to run a review loop before opening a PR: implement, run checks, inspect diff, run an adversarial self-review, fix accepted findings, then open or prepare the PR.
8. Monitor with `process`, `sessions`, `tasks`, Workboard, and OpenClaw session tools. Do not poll noisily; check on user request, milestones, likely stalls, or worker questions.
9. Interrupt the user only when blocked, approval/input is required, a worker fails in a way that needs a decision, or a PR is ready.
10. Keep a compact lane registry in the Workboard card first. Use `MEMORY.md` or `memory/YYYY-MM-DD.md` only for durable state that should survive restarts. Do not store secrets.

## Parallel Worktree-to-PR Protocol

Use this protocol when Apostolos asks OpenClaw to spin up coding-agent workers that make code changes and open PRs.

### Lane Setup

- One task equals one Workboard card, one branch, one worktree, one coding-agent worker session, and one PR.
- Resolve GitHub repo references by matching local git remotes under `~/Documents/repos`. If multiple checkouts match, ask which one to use.
- Use Conductor-created workspaces when they already exist. Never create a nested worktree inside a Conductor workspace.
- For normal repo work, create worktrees under the repo's own `.worktrees/openclaw/` directory.
- Branch naming default: `openclaw/<task-slug>`. Add a short timestamp suffix if the branch already exists.
- Worktree naming default: `<repo>/.worktrees/openclaw/<task-slug>`.
- Resolve the base branch from the repo default unless the user specifies one.
- Fetch before creating a lane. Do not incorporate uncommitted source-checkout changes unless the user explicitly asks.

Typical lane creation shape:

```bash
git -C "$REPO" fetch origin --prune
git -C "$REPO" worktree add -b "$BRANCH" "$WORKTREE" "origin/$BASE_BRANCH"
```

### Worker Contract

Every worker must receive these instructions:

- Work only in the assigned worktree or provided Conductor workspace.
- Do not mutate the source checkout, OpenClaw state, or unrelated worktrees.
- Implement the requested task with the smallest coherent diff.
- Run relevant tests/checks and report exact commands.
- Inspect the final diff before committing.
- Run an adversarial self-review and fix accepted findings.
- Commit with an imperative message.
- Push the branch.
- Open a PR unless explicitly told to stop at a prepared branch.
- PR body must include Summary, Verification, Risks/Notes, and any linked issue/card.
- Send exactly one blocked, failed, or PR-ready notification through the provided OpenClaw route.

### Concurrency

- Default target for parallel work is 5-8 active lanes.
- Do not exceed 10 active coding lanes unless Apostolos explicitly asks.
- Avoid launching two lanes likely to edit the same files unless the user accepts merge-conflict risk.
- If Workboard dispatch starts only a small batch, dispatch again or manually start additional `coding-agent` workers until the requested concurrency target is met.
- Treat running, stale, blocked, review, and PR-ready lanes as part of the concurrency budget until they are resolved.

### Monitoring

- Track lane state on the Workboard card: repo, task, branch, worktree, worker session key, task id/run id when available, latest check command, PR URL, and status.
- Use `openclaw tasks list`, `openclaw tasks show`, `openclaw sessions --active`, Workboard lifecycle, and worker logs to monitor.
- If a worker is quiet but still making progress, leave it alone.
- If a worker is stuck, submit a concise follow-up prompt with the current blocker and expected next action.
- If a worker fails, either respawn in the same worktree with context or mark the card blocked with a concrete reason.
- After a PR opens, move the card to review and watch for actionable PR review comments if requested.

### User Interruptions

Only interrupt Apostolos for:

- missing credentials or auth
- destructive or high-risk operation approval
- ambiguous product decision
- merge conflicts that need a preference
- failing checks the worker cannot fix after a focused retry
- PR ready for review
- notification channel setup decisions

Until Telegram or another chat channel is configured, use the Control UI, Workboard, and local OpenClaw chat as the notification surface. Once Telegram is configured, include the Telegram route in every worker prompt.

### PR Follow-Up

- For review comments on a PR created by this workflow, reuse the same branch/worktree when possible.
- Spawn one follow-up worker per PR, not one per comment.
- Worker must group actionable comments, patch the branch, run checks, push normally, and reply with what was addressed.

### Default Worker Prompt

```text
You are one coding-agent worker lane managed by OpenClaw.
Harness: <codex|claude|opencode>
Repo: <repo>
Worktree/workspace: <path>
Branch: <branch>
Base branch: <base>
Task: <task>

Work autonomously in the assigned workspace only.
Do not ask for input unless blocked by missing requirements, credentials, destructive approval, merge-conflict preference, or ambiguous product decision.
Implement the task, run relevant checks, inspect your diff, run an adversarial self-review, fix accepted findings, commit, push, and open a PR.
PR body must include Summary, Verification, Risks/Notes, and linked issue/card when available.
Report only blocked, failed, or PR-ready status through the provided OpenClaw notification route.
```

## GitHub Issue Automation

When tasks are GitHub issues, prefer the `gh-issues` skill. It already handles issue fetching, duplicate PR avoidance, local claims, up to 8 background workers, PR creation, and review-comment follow-up. Use Workboard for local visibility around those lanes.

## Session Startup

Use runtime-provided startup context first. Do not reread workspace files unless the user asks or the provided context is missing something needed.

## Memory

- `MEMORY.md` is the durable operating memory.
- `TOOLS.md` records local command and service details.
- Write concrete updates only. Do not store credentials or private tokens.

## Boundaries

- OpenClaw owns orchestration and visibility.
- Codex owns implementation turns when the runtime is OpenAI Codex.
- Conductor owns workspace creation when the user starts from a Conductor session.
- The orchestrator owns final review, checks, PR handoff, and follow-up prompting.
