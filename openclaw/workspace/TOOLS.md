# TOOLS.md - Local Notes

## OpenClaw

- CLI: `/opt/homebrew/bin/openclaw`
- Gateway: `http://127.0.0.1:18789/`
- Service: macOS LaunchAgent `ai.openclaw.gateway`
- State directory: `~/.openclaw`
- Workspace: `~/Documents/repos/Dotfiles/openclaw/workspace`
- Main session key: `agent:main:main`

Useful commands:

- `openclaw dashboard`
- `openclaw gateway status`
- `openclaw status`
- `openclaw logs --follow`
- `openclaw sessions list`
- `openclaw workboard list`
- `openclaw workboard create "Task title"`
- `openclaw workboard dispatch`
- `openclaw models status`
- `openclaw models auth list --provider openai`
- `openclaw skills check`
- `openclaw tasks list --status running`
- `openclaw tasks audit`
- `openclaw sessions --active 240 --all-agents`
- `openclaw sessions tail --follow`

## Codex Runtime

- Default model: `openai/gpt-5.5`
- Runtime: OpenAI Codex via `@openclaw/codex`
- Auth profile: `openai:codex-api-key`
- Codex plugin config: guardian app-server mode
- Workboard plugin is enabled for local task tracking.
- `coding-agent` skill is enabled for background Codex worker lanes.

Use native `/codex` commands from OpenClaw chat surfaces for thread control:

- `/codex status`
- `/codex models`
- `/codex threads`
- `/codex resume <thread-id>`
- `/codex bind --cwd <path>`
- `/codex stop`

## Conductor

Conductor creates one Codex session per task in a separate worktree. When a task already has a Conductor workspace, operate in that workspace and avoid creating a nested worktree.

Typical workspace root pattern:

- `~/conductor/workspaces/<repo>/<task-name>`

## Dotfiles

- Dotfiles repo: `~/Documents/repos/Dotfiles`
- OpenClaw upstream reference: `~/Documents/repos/openclaw-upstream`
