---
name: verify
description: "Use after making changes to verify they work correctly — run tests, check types, lint, and manually verify behavior when possible."
---

# Verify

Run all relevant checks to confirm changes work correctly.

## Workflow

### 1. Detect Project Tooling

Auto-detect what's available:

- **Tests**: `pytest`, `jest`, `vitest`, `rspec`, `minitest`, `go test`, `cargo test` — check `package.json` scripts, `Makefile`, `pyproject.toml`
- **Types**: `tsc --noEmit`, `mypy`, `pyright`, `sorbet`
- **Lint**: `eslint`, `rubocop`, `ruff`, `flake8`, `golangci-lint`
- **Build**: `npm run build`, `cargo build`, `go build`

### 2. Run Checks (in order)

1. **Type check** — catches the most bugs with fastest feedback
2. **Lint** — catch style and correctness issues
3. **Unit tests** — run the full suite, not just changed files
4. **Integration tests** — if they exist and are fast enough to run locally
5. **Build** — verify the project still compiles/bundles

### 3. Report Results

For each check:
- ✅ Pass — tool + summary
- ❌ Fail — tool + specific errors + suggested fix

If everything passes: "All checks pass. Changes verified."

If failures: prioritize by severity and suggest fixes.

## Gotchas

- **Only running unit tests**: If integration or e2e tests exist, skipping them means you might miss broken wiring between components. At minimum, mention they exist and offer to run them.
- **Not checking types**: A test suite can pass while the code has type errors that will break at runtime in other code paths. Always run type checking if available.
- **Verifying in wrong environment**: Make sure you're running checks against the right config. `NODE_ENV=test` vs `development` matters.
- **Assuming green tests = working code**: Tests only cover what they test. If there are no tests for the changed code path, say so explicitly rather than claiming verification.
