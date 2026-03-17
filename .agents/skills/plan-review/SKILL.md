---
name: plan-review
description: "Use when reviewing in-progress feature work, architecture decisions, or branch diffs — deeper than a pre-commit review."
---

# Plan Review

Interactive, section-by-section review for feature branches and architecture decisions.

Use this for planned/in-progress work. For pre-commit diff review, use the `review` skill.

## Workflow

### Step 0: Scope the Review

If user does not specify scope, detect it via:

```bash
git diff main...HEAD --name-only
```

Estimate review depth by size:
- Big change: 10+ files or 200+ lines -> full 4-section review
- Small change: below threshold -> quick pass (one key issue per section)

Confirm this with the user.

### Step 1: Architecture Review

Read changed files plus surrounding context (callers/importers/tests/sibling modules).
Evaluate:
1. Component boundaries
2. Data flow
3. API design
4. Pattern consistency

Present numbered issues with options (recommended + alternatives + tradeoff).
Wait for user decision before moving on.

### Step 2: Code Quality Review

Evaluate:
1. Readability
2. DRY opportunities (especially 3+ repeated patterns)
3. Complexity and simplification opportunities
4. Elegance for non-trivial changes
5. Error handling and failure modes

Present numbered issues/options and wait for response.

### Step 3: Test Review

Evaluate:
1. Coverage gaps
2. Edge cases (nulls, empties, boundaries, errors)
3. Test quality (behavior-focused)
4. Integration coverage

If no tests exist for changed logic, flag it as issue 1.
Present options and wait.

### Step 4: Performance Review

Evaluate:
1. Query efficiency
2. Memory and unbounded growth
3. Concurrency/blocking risks
4. Scaling risks

If no performance concerns exist, state that and move on.
Otherwise present options and wait.

### Step 5: Final Summary

Summarize:
- Decisions made per section
- Prioritized next steps

Then ask if the user wants implementation started.

## Output Rules

- Always include file:line references
- Be opinionated and recommend one option
- Keep depth proportional to change size
- Process one section at a time
- If a section has no issues, state that explicitly
