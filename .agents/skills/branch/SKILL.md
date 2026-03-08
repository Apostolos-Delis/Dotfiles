---
name: branch
description: Create a descriptive git branch name from context and check it out.
---

# Branch

Create a descriptive git branch prefixed with `apostolos/` based on conversation context and check it out.

## Workflow

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

If current branch is `main` or `master`, continue.

If current branch is not `main`/`master`, ask the user whether to branch off `CURRENT_BRANCH` or switch to main/master first.
- If switching is chosen, detect `main` or `master`, then run:

```bash
git checkout <main-branch> && git pull
```

### Step 3: Generate Branch Name

Infer the branch name from work context (files changed, task type, key terms).

Branch rules:
- Prefix: `apostolos/`
- Lowercase snake_case
- Concise but descriptive (3-5 words after prefix)
- No special characters beyond underscores

Examples:
- `apostolos/add_branch_skill`
- `apostolos/fix_login_redirect`
- `apostolos/refactor_helm_values`
- `apostolos/update_zsh_aliases`

### Step 4: Create and Checkout

```bash
git checkout -b <branch-name>
```

If the branch already exists, append a suffix:

```bash
git checkout -b <branch-name>_2
```

### Step 5: Output Result

Display:
- Created branch name
- Base branch used
- One-line inferred purpose
