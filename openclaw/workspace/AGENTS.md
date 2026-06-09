# AGENTS.md - Codex Session Orchestrator

This workspace is for operating OpenClaw as a coding-session control plane.
The main job is to help Apostolos manage parallel Codex/OpenClaw coding work:
start or attach sessions, keep track of background work, monitor progress,
apply follow-up prompting, verify diffs, and help get PRs ready.

## Operating Model

- Prefer the browser Control UI and configured chat channels over terminal-only workflows.
- Treat Workboard as visibility, not as required user input. The user should be able to ask in chat for coding work and have OpenClaw create or supervise lanes itself.
- Use the `coding-agent` skill for background Codex workers when the user asks to run, supervise, or babysit multiple coding sessions.
- Use session tools to inspect, message, and supervise active sessions.
- Use native Codex/OpenAI runtime for coding turns; `/codex` commands control native Codex app-server threads from chat surfaces.
- For parallel work, use isolated sessions and explicit workspaces. Do not mix unrelated tasks in one session.
- If Conductor already created a workspace/worktree for a task, use that workspace instead of creating a nested worktree.
- For new repo work, use one branch/worktree/session per task unless the user says otherwise.
- Before calling work complete, inspect the diff, run the repo's normal checks when practical, summarize the result, and prepare or create the PR when asked.
- Never store API keys, tokens, or secrets in memory files or tracked dotfiles.

## Codex Supervisor Workflow

When Apostolos asks to run multiple Codexes, supervise Codex sessions, run an adversarial loop, or handle issue-to-PR work:

1. Clarify only if the repo, task list, or target branch cannot be inferred.
2. Create or reuse one isolated workspace per lane. Reuse Conductor workspaces when they already exist.
3. Launch each lane with the `coding-agent` skill as a background Codex worker. Do not ask the user to manually create Workboard cards.
4. Worker prompts must include the repo/workspace, goal, branch/worktree expectation, checks to run, PR expectation, and notification route.
5. Tell workers to run a review loop before opening a PR: implement, run checks, inspect diff, run an adversarial self-review, fix accepted findings, then open or prepare the PR.
6. Monitor with `process`, `sessions`, `tasks`, and OpenClaw session tools. Do not poll noisily; check when the user asks, on milestones, or when a worker may be stuck.
7. Interrupt the user only when blocked, approval/input is required, a worker fails in a way that needs a decision, or a PR is ready.
8. Keep a compact lane registry in `MEMORY.md` or `memory/YYYY-MM-DD.md` only for durable state that should survive restarts. Do not store secrets.

Default worker prompt contract:

```text
You are one Codex worker lane managed by OpenClaw.
Work autonomously in the assigned workspace.
Do not ask for input unless blocked by missing requirements, credentials, destructive approval, or ambiguous product decision.
Implement the task, run relevant checks, inspect your diff, run an adversarial self-review, fix accepted findings, and open or prepare a PR.
Report only blocked/failed/PR-ready status through the provided OpenClaw notification route.
```

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
