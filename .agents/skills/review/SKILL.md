---
name: review
description: "Use when about to commit, or when asked to review uncommitted/staged changes for issues before they're committed."
---

# Code Review

Review uncommitted changes before committing. Catch issues early with multi-perspective analysis.

## Instructions

### Step 1: Gather Changes

Get all uncommitted changes (`git diff HEAD`). Include staged changes (`git diff --cached`). If no changes exist, stop.

### Step 2: Analyze Change Types

Classify changes: logic, data handling, configuration, UI/frontend, tests. This determines which contextual reviews to apply.

### Step 3: Developer Review (Always)

Evaluate from a senior engineer perspective: code quality, performance, best practices, logic errors.

### Step 4: Security Review (Always)

Check: injection risks, data handling, auth/authz, input validation gaps.

### Step 5: Contextual Reviews (When Relevant)

- Logic changes → test coverage
- Conditionals/loops → edge cases
- Data handling → data integrity
- Configuration → environment consistency

### Step 6: Integration Impact Check

When changes touch certain file types, check related files that may need updates:
- Routes/endpoints → CORS config, API docs, client code
- Auth/permissions → middleware, role definitions
- Env vars → deployment configs, CI/CD, docs
- API contracts → frontend clients, integration tests
- DB schema → migrations, seeds, related models
- Config files → environment overlays

Report files that still reference stale values.

### Step 7: Report Findings

See `references/review-format.md` for the output format template.

### Output Guidelines

- Focus on real issues, not style-only nitpicks
- Include specific file:line references
- Keep findings actionable
- If no issues exist, say: "No issues found. Ready to commit."
- Order by severity

## Gotchas

- **Reviewing only staged vs all changes**: `git diff --cached` only shows staged changes. If the user has unstaged work, you'll miss it. Always check both `git diff HEAD` and `git diff --cached`.
- **Missing cross-file impact**: A renamed function in one file breaks callers in others. Always grep for usages of changed symbols across the codebase.
- **Style nitpicking**: Don't flag formatting, naming preferences, or minor style issues if the project has a formatter. Focus on bugs, security, and logic errors. Style comments should be rare and high-value.
- **Hallucinating line numbers**: Double-check file:line references against the actual diff. Wrong line numbers destroy trust in the review.
