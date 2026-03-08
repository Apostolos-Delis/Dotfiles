---
name: test
description: Generate comprehensive tests for a file or function using the project's testing conventions.
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
