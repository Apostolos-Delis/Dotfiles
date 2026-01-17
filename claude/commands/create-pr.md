---
description: Stage, commit (with intelligent splitting), push, and open a GitHub PR with auto-filled description
allowed-tools: Read, Bash, Glob, Grep
---

# Create PR Command

Automates the workflow of staging changes, auto-formatting, intelligently splitting commits, self-reviewing, pushing, and opening a GitHub PR with a properly filled-in description.

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

**CRITICAL**: If the branch is `main`, tell the user: "ERROR: You are on the main branch. Please create a feature branch first." and stop.

### Step 3: Check for Changes

```bash
git status --porcelain
```

If there are no changes (output is empty), tell the user: "No changes to commit." and stop.

## Main Workflow

### Step 4: Stage All Changes

```bash
git add --all
```

### Step 5: Analyze the Diff

Get the staged diff to understand what changed:

```bash
git diff --cached --stat
git diff --cached
```

Also check recent commits on this branch vs main to understand full PR context:

```bash
git log main..HEAD --oneline 2>/dev/null || echo "No prior commits on this branch"
```

### Step 5.1: Auto-Format Changed Files

Detect project tooling and run the appropriate formatter on staged files:

**Detection & Execution:**

1. **TypeScript/JavaScript** - Check for prettier config:
   ```bash
   # If .prettierrc, prettier.config.js, or package.json has prettier
   npx prettier --write <changed-files>
   ```

2. **Python** - Check for Python tooling:
   ```bash
   # If pyproject.toml with black, or .flake8
   black <changed-python-files> && isort <changed-python-files>
   ```

3. **Ruby** - Check for rubocop:
   ```bash
   # If .rubocop.yml or Gemfile includes rubocop
   bundle exec rubocop -a <changed-ruby-files>
   ```

**After formatting**: Re-stage any files that were modified:
```bash
git add --all
```

If no formatter is detected, skip this step silently.

### Step 5.5: Determine Commit Strategy

Analyze the staged diff to determine if changes should be split into multiple commits.

**Split Criteria - Ask yourself:**
- Are there different concerns? (e.g., refactor vs feature vs fix)
- Are there changes to unrelated components/modules?
- Are test additions mixed with implementation?
- Are documentation changes mixed with code changes?
- Are dependency updates mixed with feature code?

**If multiple logical units are detected:**

1. Inform the user: "I've identified N distinct logical changes. I'll create separate commits for each."

2. Reset the staging area:
   ```bash
   git reset
   ```

3. For each logical unit:
   a. Stage only related files:
      ```bash
      git add <files-for-this-unit>
      ```
   b. Create a focused commit with a descriptive message (see Step 6 format)
   c. Repeat for remaining changes

4. Continue to Step 7.5 (Self-Review)

**If single logical unit:**
Continue to Step 6 (Generate Commit Message)

**Commit Type Guidelines (for split commits):**
- `feat`: New feature or capability
- `fix`: Bug fix
- `refactor`: Code restructuring without behavior change
- `test`: Adding or updating tests
- `docs`: Documentation only
- `style`: Formatting, whitespace (no code change)
- `chore`: Dependencies, configs, tooling

### Step 6: Generate Commit Message

Based on the diff analysis, generate a **concise commit message** that:
- Has a clear, descriptive subject line (50 chars or less ideally)
- Optionally includes a body explaining the "why" if the changes are complex
- Focuses on what changed and why
- Uses imperative mood ("Add feature" not "Added feature")

**IMPORTANT**: This is the user's work. Do NOT add any Claude attribution, "Generated with Claude Code" footer, or Co-Authored-By lines. The commit should appear as if the user wrote it themselves.

### Step 7: Create the Commit

Use a HEREDOC to create the commit:

```bash
git commit -m "$(cat <<'EOF'
<subject line>

<optional body>
EOF
)"
```

If the commit fails, reset and stop:

```bash
git reset
```

### Step 7.5: Self-Review (Multi-Perspective)

Before creating the PR, conduct a brief self-review of all commits on this branch:

```bash
git diff main..HEAD
```

**Developer Review:**
- Is the code structured for readability and maintainability?
- Are there any obvious performance issues?
- Does it follow the project's coding conventions?

**Security Review:**
- No hardcoded secrets, API keys, or credentials?
- Proper input validation where needed?
- Safe data handling (no SQL injection, XSS risks)?

**Test Coverage Review:**
- Are the changes adequately tested?
- Have edge cases been considered?
- Will existing tests still pass?

**If issues are found:**

Tell the user what you found and offer options:
1. "Fix now" - Make the corrections before creating the PR
2. "Note in PR" - Add the issues to the PR description for reviewer awareness
3. "Proceed anyway" - Continue without changes (user's choice)

If no issues found, continue to Step 8.

### Step 8: Push the Branch

Since we verified we're not on main, push with upstream tracking:

```bash
git push --set-upstream origin $(git symbolic-ref --short HEAD)
```

### Step 9: Create GitHub PR

Use the `gh` CLI to create a PR with the filled-in template.

Analyze all changes (both the new commit(s) and any prior commits on the branch) to fill in:

1. **Context**: Summarize what changes are being made and why
2. **Test Plan**: Based on the changes, describe how they were/should be tested
3. **Mitigation**: Estimate impact and rollback strategy
4. **Checklist**: Leave unchecked for user to verify

```bash
gh pr create --title "<PR title based on changes>" --body "$(cat <<'EOF'
## Context

<2-4 bullet points describing what changed and why>

## Test Plan

<How these changes were tested or should be tested>

## Mitigation

<Impact assessment and rollback strategy>

## Checklist

- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to external documentation if necessary (READMEs, Confluence, etc.)
- [ ] I have checked that other PRs this PR depends on have already been deployed.
- [ ] I can confirm that if this PR introduces a DB schema change, I have read and followed all the steps outlined in the [Data Contract](https://docs.google.com/document/d/1g_ZZ8TU58Dh2Fn_6aNHktBUNdnBtYNuOyu3GY-kGHnk/edit#heading=h.o2ce6n1q3gpb).
EOF
)"
```

### Step 10: Output Result

After successful PR creation, display:
- The PR URL
- A brief summary of commits created
- Any issues noted during self-review (if applicable)

## Guidelines for Filling in PR Description

### Context Section
- Be specific about what files/features changed
- Explain the motivation (bug fix, new feature, refactor, etc.)
- Use bullet points for clarity
- If commits were split, summarize the logical groupings

### Test Plan Section
- For Ruby changes: mention if rspec tests were added/run
- For frontend changes: mention manual testing or Jest tests
- For GraphQL changes: mention if schema was regenerated
- For Python changes: mention pytest tests
- If no tests: be honest and note "Manual testing" or "Needs tests"

### Mitigation Section
- Low risk: "Low impact, affects only [specific area]. Can be reverted with a simple revert commit."
- Medium risk: "Moderate impact on [area]. Rollback via revert, monitor [specific metrics]."
- High risk: "Significant changes to [critical system]. Recommend staged rollout. Rollback plan: [steps]."
- For DB migrations: Note if they're reversible

## Example Usage

User runs `/create-pr` after making changes that include a new feature and a refactor.

Output:
```
Staged 5 files
Auto-formatted 3 Python files with black/isort

Detected 2 logical units:
  1. Refactor: Extract validation logic to separate module
  2. Feature: Add borrower income verification endpoint

Created commits:
  - refactor: Extract validation logic to income_validation.py
  - feat: Add borrower income verification endpoint

Self-review complete - no issues found

Pushed to origin/feature/income-verification
Created PR: https://github.com/opendoor-labs/mortgages/pull/123

Summary:
- Refactored validation logic into reusable module
- Added new GraphQL mutation for income verification
- Created Income::Verify interaction
- Added specs for the new endpoint
```

## Command Options

- `--no-format`: Skip auto-formatting step
- `--no-split`: Force single commit (don't split)
- `--no-review`: Skip self-review step
