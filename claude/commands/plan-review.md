---
description: Interactive 4-section review for features and architecture decisions in plan mode
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
---

# Plan Review

Interactive, section-by-section review for feature branches and architecture changes. Unlike `/review` (pre-commit), this is for evaluating planned or in-progress work at a higher level.

> **Philosophy**: Review in layers — architecture first, details last. Get alignment before going deep.

> **Engineering bar**: DRY (consolidate repetition), well-tested, "engineered enough" (fits problem size), handle edge cases, explicit > clever.

## Instructions

### Step 0: Scope the Review

If the user doesn't specify a branch or set of files, use `git diff main...HEAD --name-only` (or `master`) to identify what's changed.

Auto-detect scope based on the diff: count changed files and total lines changed. Suggest the appropriate depth, then confirm with the user via AskUserQuestion:

- **BIG CHANGE** (10+ files or 200+ lines): Full 4-section review, up to 4 issues per section
- **SMALL CHANGE** (under those thresholds): Quick pass, 1 question per section

### Step 1: Architecture Review

Read the changed files and their surrounding context. For each changed file, also read its callers/importers, related test files, and sibling modules to understand the full impact. Evaluate:

1. **Component boundaries** — Are responsibilities clearly separated? Any god objects or tangled dependencies?
2. **Data flow** — Is data flowing in a clear direction? Any circular dependencies or unnecessary coupling?
3. **API design** — Are interfaces clean and consistent? Will they be painful to evolve?
4. **Patterns** — Does this follow existing patterns in the codebase, or introduce new ones? If new, is that justified?

**Present findings as numbered issues.** For each issue, provide lettered options:

```
### 🏗️ Architecture

1. [Issue description with file:line references]
   a) [Recommended fix]
   b) [Alternative approach]
   c) Do nothing — [explain tradeoff]

2. [Next issue...]
```

Use AskUserQuestion to present the options and wait for the user's response before continuing.

### Step 2: Code Quality Review

Read implementation details. Evaluate:

1. **Readability** — Can a new developer follow this? Are names descriptive?
2. **DRY** — Is there repetition worth consolidating? (Threshold: 3+ occurrences or complex duplicated logic)
3. **Complexity** — Any deeply nested logic, long functions, or clever tricks that should be simplified?
4. **Elegance check** — For non-trivial changes: "is there a more elegant way?" If a fix feels hacky, flag it.
5. **Error handling** — Are failure modes covered? Are errors informative?

**Present findings the same way** — numbered issues with lettered options. Use AskUserQuestion and wait.

### Step 3: Test Review

Identify test files related to the changes. Evaluate:

1. **Coverage gaps** — Are new code paths tested? What's missing?
2. **Edge cases** — Are boundaries, nulls, empties, and error states tested?
3. **Test quality** — Are tests testing behavior (not implementation)? Are they readable?
4. **Integration** — If components interact, are those interactions tested?

If no tests exist for the changes, flag that as issue #1.

**Present findings the same way.** Use AskUserQuestion and wait.

### Step 4: Performance Review

Read code paths for performance concerns. Evaluate:

1. **Query efficiency** — N+1 queries, missing indexes, unbounded SELECTs?
2. **Memory** — Large allocations, unbounded collections, missing pagination?
3. **Concurrency** — Race conditions, missing locks, blocking operations?
4. **Scaling** — Will this work at 10x current load? Any O(n²) lurking?

If no performance concerns exist, say so and skip the AskUserQuestion for this section.

**Otherwise, present findings the same way.** Use AskUserQuestion and wait.

### Step 5: Final Summary

After all sections are complete, present a summary:

```
## Plan Review Summary

### Decisions Made
- **Architecture**: [outcome per issue]
- **Code Quality**: [outcome per issue]
- **Tests**: [outcome per issue]
- **Performance**: [outcome per issue]

### Prioritized Next Steps
1. [Most important action]
2. [Next action]
3. [...]
```

Then ask: "Want me to start working through these?" via AskUserQuestion.

## Output Guidelines

- **Be specific** — Always include file:line references
- **Be opinionated** — Recommend the best option, don't just list choices
- **Be proportional** — BIG CHANGE = thorough, SMALL CHANGE = focused
- **One section at a time** — Never skip ahead. Wait for user feedback before proceeding.
- **No filler** — If a section has no issues, say "No issues found" and move on
