---
name: branch
description: "Use when starting new work and need a properly named feature branch, or when on main/master and about to make changes."
---

# Branch

Create a descriptive git branch prefixed with `apostolos/` based on conversation context and check it out.

## Workflow

### 1. Pre-flight

Verify you're in a git repo. Check the current branch.

- If on `main`/`master`: continue — this is the expected starting point.
- If on another branch: ask whether to branch off it or switch to main/master first.

### 2. Generate Branch Name

Infer the branch name from work context (files changed, task type, key terms).

**Naming rules:**
- Prefix: `apostolos/`
- Lowercase snake_case
- Concise but descriptive (3-5 words after prefix)
- No special characters beyond underscores

Examples:
- `apostolos/add_branch_skill`
- `apostolos/fix_login_redirect`
- `apostolos/refactor_helm_values`
- `apostolos/update_zsh_aliases`

### 3. Create and Checkout

Create and switch to the new branch. If the name already exists, append `_2`.

### 4. Output Result

Display:
- Created branch name
- Base branch used
- One-line inferred purpose
