---
description: End-to-end ship workflow — merge main, run tests, review diff, commit (bisectable), push, and open PR
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion
---

# Ship: End-to-End Ship Workflow

You are running the `/ship` workflow. This is a **non-interactive, fully automated** workflow. Do NOT ask for confirmation at any step unless specified. The user said `/ship` — DO IT.

**Only stop for:**
- On `main`/`master` branch (abort)
- Merge conflicts that can't be auto-resolved
- Test failures
- CRITICAL issues in the pre-landing review

**Never stop for:**
- Uncommitted changes (always include them)
- Commit message approval (auto-generate)
- Multi-file changesets (auto-split into bisectable commits)

---

## Step 1: Pre-flight

1. Check the current branch. If on `main` or `master`, **abort**: "You're on main. Ship from a feature branch."
2. Run `git status`. Uncommitted changes are always included.
3. Run `git diff main...HEAD --stat` and `git log main..HEAD --oneline` to understand what's being shipped.

---

## Step 2: Merge origin/main

Fetch and merge `origin/main` into the feature branch so tests run against the merged state:

```bash
git fetch origin main && git merge origin/main --no-edit
```

If there are merge conflicts, try to auto-resolve simple ones. If complex or ambiguous, **STOP** and show them.

---

## Step 3: Run tests

Detect and run the project's test suite:

- **Ruby/Rails**: Look for `bin/rails test`, `bundle exec rspec`, `bin/test-lane`, or `rake test`
- **JavaScript/TypeScript**: Look for `npm test`, `yarn test`, `bun test`, `npx vitest`
- **Python**: Look for `pytest`, `python -m pytest`
- **Go**: `go test ./...`

Run whatever test commands are appropriate for the project. If multiple suites exist (e.g., Rails + Vitest), run them in parallel.

**If any test fails:** Show the failures and **STOP**. Do not proceed.
**If all pass:** Note the counts briefly and continue.

---

## Step 4: Pre-Landing Review

Review the diff for structural issues that tests don't catch:

```bash
git fetch origin main --quiet
git diff origin/main
```

Scan for:
- **SQL safety**: Raw SQL, missing indexes on new columns, N+1 patterns
- **Security**: Unsanitized input, missing auth checks, hardcoded secrets
- **Trust boundaries**: LLM output used without validation, user input in dangerous contexts
- **Race conditions**: Concurrent access to shared state without protection
- **Silent failures**: Rescued exceptions that swallow errors without logging
- **Dead code**: Unreachable branches, unused imports/variables

**If CRITICAL issues found:** For EACH critical issue, use AskUserQuestion with:
- The problem (file:line + description)
- Your recommended fix
- Options: A) Fix it now, B) Acknowledge and ship anyway, C) False positive — skip

**If no critical issues:** Continue.

---

## Step 5: Commit (bisectable chunks)

Split changes into logical, bisectable commits. Each commit = one coherent change.

**Commit ordering** (earlier first):
1. Infrastructure: migrations, config, routes
2. Models & services (with their tests)
3. Controllers & views (with their tests)
4. Documentation updates

**Rules:**
- A file and its test go in the same commit
- Each commit must be independently valid (no broken imports)
- If total diff is small (<50 lines, <4 files), a single commit is fine
- Format: `<type>: <summary>` (feat/fix/chore/refactor/docs)
- Add `Co-Authored-By: Claude <noreply@anthropic.com>` to the final commit

---

## Step 6: Push

```bash
git push -u origin $(git branch --show-current)
```

---

## Step 7: Create PR

Use the `/create-pr` skill patterns — create a PR with `gh pr create`:

```bash
gh pr create --title "<type>: <summary>" --body "$(cat <<'EOF'
## Summary
<bullet points of changes>

## Pre-Landing Review
<findings from Step 4, or "No issues found.">

## Test Results
- [x] Tests pass (N tests, 0 failures)

🤖 Generated with Claude Code
EOF
)"
```

**Output the PR URL** — this is the final output the user sees.

---

## Important Rules

- **Never skip tests.** If tests fail, stop.
- **Never force push.** Regular `git push` only.
- **Never ask for confirmation** except for CRITICAL review findings.
- **The goal is: user says `/ship`, next thing they see is the PR URL.**
