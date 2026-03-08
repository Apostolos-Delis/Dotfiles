---
name: rebase
description: Rebase the current branch onto main/master, resolve conflicts, and push safely.
---

# Rebase

Rebase the current branch onto the latest main branch and handle conflicts safely.

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

If branch is `main` or `master`, tell user: "ERROR: You are already on the main branch. Nothing to rebase." and stop.

### Step 3: Check Clean Working Tree

```bash
git status --porcelain
```

If there are uncommitted changes, stop and ask user to commit or stash first.

### Step 4: Detect Base Branch

```bash
git rev-parse --verify main 2>/dev/null && echo "main" || git rev-parse --verify master 2>/dev/null && echo "master"
```

If neither exists locally, check remote:

```bash
git ls-remote --heads origin main 2>/dev/null | grep -q main && echo "main" || git ls-remote --heads origin master 2>/dev/null | grep -q master && echo "master"
```

If no base is found, report error and stop.

### Step 5: Fetch Latest

```bash
git fetch origin
```

## Rebase Workflow

### Step 6: Start Rebase

```bash
git rebase origin/<BASE_BRANCH>
```

If no conflicts, continue to Step 8.

### Step 7: Resolve Conflicts Loop

List unresolved files:

```bash
git diff --name-only --diff-filter=U
```

For each conflicted file:
1. Inspect stages:

```bash
git show :1:<file>
git show :2:<file>
git show :3:<file>
```

2. Resolve conflict with merged intent.
3. Remove conflict markers.
4. Stage file:

```bash
git add <file>
```

Continue rebase:

```bash
git rebase --continue
```

Repeat until complete.

If semantic conflict needs product judgment, ask user to choose direction.

### Step 8: Verify Result

```bash
git log --oneline -5
git status
```

Confirm branch is out of rebase state and based on latest main/master.

### Step 9: Optional Test Validation

If project test command is known, offer to run it and report outcome.

### Step 10: Push Safely

```bash
git push --force-with-lease
```

If lease is rejected, report that remote changed and user should coordinate before forcing.

### Step 11: Output Summary

Report:
- Number of commits rebased
- Number of conflicts resolved
- Files with conflicts
- Push status

## Safety

- This rewrites history and force-pushes
- Prefer `--force-with-lease` only (never `--force`)
- If needed, abort with `git rebase --abort`
