---
description: Rebase current branch onto main/master, resolve conflicts, and force push
allowed-tools: Read, Bash, Glob, Grep, Edit
---

# Rebase Command

Rebases the current branch onto the main branch (main or master) and automatically resolves any git conflicts that arise.

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

Store this as the current branch name.

**CRITICAL**: If the branch is `main` or `master`, tell the user: "ERROR: You are already on the main branch. Nothing to rebase." and stop.

### Step 3: Check for Uncommitted Changes

```bash
git status --porcelain
```

If there are uncommitted changes, tell the user: "ERROR: You have uncommitted changes. Please commit or stash them first." and stop.

### Step 4: Detect Main Branch

Determine which branch to rebase onto:

```bash
git rev-parse --verify main 2>/dev/null && echo "main" || git rev-parse --verify master 2>/dev/null && echo "master"
```

If neither exists, check remote:

```bash
git ls-remote --heads origin main 2>/dev/null | grep -q main && echo "origin/main" || git ls-remote --heads origin master 2>/dev/null | grep -q master && echo "origin/master"
```

If no main branch can be found, tell the user: "ERROR: Could not find main or master branch" and stop.

Store the detected branch as `BASE_BRANCH`.

### Step 5: Fetch Latest from Remote

```bash
git fetch origin
```

## Main Workflow

### Step 6: Start the Rebase

```bash
git rebase origin/<BASE_BRANCH>
```

If the rebase completes without conflicts, skip to Step 10.

### Step 7: Handle Conflicts (Loop)

When conflicts occur, git will pause the rebase. For each conflict:

#### 7.1: Identify Conflicting Files

```bash
git diff --name-only --diff-filter=U
```

#### 7.2: For Each Conflicting File

1. Read the file contents to understand the conflict:
   ```bash
   git show :1:<file>  # common ancestor
   git show :2:<file>  # ours (current branch)
   git show :3:<file>  # theirs (main branch)
   ```

2. Read the current file with conflict markers to see the full context

3. **Resolution Strategy**:
   - Analyze both versions and the ancestor to understand the intent
   - If the changes are in different parts of the file: merge both changes
   - If the changes overlap but are compatible: combine them logically
   - If the changes conflict semantically: prefer the main branch version but preserve any unique functionality from the feature branch
   - Remove all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)

4. Use the Edit tool to resolve the conflict in the file

5. Stage the resolved file:
   ```bash
   git add <file>
   ```

#### 7.3: Continue the Rebase

After resolving all conflicts for the current commit:

```bash
git rebase --continue
```

If more conflicts arise, repeat Step 7. If the rebase is complete, continue to Step 8.

### Step 8: Verify Rebase Success

```bash
git log --oneline -5
git status
```

Confirm that:
- The branch is no longer in a rebase state
- The commits are now based on the latest main

### Step 9: Check for Build/Test Issues (Optional)

If the project has a known test command (from package.json, Makefile, etc.), offer to run it:

```bash
# Examples:
npm test
pytest
bundle exec rspec
make test
```

Tell the user if tests pass or fail after the rebase.

### Step 10: Push with Force-With-Lease

Push the rebased branch to the remote:

```bash
git push --force-with-lease
```

This safely force-pushes the rebased commits. The `--force-with-lease` flag ensures we don't overwrite any commits on the remote that we haven't seen locally.

If the push fails due to lease rejection, tell the user: "Push rejected - the remote has commits you don't have locally. Someone may have pushed to this branch. Please check with your team before force pushing."

### Step 11: Output Result

Display:
- Number of commits rebased
- Number of conflicts resolved (if any)
- Files that had conflicts resolved
- Push status

Example output:
```
Rebase complete!

Rebased 3 commits onto origin/main
Resolved 2 conflicts:
  - src/utils/helper.ts (merged both changes)
  - src/api/client.ts (preserved main's refactor + feature additions)

Pushed to origin/<current-branch> (force-with-lease)
```

## Conflict Resolution Guidelines

### Code Conflicts

- **Import statements**: Include all unique imports from both versions
- **Function changes**: If both modified the same function, understand what each change does and combine if possible
- **Configuration files**: Merge all unique entries, prefer main for shared keys
- **Package.json/lockfiles**: After resolution, may need to run `npm install` or equivalent

### When to Ask for Help

If you encounter:
- Conflicts that fundamentally change the feature's behavior
- Deleted files that the feature branch depends on
- Semantic conflicts that can't be automatically resolved

Tell the user: "This conflict requires human judgment: [explain the situation]" and provide options:
1. "Accept main's version" - discard feature branch changes for this file
2. "Accept feature's version" - keep feature branch changes
3. "Manual resolution" - show both versions and let user decide

## Safety Notes

- This command modifies git history and force pushes to the remote
- Uses `--force-with-lease` to prevent overwriting unseen remote commits
- If anything goes wrong during rebase, the user can abort with `git rebase --abort`
- Always fetches before rebasing to ensure we're rebasing onto the latest

## Command Options

- `--abort`: Abort an in-progress rebase
- `--continue`: Continue after manually resolving conflicts
