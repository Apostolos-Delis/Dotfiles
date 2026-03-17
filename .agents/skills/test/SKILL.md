---
name: test
description: "Use when asked to write, generate, or add tests for a file, function, or module."
---

# Generate Tests

Generate tests for the specified file or function.

## Instructions

1. Read the file or function specified by the user.
2. Identify the testing framework used in the project:
   - Python: `pytest`, `unittest`
   - JavaScript/TypeScript: `jest`, `vitest`, `mocha`
   - Ruby: `rspec`, `minitest`
3. Generate tests covering:
   - Happy paths
   - Edge cases (empty inputs, null values, boundaries)
   - Error conditions
   - Existing project test patterns
4. Follow the project's test file structure and naming conventions.
5. Include setup/teardown when needed.
6. Use descriptive test names.

## Gotchas

- **Over-mocking**: Don't mock everything. If you mock the thing you're testing, you're testing the mock. Only mock external dependencies (network, DB, filesystem) — not internal collaborators unless there's a good reason.
- **Testing implementation, not behavior**: Tests that assert internal method calls or private state break on every refactor. Test inputs → outputs and observable side effects.
- **Ignoring project test patterns**: Look at existing tests first. If the project uses factories, use factories. If it uses `describe`/`it` blocks, don't switch to `test()`. Match the style.
- **Missing test runner config**: Don't assume `pytest` or `jest` works out of the box. Check for config files (`jest.config.*`, `pytest.ini`, `pyproject.toml`) and run the test suite once to verify your tests actually execute.
- **Brittle assertions on output format**: Don't assert exact error messages or log output unless that's the contract. These break on minor wording changes.
