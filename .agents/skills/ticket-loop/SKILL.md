---
name: ticket-loop
description: Sequentially implement a batch of tickets, issues, or tasks one at a time with goal tracking, per-ticket validation, independent subagent review using the thermo-nuclear-code-quality-review rubric, remediation of every actionable finding, and continuation until all tickets are complete. Use when the user asks to implement multiple tickets one by one, says not to stop until all are implemented, or requests a review-and-fix loop after each ticket.
---

# Ticket Loop

## Overview

Use this skill to run a disciplined implementation queue. Finish one ticket completely before starting the next: understand it, implement it, validate it, have an independent review pass, address review findings, then move on.

## Start The Loop

1. Identify the full ticket list and preserve the user's intended order.
2. If tickets are referenced by URL, issue ID, file, board, or PRD, fetch or read the ticket bodies before implementation.
3. If the queue is ambiguous enough that implementation order or scope would be risky, ask one concise question. Otherwise make a reasonable assumption and state it.
4. Check git status before editing and preserve unrelated user changes.
5. Create a visible plan with one item per ticket plus a final integration pass.
6. Create a goal only when the user explicitly asks for one, for example with `/goal`; otherwise use the plan as the progress ledger.

Keep the ledger current. At minimum, track:

```text
Ticket | Status | Validation | Review | Notes
```

## Per-Ticket Cycle

For each ticket, complete these steps before advancing:

1. Mark the ticket in progress.
2. Read the surrounding code and find the real implementation point before changing files.
3. Record the current changed-file set before editing so the review handoff can distinguish this ticket from prior work.
4. Implement only the current ticket's scope. Avoid drive-by refactors, compatibility shims, and speculative abstraction.
5. Run the narrowest meaningful validation for the ticket: focused tests first, then lint/typecheck/build commands when relevant.
6. Collect review input:
   - ticket text and acceptance criteria
   - `git diff` for the current ticket, or a clearly labeled cumulative diff if prior uncommitted tickets overlap
   - changed-file list and relevant surrounding files
   - validation commands and results
   - known assumptions or external blockers
7. Invoke one independent read-only review subagent when subagents are available, and require it to use `$thermo-nuclear-code-quality-review` as the review rubric. If the subagent cannot load that skill by name, point it at `~/.codex/skills/thermo-nuclear-code-quality-review/SKILL.md` or `.agents/skills/thermo-nuclear-code-quality-review/SKILL.md` and rerun the review. If subagents are unavailable, run an explicit local review pass using the same rubric and state that fallback in the ticket notes.
8. Address every actionable review finding before moving on.
9. Re-run the relevant validation after fixes.
10. If review fixes were substantial, run one more targeted review pass for that ticket.
11. Mark the ticket complete only when implementation, validation, and review remediation are all done.

## Review Subagent Prompt

Use this shape for the review handoff. Keep it artifact-first and avoid telling the reviewer what you expect it to find.

```text
Use $thermo-nuclear-code-quality-review as the required review rubric. If that skill
is not in your available skill list, read and follow the rubric at
~/.codex/skills/thermo-nuclear-code-quality-review/SKILL.md or
.agents/skills/thermo-nuclear-code-quality-review/SKILL.md.

Review only the current ticket's changes. Do not edit files. Look for correctness bugs,
edge cases, missing tests, structural quality issues, unnecessary complexity,
spaghetti branching, file-size/decomposition problems, boundary leaks, and canonical
helper reuse opportunities.

Return findings ordered by severity with file:line references and concrete fixes.
If there are no issues, say that clearly.

### Ticket
...

### Diff
...

### Changed file contents or relevant excerpts
...

### Validation
...

### Assumptions / known constraints
...
```

## Handling Review Findings

Treat each review item as unresolved until one of these is true:

- The issue is fixed and validation has been rerun.
- The finding is demonstrably incorrect or conflicts with the user's instructions, and the final ticket notes explain why.
- The finding requires a product or architectural decision that cannot be inferred safely; pause and ask the user before continuing.

Do not silently ignore findings. Do not move to the next ticket with unresolved blocker or major findings.

## Validation Strategy

Prefer validation that matches the risk of the ticket:

- Pure logic: focused unit tests plus existing related tests.
- API or data contract: tests for callers/consumers and schema or serialization checks.
- UI: component tests when present, plus browser verification for user-visible flows.
- Config or deployment: inspect environment overlays and run the repository's validation command.
- Cross-cutting changes: run the broader suite the repo normally expects before closeout.

If a command cannot run because of missing services, credentials, or environment state, capture the exact command, failure reason, and any partial evidence gathered.

## Commit Policy

Do not commit unless the user asked for commits, shipping, or PR creation. When commits are requested, commit after each ticket passes validation and review remediation so each commit is atomic and bisectable.

## Final Integration Pass

After the last ticket:

1. Re-read the full diff across all tickets.
2. Look for cross-ticket conflicts, duplicated helpers, inconsistent naming, stale task markers, missed docs, and tests that only pass in isolation.
3. Run the broad validation appropriate for the total change.
4. Run a final review pass if the tickets touched shared code, public contracts, data models, auth, deployment, or UI flows.
5. Update the goal as complete only if one was created and every ticket is genuinely done.
6. Final response should list completed tickets, validation run, review status, and any residual risk.

## Stop Conditions

Keep going until every ticket is complete unless:

- The user interrupts or changes direction.
- A ticket needs a decision that cannot be made safely from the repository context.
- A required external dependency, credential, or service is unavailable and blocks implementation.
- Validation exposes a pre-existing failure that cannot be separated from the work.

When stopped by a blocker, preserve the current state, explain exactly where the loop paused, and identify the next concrete action.
