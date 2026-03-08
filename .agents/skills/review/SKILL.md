---
name: review
description: Review uncommitted changes before committing and report concrete findings by severity.
---

# Code Review

Review uncommitted changes before committing. Catch issues early with multi-perspective analysis.

## Instructions

### Step 1: Gather Changes

Get all uncommitted changes:

```bash
git diff HEAD
```

If there are staged changes, also check:

```bash
git diff --cached
```

If no changes exist, tell the user: "No uncommitted changes to review." and stop.

### Step 2: Analyze Change Types

Before reviewing, identify what types of changes are present:
- Logic changes: New functions, modified algorithms, conditional changes
- Data handling: Database queries, API calls, file I/O
- Configuration: Environment variables, config files, dependencies
- UI/Frontend: Templates, styles, client-side code
- Tests: Test files, test utilities

This determines which contextual reviews to apply.

### Step 3: Developer Review (Always Applied)

Evaluate the code from a senior engineer perspective:
1. Code quality and maintainability
2. Performance
3. Best practices
4. Logic errors

### Step 4: Security Review (Always Applied)

Check for security vulnerabilities:
1. Injection risks
2. Data handling risks
3. Authentication and authorization risks
4. Input validation gaps

### Step 5: Contextual Reviews (When Relevant)

If logic changes are present, review test coverage.
If conditionals/loops are present, review edge cases.
If data handling changes are present, review data integrity.
If configuration changes are present, review environment consistency.

### Step 6: Integration Impact Check

When changes touch certain file types, check related files that may also need updates:
- Routes/endpoints: CORS config, API docs, client code
- Auth/permissions: Entry points, middleware, role definitions
- Env vars: Deployment configs, CI/CD, documentation
- API paths/contracts: Frontend clients, API docs, integration tests
- Database schema: Migrations, seeds, related models
- Config files: Environment overlays (`staging.yaml`, `production.yaml`)

Report files that still reference stale values.

### Step 7: Report Findings

Use this format:

```text
## Review Summary

[Brief overview of changes and overall assessment]

### Findings

CRITICAL (must fix before commit)
- [file:line] Issue description
  -> Fix: Suggested solution

WARNING (should fix)
- [file:line] Issue description
  -> Fix: Suggested solution

SUGGESTION (optional improvement)
- [file:line] Issue description
  -> Consider: Alternative approach

GOOD (positive observations)
- [file] Positive observation

---
Summary: X critical, Y warnings, Z suggestions
Recommendation: [Ready to commit / Fix critical issues first / Consider warnings]
```

### Output Guidelines

- Focus on real issues, not style-only nitpicks
- Include specific file:line references
- Keep findings actionable
- If no issues exist, say: "No issues found. Ready to commit."
- Order by severity
