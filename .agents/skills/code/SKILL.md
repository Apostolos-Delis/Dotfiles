---
name: code
description: One-off implementation workflow for a single coding task. Use when the user asks to code, implement, build, fix, refactor, update, or change one feature/bug/task and wants the agent to complete it end-to-end, validate it, run an adversarial Thermos review, address review findings, and open a PR without a multi-ticket loop.
---

# Code

Use this skill for one focused implementation request. For batches of tickets, use `$ticket-loop` instead.

## Workflow

1. Restate the task internally as acceptance criteria from the user's instructions and current repo context.
2. If a missing decision would make implementation risky, ask one concise question. Otherwise make a reasonable assumption and state it while working.
3. Check git status before editing and preserve unrelated user changes.
4. Read the surrounding code until the real implementation point is clear.
5. Implement the requested behavior end-to-end using existing project patterns. Keep the diff scoped; avoid drive-by refactors, compatibility shims, and speculative abstraction.
6. Add or update focused tests when the task changes behavior and the repo has a relevant test pattern.
7. Run the narrowest meaningful validation first, then broader lint/typecheck/build/test commands when risk warrants it.
8. Run an adversarial `$thermos` review gate on the completed diff.
9. Address every actionable Thermos finding before finishing.
10. Re-run relevant validation after fixes. If fixes were substantial, run one more targeted adversarial `$thermos` pass.
11. If there are no unresolved blocker or major findings, create a PR by invoking `$create-pr`. Include the validation commands and Thermos review status in the PR body.
12. Final response should summarize what changed, validation run, Thermos review status, PR URL, and any residual risk.

Because `$code` includes PR creation, commits and push are expected after the implementation passes validation and Thermos review. If the user explicitly says not to commit, push, or open a PR, stop after the remediated Thermos loop and report the ready-to-PR state.

## Adversarial Thermos Handoff

Use this shape after implementation and initial validation:

```text
Use $thermos in adversarial mode. Review only the supplied task changes. Do not edit files.

Try to disprove the implementation against the user's instructions. Look for missed
acceptance criteria, correctness bugs, security issues, regressions, feature-gate
leaks, edge cases, missing tests, structural quality problems, unnecessary
complexity, boundary leaks, and simpler designs that would remove risk.

Return findings ordered by severity with file:line references and concrete fixes.
If there are no issues, say that clearly.

### User request
...

### Assumptions
...

### Diff
...

### Relevant context
...

### Validation
...
```

If `$thermos` cannot load by name, read `~/.codex/skills/thermos/SKILL.md` or `.agents/skills/thermos/SKILL.md`. If Thermos is unavailable, run both `$thermo-nuclear-review` and `$thermo-nuclear-code-quality-review` and synthesize the findings.

## Finding Handling

Treat every Thermos finding as unresolved until one of these is true:

- The issue is fixed and relevant validation has been rerun.
- The finding is demonstrably incorrect, with a short note explaining why.
- The finding conflicts with the user's explicit instructions.
- The finding requires a product or architecture decision that cannot be inferred safely; pause and ask the user.

Do not finish with unresolved blocker or major findings unless the user explicitly accepts the risk.

## PR Handoff

After the adversarial review loop is clean, use `$create-pr` for staging, formatting, committing, pushing, and opening the PR. Before handing off:

- Verify no unrelated user changes are staged or included.
- Provide `$create-pr` the task summary, validation commands and results, Thermos review outcome, and any accepted residual risk.
- If `$create-pr` finds new self-review issues, address them and re-run relevant validation before opening the PR.
- If GitHub auth, branch divergence, or remote setup blocks PR creation, leave the branch ready and report the exact blocker.

## Stop Conditions

Keep going until the task is implemented, validated, reviewed, remediated, and a PR is opened unless:

- The user interrupts or changes direction.
- A required credential, service, dependency, or external state is unavailable.
- The task needs a decision that cannot be made safely from repo context.
- Validation exposes a pre-existing failure that cannot be separated from the change.
- The user explicitly says not to commit, push, or open a PR.
