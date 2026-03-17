---
name: rebase
description: "Use when a feature branch needs to be updated with the latest main/master, or when asked to rebase."
---

# Rebase

Rebase the current branch onto the latest main branch and handle conflicts safely.

## Pre-flight

Verify: in a git repo, not on main/master, clean working tree. Detect the base branch (main or master) and fetch latest.

## Rebase Workflow

### 1. Start Rebase

Rebase onto `origin/<base>`. If no conflicts, skip to verification.

### 2. Resolve Conflicts

For each conflicted file, inspect all three stages to understand intent:

```bash
git show :1:<file>   # common ancestor
git show :2:<file>   # ours (current branch)
git show :3:<file>   # theirs (base branch)
```

Resolve with merged intent, stage, and continue. If a conflict requires product judgment, ask the user.

### 3. Verify Result

Confirm the branch is clean and based on latest main/master. Review the log.

### 4. Test Validation

If project test command is known, offer to run it and report outcome.

### 5. Push Safely

```bash
git push --force-with-lease
```

If rejected, report that the remote changed — user should coordinate before forcing.

### 6. Output Summary

Report: commits rebased, conflicts resolved, files affected, push status.

## Safety

- **Always** `--force-with-lease`, **never** `--force`
- If things go wrong: `git rebase --abort`

## Gotchas

- **Rebasing with uncommitted work**: Always check for a clean working tree first. Stashing "just to rebase" often leads to stash-pop conflicts on top of rebase conflicts.
- **Losing commits during conflict resolution**: When resolving conflicts, `git rebase --continue` with an empty diff silently drops that commit. Always verify commit count before and after.
- **Rebasing shared/public branches**: If others have based work on this branch, rebasing rewrites their history too. Ask before rebasing branches with open PRs that have reviewers' comments.
- **Conflict resolution amnesia**: After resolving 5+ conflicts, it's easy to introduce bugs. Run tests after rebase, not just before pushing.
