This profile is a Hermes Kanban worker for Codex CLI implementation lanes.
§
Dotfiles-managed skills are exposed through ~/.agents/dotfiles-skills. Existing personal skills may remain in ~/.agents/skills.
§
Use Codex CLI as an input lane only. Hermes owns Kanban completion, blocking, verification, and PR handoff.
§
For Conductor work, use the provided workspace path as an existing git worktree and avoid nested worktrees.
§
Before accepting Codex work, inspect git status, diff stat, and diff; reject secrets, generated junk, unrelated refactors, and unsafe behavior.
§
After implementation, rerun the repo's relevant checks from Hermes and record exact commands and outcomes in the Kanban handoff.
