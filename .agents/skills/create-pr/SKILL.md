---
name: create-pr
description: Stage, commit (with optional logical splitting), push, and create a GitHub PR with a filled description.
---

# Create PR

Automate staging, formatting, commit creation, push, and GitHub PR creation.

## Pre-flight Checks

### Step 1: Verify Git Repository

```bash
git rev-parse --git-dir > /dev/null 2>&1
```

If this fails, tell the user: "ERROR: This is not a git repository" and stop.

### Step 2: Check Current Branch

```bash
git symbolic-ref --short -q HEAD
```

If the branch is `main` or `master`, run the `branch` skill first to create a feature branch, then continue.

### Step 3: Check for Changes

```bash
git status --porcelain
```

If there are no changes, tell the user: "No changes to commit." and stop.

## Main Workflow

### Step 4: Stage All Changes

```bash
git add --all
```

### Step 5: Analyze Diffs and Context

```bash
git diff --cached --stat
git diff --cached
git log main..HEAD --oneline 2>/dev/null || echo "No prior commits on this branch"
```

### Step 5.1: Auto-format Changed Files

Detect formatter/language tooling and run formatter on changed files:
- JS/TS: `npx prettier --write ...`
- Python: `black ... && isort ...`
- Ruby: `bundle exec rubocop -a ...`

Then re-stage:

```bash
git add --all
```

If no formatter is detected, skip.

### Step 5.5: Decide Commit Strategy

Decide if changes should be split into multiple commits based on logical units.

If split is needed:
1. Explain split plan to user
2. Unstage all:

```bash
git reset
```

3. For each logical unit:
- `git add <related-files>`
- Commit with focused message

Commit type guidance: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`.

If single logical unit, continue to Step 6.

### Step 6: Generate Commit Message

Create concise, imperative commit message.
- Subject ideally <= 50 chars
- Add body only if needed for why/context
- Do not add AI attribution or co-author lines

### Step 7: Commit

```bash
git commit -m "$(cat <<'EOFMSG'
<subject>

<optional body>
EOFMSG
)"
```

If commit fails:

```bash
git reset
```

Then stop.

### Step 7.5: Self Review

Review branch diff before PR:

```bash
git diff main..HEAD
```

Check:
- Developer quality/readability
- Security risks (secrets, validation, unsafe handling)
- Test coverage and edge cases

If issues found, present options:
1. Fix now
2. Note in PR
3. Proceed anyway

### Step 8: Push Branch

```bash
git push --set-upstream origin $(git symbolic-ref --short HEAD)
```

### Step 9: Create GitHub PR

Create PR with structured body:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOFPR'
## Context

<2-4 bullets on what changed and why>

## Test Plan

<how this was tested>

## Mitigation

<impact and rollback>

## Checklist

- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to external documentation if necessary (READMEs, Confluence, etc.)
- [ ] I have checked that other PRs this PR depends on have already been deployed.
- [ ] I can confirm that if this PR introduces a DB schema change, I have read and followed all the steps outlined in the [Data Contract](https://docs.google.com/document/d/1g_ZZ8TU58Dh2Fn_6aNHktBUNdnBtYNuOyu3GY-kGHnk/edit#heading=h.o2ce6n1q3gpb).
EOFPR
)"
```

### Step 10: Output Result

After success, show:
- PR URL
- Commit summary
- Any unresolved review risks noted during self-review
