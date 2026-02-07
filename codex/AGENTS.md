# Global Context

Full-stack developer on macOS. Primary languages: Python, TypeScript, Ruby.

## Coding Preferences

- **No comment pollution**: Don't add comments, docstrings, or type annotations to code you didn't write
- **Minimal diffs**: Only change what's directly needed - no drive-by refactors or "improvements"
- **No premature abstraction in new code**: Three similar lines > unnecessary helper function
- **Flag DRY opportunities in reviews**: When reviewing or refactoring existing code, identify repetition worth consolidating
- **"Engineered enough"**: Solution should fit problem size — not under-engineered (fragile) and not over-engineered (unnecessary complexity)
- **Demand elegance (balanced)**: For non-trivial changes, pause and ask "is there a more elegant way?" Skip this for simple, obvious fixes. Challenge your own work before presenting it.
- **Handle edge cases**: Consider nulls, empties, boundaries, and error states
- **Let tooling handle style**: Don't manually format - run the project's linter/formatter
- **Understand before fixing**: Read surrounding code and find root cause before changing anything. No temporary fixes — find and fix the real problem.

## Git Commits

- Atomic commits focused on one change
- Message format: imperative mood, explain "why" not "what"
- Run project's existing test/lint commands before committing

## Shell Shortcuts (available in my environment)

- `gsedit` - Open git-modified files in nvim
- `root` - cd to git repo root
- `killp <port>` - Kill process on port

## Development Environment

- **Terminal**: Ghostty (primary), not VS Code integrated terminal
- **Editor**: Cursor (VS Code fork) for code editing
- **OS**: macOS with terminal-notifier for system notifications

## Infrastructure & Deployment

- **Kubernetes/Helm**: When modifying Helm charts, ALWAYS check for environment-specific overlay files (staging.yaml, production.yaml, etc.) that may override base values.yaml
- **Multi-environment changes**: Read ALL environment overlay files before proposing configuration changes

## Agent Behavior

- **Exploration tasks**: For targeted exploration of a single repo/directory, use direct file reads/searches instead of spawning sub-agents
- **Use sub-agents only for**: Unbounded searches across large codebases, or when searching for patterns across multiple repos
- **Avoid parallel agent spam**: Don't spawn multiple agents to explore the same repository from different angles - do comprehensive single-pass exploration
