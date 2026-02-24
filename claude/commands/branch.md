---
description: Create a descriptive branch name from conversation context and check it out
allowed-tools: Bash, AskUserQuestion
---

# Branch Command

Creates a descriptive git branch prefixed with `apostolos/` based on the current conversation context (changes made, tasks discussed) and checks it out.

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

Store this as `CURRENT_BRANCH`.

**If the current branch is `main` or `master`**: Proceed directly to Step 3 (no confirmation needed — branching off main/master is the default safe path).

**If the current branch is anything else**: Use `AskUserQuestion` to confirm with the user:

> "You're currently on `<CURRENT_BRANCH>`, not main/master. Do you want to branch off this branch?"

Options:
1. **"Yes, branch off `<CURRENT_BRANCH>`"** — Continue to Step 3 using the current branch as the base.
2. **"No, switch to main/master first"** — Detect the main branch (`main` or `master`), run `git checkout <main-branch> && git pull`, then continue to Step 3.

## Main Workflow

### Step 3: Generate Branch Name

Analyze the conversation context to determine what work has been done or is being planned. Consider:
- Files that were modified or created
- The nature of the task (feature, fix, refactor, chore, etc.)
- Key terms from the discussion

**Branch name rules:**
- Prefix: `apostolos/`
- Use lowercase with underscores as separators (snake_case)
- Keep it concise but descriptive (3-5 words max after the prefix)
- No special characters beyond underscores
- Examples:
  - `apostolos/add_branch_skill`
  - `apostolos/fix_login_redirect`
  - `apostolos/refactor_helm_values`
  - `apostolos/update_zsh_aliases`

### Step 4: Create and Checkout the Branch

```bash
git checkout -b <branch-name>
```

If this fails because the branch already exists, append a short numeric suffix:

```bash
git checkout -b <branch-name>_2
```

### Step 5: Output Result

Display:
- The branch name created
- What branch it was created from
- A one-line summary of the inferred purpose

Example:
```
Created branch: apostolos/add_branch_skill
  Based on: main
  Purpose: Add /branch skill for auto-generating branch names
```
