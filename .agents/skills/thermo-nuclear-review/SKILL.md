---
name: thermo-nuclear-review
description: Comprehensive security and correctness audit of branch or PR changes. Use for thermo nuclear, thermonuclear, deep review, branch audit, PR diff audit, bug review, security review, breaking-change review, devex regression review, or feature-gate leak review.
---

# Thermo-Nuclear Review

Use this skill for a strict audit of changed code. The goal is to catch bugs, broken existing behavior, security issues, developer-experience regressions, and feature-gate leaks before code lands.

## Scope

Review only code being added or modified by the current branch, PR, ticket, or supplied diff. Do not report pre-existing issues unless the change makes them materially worse or exposes them through a new path.

If no diff or concrete artifact is available, gather `git status --short`, the relevant diff, changed file context, and any available validation output. If the target is still unclear, ask for it.

## Review Priorities

Findings should be ordered by impact:

1. Security vulnerabilities, data loss, authz/authn mistakes, privacy leaks, or unsafe trust-boundary changes.
2. Correctness bugs and regressions in existing workflows.
3. Feature-flag, internal-only, rollout, or permission leaks.
4. Breaking API, schema, migration, deployment, or developer-experience changes.
5. Missing tests for changed behavior, edge cases, or integration points.
6. Observability, error handling, and operational risks that make failures hard to detect or recover.

Do not flood the review with low-confidence hypotheticals or cosmetic notes.

## What To Investigate

For every meaningful change, trace the end-to-end behavior:

- Are callers, consumers, migrations, generated types, background jobs, queues, and API clients still compatible?
- Could empty, null, duplicate, stale, unauthorized, malformed, or out-of-order inputs break the flow?
- Does the change alter auth, permissions, tenant boundaries, ownership checks, or trust boundaries?
- Does user-controlled data reach SQL, shell commands, filesystem paths, URLs, logs, prompts, or rendered HTML unsafely?
- Does the diff leak a gated feature through routing, navigation, API responses, experiments, emails, analytics, or background jobs?
- Does the change break local setup, ports, scripts, env vars, secrets loading, package managers, build commands, or test commands?
- Are errors handled deliberately, or can partial writes and retries leave inconsistent state?
- Are tests proving the risky paths, not just the happy path?

## Intended Breakage

If the branch clearly intends to remove behavior, change a contract, or delete a safeguard, do not report that fact by itself. Still report it when the blast radius is wider than the change appears to acknowledge, when downstream callers are not updated, when rollout or migration safety is missing, or when the change looks risky enough that the author may be underestimating it.

## PR Discussion

If there is an associated PR and you have already completed your own audit, inspect PR comments or review threads with `gh` or `glab` when available. Incorporate valid findings from other reviewers, and label them as coming from the PR discussion. Do this after your own pass so the first review stays independent.

## Output Format

Start with findings. Use this format:

```text
Findings
- [Blocker] path/to/file.ts:123 - Short issue title
  Why: Explain the concrete risk and affected path.
  Fix: Give the smallest fix that actually resolves it.

- [Major] path/to/file.ts:45 - Short issue title
  Why: ...
  Fix: ...

No issues found.
```

Severity guidance:

- `Blocker`: likely security issue, data loss, broken critical flow, broken acceptance criteria, unsafe migration/deploy, or severe feature leak.
- `Major`: correctness, regression, devex, rollout, or test gap that should be fixed before landing.
- `Minor`: useful but non-blocking risk reduction.

If there are no issues, say `No issues found.` and mention validation gaps or residual risk separately.

## Rules

Never present unfinished research as a finding. If the backend, caller, migration, or config exists in the repo, check it before claiming uncertainty. Be thorough and skeptical, but keep reported findings high-confidence and actionable.
