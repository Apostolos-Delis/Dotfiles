---
name: fix-pr-checks
description: Find the PR for the current branch, inspect failing GitHub Actions checks and workflow runs, diagnose the root cause, fix repository-side problems, validate locally, then commit and push.
argument-hint: [pr-number-or-url]
allowed-tools: Read, Bash, Glob, Grep, Edit, Write
disable-model-invocation: true
---

# Fix PR Checks

Diagnose and fix failing GitHub PR checks for the current branch.

## Supporting File

Use `scripts/collect_pr_checks.py` to gather:
- current branch and HEAD SHA
- repository and PR metadata
- PR check status
- recent workflow runs for the current branch and SHA
- candidate run matches for problematic checks

Use this shell setup before calling the helper:

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.claude/skills/fix-pr-checks}"
if [ ! -d "$SKILL_DIR" ]; then
  SKILL_DIR=".agents/skills/fix-pr-checks"
fi
CHECKS_FILE="$(mktemp -t fix-pr-checks.XXXXXX.json)"
```

If `$ARGUMENTS` is present, pass it as the helper's single argument. If not, omit the argument so the helper auto-detects the PR from the current branch.

## Goal

1. Identify the PR for the current branch.
2. Discover all failing or otherwise problematic checks for that PR.
3. Inspect the relevant workflow runs, failed jobs, and logs.
4. Reproduce the failure locally when possible.
5. Fix the root cause in the repository.
6. Run the narrowest useful local validation.
7. Commit and push the fix if code changed.
8. Report exactly what was fixed and what remains blocked.

## Hard Rules

- Do not blindly rerun CI and call it fixed.
- Fix the real cause instead of patching symptoms.
- Make the smallest correct change.
- Do not weaken tests, lint rules, type checks, or build requirements just to get green CI unless the user explicitly asks.
- If the failure is external or environmental, say so clearly instead of pretending it is fixable in the repo.
- Never force-push unless the user explicitly asks.
- Do not create an empty commit.
- Do not declare success just because a narrow local command passed. If the fresh SHA has not passed CI yet, say that explicitly.

## Step 1: Collect Normalized Check Data

Run the bundled helper and inspect the JSON it returns. The JSON includes:
- `repository`
- `branch`
- `pull_request`
- `counts`
- `checks`
- `problem_checks`
- `runs`
- `failing_runs`

Stop immediately if:
- there is no PR for the branch
- GitHub access fails
- the helper cannot gather check data

If there are no problematic checks, stop and report that nothing currently needs fixing.

## Step 2: Build the Work Checklist

Create a checklist with one row per problematic check. Capture:
- check name
- workflow name
- bucket and state
- description and link
- likely category: `test`, `lint`, `typecheck`, `build`, `docker`, `deploy`, `security`, `infra`, or `unknown`
- candidate workflow runs from the helper
- status: `todo`, `doing`, `done`, `blocked`, or `skipped`

Prioritize in this order:
1. setup, install, or build graph failures
2. type errors
3. lint or formatting
4. tests
5. packaging, docker, or deploy

Ignore passing checks. Only include pending checks if they look stuck or are needed to confirm the fix.

## Step 3: Inspect Relevant Runs and Logs

For each checklist item, inspect the most relevant run first:

```bash
gh run view RUN_ID --json databaseId,name,workflowName,status,conclusion,url,jobs
gh run view RUN_ID --log-failed
```

If failed-step logs are insufficient, inspect the full log:

```bash
gh run view RUN_ID --log
```

Identify:
- failing job name
- failing step name
- exact error message
- likely root cause

Do not stop at the first red line if an earlier error explains the failure better.

## Step 4: Read the Actual Workflow and Repo Code

Before changing anything, read:
- the relevant workflow YAML under `.github/workflows/` when applicable
- any scripts the workflow invokes
- the code or tests involved in the failure
- project tooling files like `package.json`, `Makefile`, `pyproject.toml`, or equivalent if they define the failing command

If the failing log names a file and line, read that exact location first.

If the failure involves a specific symbol, column, file path, script name, or environment assumption, grep for all related references before editing. Do not stop after the first hit if the same pattern can exist in specs, helpers, support code, or workflow scripts.

## Step 5: Reproduce Locally

Reproduce the narrowest failing target locally when possible:
- specs or tests: run the exact file, package, or command first
- lint: run the relevant linter on the affected files or package
- typecheck: run the relevant type checker for the affected package
- build: run the relevant build target
- docker: run the same Docker build command or the closest equivalent from the workflow
- workflow script failure: run the script locally with the same arguments when possible

If the failure is clearly caused by missing secrets, permissions, runner issues, or external outages, do not invent a local repro. Mark it as blocked and explain why.

If the CI error suggests local environment drift, validate in a cleaner environment before trusting a green result. Examples:
- undefined column, missing table, or schema mismatch: recreate or reset the test database from the repository state
- missing file or generated artifact: clean untracked/generated files and rerun
- dependency mismatch: reinstall from the lockfile or CI-equivalent command

If a narrow repro passes locally but the CI failure indicates a broader shared pattern, expand immediately to the full affected suite or family instead of pushing.

## Step 6: Fix the Root Cause

Make the smallest correct fix. Valid fixes include:
- code bugs causing failing tests
- stale fixtures or snapshots when behavior legitimately changed
- missing imports, types, or interfaces
- broken build scripts or repository paths
- Docker context or copy issues caused by repository contents
- legitimate stabilization of a flaky test
- workflow YAML fixes when the workflow itself is wrong

Invalid fixes unless explicitly justified:
- deleting or weakening tests
- adding sleeps blindly
- swallowing real errors
- disabling checks
- replacing assertions with trivial truths

After the first fix, search for sibling occurrences of the same broken pattern and address them in the same pass when they are part of the same root cause. Example: if one `position` reference is invalid because the column is unavailable on the branch, check the app code, specs, helpers, and support code for every remaining `position` reference before pushing.

## Step 7: Validate Locally

After each fix:
1. run the exact failing command or closest local equivalent
2. run related validation for the touched package or service
3. run broader validation only if needed

Be efficient, but do not claim success without actual validation.

When the failure came from a shared helper, schema assumption, test support code, or repeated pattern, broader validation is needed. Run the whole affected suite, directory, or CI-equivalent command before pushing.

## Step 8: Decide Whether to Rerun CI

If the issue was environmental or flaky and there is no repository change, one diagnostic rerun is acceptable:

```bash
gh run rerun RUN_ID --failed
```

If you made a code or workflow change, commit and push it. Do not rely on rerunning the old run as proof for the new SHA.

## Step 9: Commit and Push

Only if there are actual repository changes:

```bash
git status
git diff --stat
git diff
git add -A
git commit -m "fix failing PR checks"
git push
```

Use a more specific commit message if the cause is obvious.

## Step 10: Confirm Post-Push Status

After pushing, check the new SHA's PR checks.

If the relevant checks finish in a reasonable time, wait for them:

```bash
gh pr checks --watch --fail-fast
```

If they are still running when you need to stop, do not say the issue is fixed. Say the fix was pushed and CI is still pending for the new SHA.

If the same check fails again, inspect the new failing log before summarizing. Treat that as the previous fix being incomplete, not as success.

## Final Response

Return a compact summary with:
- PR number and URL
- branch and pushed commit SHA, if any
- failing checks found
- root cause for each addressed failure
- what changed
- local validation run
- whether the new SHA's CI passed, failed again, or is still pending
- whether CI was rerun diagnostically
- anything still blocked or unresolved
