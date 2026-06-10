# TOOLS.md - Local Notes

## OpenClaw

- CLI: `/opt/homebrew/bin/openclaw`
- Gateway: `http://127.0.0.1:18789/`
- Service: macOS LaunchAgent `ai.openclaw.gateway`
- State directory: `~/.openclaw`
- Workspace: `~/.openclaw/workspace`
- Main session key: `agent:main:main`

Useful commands:

- `openclaw dashboard`
- `openclaw gateway status`
- `openclaw status`
- `openclaw logs --follow`
- `openclaw sessions list`
- `openclaw workboard list`
- `openclaw workboard create "Task title"`
- `openclaw workboard show <card-id>`
- `openclaw workboard dispatch`
- `openclaw models status`
- `openclaw models auth list --provider openai`
- `openclaw skills check`
- `openclaw tasks list --status running`
- `openclaw tasks show <task-id-or-session-key>`
- `openclaw tasks audit`
- `openclaw sessions --active 240 --all-agents`
- `openclaw sessions tail --follow`

## Codex Runtime

- Default model: `openai/gpt-5.5`
- Runtime: OpenAI Codex via `@openclaw/codex`
- Auth profile: `openai:codex-api-key`
- Codex plugin config: guardian app-server mode
- Workboard plugin is enabled for local task tracking.
- `coding-agent` skill is enabled for background worker lanes.
- Default worker harness is Codex unless the user asks for Claude Code or OpenCode.

Use native `/codex` commands from OpenClaw chat surfaces for thread control:

- `/codex status`
- `/codex models`
- `/codex threads`
- `/codex resume <thread-id>`
- `/codex bind --cwd <path>`
- `/codex stop`

## Parallel Worktree-to-PR Commands

Use these as the default shape for coding-agent worker lanes when Conductor has not already created a workspace:

```bash
REPO=/path/to/repo
BASE_BRANCH=main
TASK_SLUG=short-task-slug
BRANCH="openclaw/$TASK_SLUG"
WORKTREE="$REPO/.worktrees/openclaw/$TASK_SLUG"

git -C "$REPO" fetch origin --prune
git -C "$REPO" worktree add -b "$BRANCH" "$WORKTREE" "origin/$BASE_BRANCH"
```

Worker launch shapes from OpenClaw:

```bash
PROMPT=$(mktemp -t openclaw-worker-prompt.XXXXXX)
# write the worker prompt and notification route into "$PROMPT"

# Codex: OpenClaw tool call should use pty:true background:true workdir:$WORKTREE
codex exec - < "$PROMPT"

# Claude Code: OpenClaw tool call should use background:true workdir:$WORKTREE, no PTY
claude --permission-mode bypassPermissions --print < "$PROMPT"

# OpenCode: OpenClaw tool call should use pty:true background:true workdir:$WORKTREE
opencode run < "$PROMPT"
```

PR creation shape from inside the worker worktree:

```bash
git status --short
git diff --stat "origin/$BASE_BRANCH"...
gh pr create --title "..." --body-file /tmp/pr.md
```

The PR body should include Summary, Verification, Risks/Notes, and linked issue/card.

## Repo Resolution

When the user references a GitHub repo by `owner/repo`, repo name, or URL, search local checkouts under `~/Documents/repos` before asking for a path.

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

## Conductor

Conductor creates one Codex session per task in a separate worktree. When a task already has a Conductor workspace, operate in that workspace and avoid creating a nested worktree.

Typical workspace root pattern:

- `~/conductor/workspaces/<repo>/<task-name>`

## Dotfiles

- Dotfiles repo: `~/Documents/repos/Dotfiles`
- OpenClaw upstream reference: `~/Documents/repos/openclaw-upstream`
