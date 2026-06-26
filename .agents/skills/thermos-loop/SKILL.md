---
name: thermos-loop
description: Iteratively run Thermos review, fix every actionable finding, validate the fixes, and repeat until a fresh Thermos run reports no issues. Use when asked for thermos-loop, repeated Thermos remediation, fix-until-clean review loops, or to keep addressing Thermos findings until none remain.
---

# Thermos Loop

## Overview

Run `$thermos`, fix its findings, validate, and rerun `$thermos` until the final review says no issues found.

The completion condition is a clean Thermos pass. Do not stop merely because one batch of findings was fixed.

## Hard Rules

- Load and use the local `$thermos` skill before the first review pass.
- Re-run `$thermos` after each remediation batch, even if the fixes seem obvious.
- Address every high-confidence actionable finding before the next pass.
- Do not dismiss a finding without rereading the current code and proving it is false, stale, duplicate, or outside the requested scope.
- Do not introduce broad refactors while fixing review findings.
- Do not commit, push, or open a PR unless the user requested that as part of the task or the surrounding workflow clearly requires it.
- Stop only when a fresh Thermos pass reports no issues, or when a genuine external blocker prevents progress.

## Workflow

### 1. Establish Scope

Determine the review target from the user request:

- Current branch diff against the base branch.
- A PR URL or number.
- A named set of files or commits.
- The current uncommitted changes.

Before editing:

```bash
git status --short
git branch --show-current
git merge-base --fork-point origin/main HEAD 2>/dev/null || git merge-base origin/main HEAD
```

If the repo uses `master`, `develop`, or a custom base, use the repo's actual base branch. Protect unrelated user changes; do not overwrite or revert work you did not create.

### 2. Run Thermos

Run `$thermos` on the scoped diff. Capture:

- iteration number
- reviewed scope
- findings
- findings accepted for remediation
- findings proven false or stale, with evidence
- validation state

If Thermos reports `No issues found`, run the final checks in step 5 and finish.

### 3. Remediate Findings

For each actionable finding:

1. Reproduce or confirm the issue from current code.
2. Find the root cause.
3. Make the smallest correct fix.
4. Add or update focused tests when the finding exposes behavior risk.
5. Run the narrowest useful validation for the changed area.
6. Record the command results.

Prefer fixing findings in one coherent batch per iteration. If a finding is large or risky, fix it independently and validate before continuing.

### 4. Rerun The Loop

After remediation and validation, rerun `$thermos` on the current updated scope.

Continue:

- Thermos finds issues -> go back to step 3.
- Thermos finds no issues -> go to step 5.
- The same finding repeats -> inspect why the previous fix did not satisfy it; fix the actual remaining problem rather than restating the prior fix.
- A finding is a false positive -> document evidence, but still rerun Thermos. If the same proven-false finding repeats and no code change can make the final Thermos pass clean without harming the code, treat that as a blocker and report it explicitly.

Do not impose an arbitrary iteration limit. The loop is done when the clean review proves it is done.

### 5. Final Verification

Before finishing, run the strongest practical validation for the final diff:

- relevant unit tests
- typecheck
- lint/format checks
- project-specific test command when reasonably scoped

Inspect the final diff:

```bash
git diff --stat
git diff
git status --short
```

Make sure the final diff contains only changes needed to satisfy the Thermos loop.

## Final Response

Report:

- number of Thermos iterations
- final clean Thermos pass result
- findings fixed by iteration
- tests and checks run
- files changed
- any blocker, skipped false positive, or residual risk

If the user requested commits or pushing, include commit SHAs and remote branch. Otherwise leave the working tree changes for the user to inspect.
