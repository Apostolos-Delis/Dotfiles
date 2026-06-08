Dotfiles is the source of truth for Claude, Codex, and Hermes agent configuration on this machine.
§
Shared local skills live in Dotfiles at .agents/skills and are exposed to Hermes through ~/.agents/dotfiles-skills. Existing personal skills may remain in ~/.agents/skills.
§
Hermes pilot uses Kanban as lifecycle owner and Codex CLI as a bounded coding lane. Hermes must review diffs and rerun verification before marking tasks done.
§
Conductor workspaces live under ~/conductor/workspaces and are normal git worktrees. Register an existing workspace path instead of creating nested worktrees.
§
Codex CLI and GitHub CLI are available on this machine; Codex auth lives separately under ~/.codex.
