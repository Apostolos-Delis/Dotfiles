---
name: create-hook
description: "Use when asked to create, suggest, or set up Claude Code hooks for a project."
---

# Create Hook

Analyze the project, suggest practical hooks, and create them with testing.

## Workflow

### 1. Environment Analysis and Suggestions

Detect project tooling and suggest relevant hooks.

When TypeScript is detected (`tsconfig.json`):
- PostToolUse: type-check after editing
- PreToolUse: block edits with type errors

When Prettier is detected (`.prettierrc`, `prettier.config.js`, `package.json`):
- PostToolUse: auto-format changed files
- PreToolUse: require formatted code

When ESLint is detected (`.eslintrc.*`):
- PostToolUse: lint/auto-fix after editing
- PreToolUse: block operations with lint errors

When Python tooling is detected (`pyproject.toml`, `.flake8`, `setup.py`):
- PostToolUse: auto-format with black/isort
- PostToolUse: run ruff/flake8 checks
- PreToolUse: block with mypy type errors

When Ruby tooling is detected (`Gemfile`, `.rubocop.yml`):
- PostToolUse: auto-format with `rubocop -a`
- PreToolUse: block with rubocop offenses

When `package.json` scripts exist:
- `test` script: suggest test validation hooks
- `build` script: suggest build validation hooks

When git repo is detected:
- PreToolUse/Bash: prevent commits with secrets
- PostToolUse: security scans on changed files

### 2. Hook Configuration

Start with: "What should this hook do?"

Ask only for unknown details:
1. Trigger timing (`PreToolUse`, `PostToolUse`, `UserPromptSubmit`, etc.)
2. Tool matcher (`Write`, `Edit`, `Bash`, `*`)
3. Scope (`global`, `project`, `project-local`)
4. Response approach (exit codes vs JSON response)
5. Blocking behavior
6. Claude integration (`additionalContext` vs silent mode)
7. Context noise preferences (`suppressOutput` on success)
8. File filtering scope

### 3. Hook Creation

Create or update:
- Hook script in `~/.claude/hooks/` or `.claude/hooks/`
- Hook registration in the correct `settings.json`

Implementation standards:
- Read JSON input from stdin
- Use top-level `additionalContext`/`systemMessage` for Claude communication
- Use `suppressOutput: true` for successful routine runs
- Report specific, actionable failures
- Operate on changed files instead of full repo scans
- Use absolute paths and `$CLAUDE_PROJECT_DIR` where needed

### 4. Testing and Validation

Test both paths:
- Happy path: hook passes on valid input
- Sad path: hook warns/blocks on invalid input

Then verify:
1. Hook is registered in settings
2. Script is executable (`chmod +x`)
3. Behavior matches expected blocking/warning semantics

If problems occur:
- Verify registration
- Verify permissions
- Reduce to a minimal reproduction
- Re-test with a simplified script

## References

- Official docs: `https://docs.claude.com/en/docs/claude-code/hooks.md`
- Examples: `https://docs.claude.com/en/docs/claude-code/hooks#examples`

## Gotchas

- **Slow hooks block everything**: A hook that runs `tsc` on the entire project after every file edit will make Claude unusable. Scope to changed files only, and keep execution under 2-3 seconds.
- **stdin JSON parsing failures**: Hooks receive JSON on stdin. If your script doesn't read stdin (or reads it wrong), it silently gets empty input. Always test with `echo '{"tool":"Write"}' | ./hook.sh`.
- **Permission issues**: Forgetting `chmod +x` on the hook script is the #1 cause of "hook not working." Always verify.
- **Hooks that break in CI**: Hooks that depend on global tools (`prettier` not in devDependencies, `rubocop` not in Gemfile) will fail in CI or on other machines. Use project-local binaries (`npx`, `bundle exec`).
- **Infinite loops**: A PostToolUse hook that modifies files can trigger itself if not filtered properly. Always check the tool name and file path before acting.
