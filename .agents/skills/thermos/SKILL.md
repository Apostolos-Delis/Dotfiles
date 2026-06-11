---
name: thermos
description: Run both thermo-nuclear review passes and synthesize their findings. Use for thermos, double thermo review, combined thermonuclear review, comprehensive branch audit, PR audit, or when both bug/security review and code-quality review are needed.
---

# Thermos

Use this skill when a change needs both review lenses:

- `$thermo-nuclear-review` for correctness, security, feature leaks, regressions, and developer-experience breakage.
- `$thermo-nuclear-code-quality-review` for maintainability, structural simplification, abstraction quality, file size, spaghetti branching, and boundary cleanliness.

Thermos owns review orchestration. Callers should invoke Thermos once with the scoped artifacts; do not spawn a separate subagent whose only job is to run Thermos.

## Adversarial Mode

When a caller requests adversarial review, actively try to disprove the implementation against the stated requirements. Focus on missed acceptance criteria, incorrect assumptions, hidden regressions, security and trust-boundary mistakes, feature leaks, missing edge cases, weak tests, and structural choices that create unnecessary risk. Keep findings high-confidence and actionable.

## Workflow

1. Determine the review scope from the user request, PR, current branch, ticket, or changed files.
2. Gather the diff and the smallest surrounding context reviewers need to evaluate the change without guessing.
3. Run both review passes independently. If subagents are available, run them as read-only subagents in parallel with the same scoped artifacts. If subagents are unavailable, run the two passes locally one after the other.
4. Ask each pass to return prioritized findings with file references, evidence, and concrete fixes.
5. Synthesize the results with findings first, deduplicated across reviewers.
6. Weight overlapping findings more heavily. Resolve disagreements with direct evidence from the code.

## Review Handoff

Use this shape for each review pass:

```text
Review only the supplied changes. Do not edit files.

Use $thermo-nuclear-review for correctness/security/devex risks.
Use $thermo-nuclear-code-quality-review for maintainability/structure risks.

Return findings ordered by severity with file:line references and concrete fixes.
If there are no issues, say that clearly.

### Scope
...

### Diff
...

### Relevant context
...

### Validation
...
```

## Output

Start with the unified findings:

```text
Findings
- [Blocker] path/to/file.ts:123 - Short issue title
  Source: correctness/security, code-quality, or both.
  Why: Explain the concrete risk.
  Fix: Give the smallest fix that actually resolves it.

No issues found.
```

After findings, keep the summary brief:

- review scope
- validation considered
- unresolved uncertainty or residual risk

Do not restate each individual review wholesale if those outputs are already visible to the user.
