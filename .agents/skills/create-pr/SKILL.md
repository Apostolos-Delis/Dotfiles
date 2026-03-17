---
name: create-pr
description: "Use when work is ready to push and open a pull request, or when asked to create/submit a PR."
---

# Create PR

Automate staging, formatting, commit creation, push, and GitHub PR creation.

## Pre-flight Checks

1. Verify git repo and check current branch.
2. If on `main`/`master`, run the `branch` skill first.
3. If no changes exist, stop.

## Main Workflow

### 1. Stage and Format

Stage all changes. Detect and run project formatter (prettier, black, rubocop, etc.) on changed files, then re-stage.

### 2. Decide Commit Strategy

If changes span multiple logical units, split into focused commits. Otherwise, single commit.

Commit type guidance: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`.

### 3. Generate Commit Message

- Subject: imperative mood, ideally <= 50 chars
- Body only if needed for why/context
- No AI attribution or co-author lines

### 4. Self Review

Review `git diff main..HEAD` before creating PR:
- Quality/readability
- Security risks (secrets, validation, unsafe handling)
- Test coverage gaps

If issues found: offer to fix now, note in PR, or proceed anyway.

### 5. Push and Create PR

Push with `--set-upstream`, then create PR:

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

### 6. Output Result

Show: PR URL, commit summary, any unresolved review risks.

## Gotchas

- **Verbose commit messages**: Claude tends to write essay-length commit messages. Keep the subject under 50 chars. The body should be 1-3 lines max, not a changelog.
- **PR description hallucination**: Don't invent test results or claim testing that didn't happen. Only describe what was actually done.
- **Force-push on shared branches**: Never force-push without checking if others have pushed to the branch. Use `--force-with-lease` if rebasing was involved.
- **gh auth issues**: If `gh pr create` fails with auth errors, check `gh auth status` before retrying. Don't retry in a loop.
- **Forgetting to pull before push**: If the branch already exists on remote (e.g., from a previous push), pull or check for divergence first.
