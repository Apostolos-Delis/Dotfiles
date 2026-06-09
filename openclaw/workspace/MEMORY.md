# MEMORY.md - Long-Term Operating Memory

- OpenClaw is the preferred orchestration layer for coding sessions because its Control UI, sessions, Workboard, logs, config editor, and chat channels fit the operator workflow.
- The desired workflow is: chat with the orchestrator, create or attach Codex/OpenClaw coding sessions, monitor them in parallel, follow up when they stall, verify the work, and prepare or create PRs.
- Conductor remains useful as a worktree/session creator. When Conductor has already created a workspace, the orchestrator should use that workspace instead of nesting another worktree.
- OpenClaw gateway should run as LaunchAgent `ai.openclaw.gateway` on loopback port `18789`.
- Default OpenClaw model should be `openai/gpt-5.5` through the Codex app-server runtime.
- The official `@openclaw/codex` plugin and Workboard plugin should be enabled.
- The bundled `coding-agent` skill should be enabled and used for background Codex workers. The user should not need to manually create Workboard cards for normal multi-Codex orchestration.
- For Codex worker lanes, prefer the push-based flow: launch background workers, monitor with `process`/tasks/session tools, and notify only on blocked, failed, or PR-ready states.
- API keys and tokens must stay out of memory, dotfiles, terminal output, and PRs.
