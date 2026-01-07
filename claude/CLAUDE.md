# Global Context

Full-stack developer on macOS. Primary languages: Python, TypeScript, Ruby.

## Environment

- Terminal: Ghostty + tmux (prefix: `Ctrl+a`)
- Editor: Neovim with LSP
- Shell: Zsh with Oh-My-Zsh
- Version managers: rbenv, nodenv, pyenv

## Shell Aliases

- `gsedit` - Open git-modified files in nvim
- `fedit` - Fuzzy find + edit file
- `fd` - Fuzzy cd to directory
- `root` - cd to git repo root
- `killp <port>` - Kill process on port

## How I Work

IMPORTANT: Always follow existing project conventions. Read surrounding code before making changes.

### Code Style
- Concise, readable code - no clever one-liners
- Self-documenting code - minimal comments
- Let linters/formatters handle style (don't manually format)

### Changes
- Minimal diffs - only change what's necessary
- No over-engineering or premature abstraction
- Understand root cause before fixing bugs
- Test new features and bug fixes

### Git
- Atomic commits with clear "why" messages

## Project Detection

When entering a new project, check for:
- `package.json` → Node project, use npm/yarn/pnpm
- `pyproject.toml` or `requirements.txt` → Python project
- `Gemfile` → Ruby project, use bundler
- `Cargo.toml` → Rust project
- `go.mod` → Go project

Run the project's existing test/lint commands rather than assuming.

## Things to Avoid

- Don't add comments to code you didn't write
- Don't refactor unrelated code while fixing bugs
- Don't create abstractions for one-time operations
- Don't guess at project structure - explore first
