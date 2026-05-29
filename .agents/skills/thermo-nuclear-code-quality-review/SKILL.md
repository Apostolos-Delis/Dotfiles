---
name: thermo-nuclear-code-quality-review
description: Run an unusually strict code quality review focused on maintainability, structural simplification, abstraction quality, giant files, spaghetti branching, type and boundary cleanliness, and canonical layer/helper reuse. Use for thermonuclear review, thermo-nuclear review, deep maintainability audit, harsh code quality review, or as the review subagent rubric in a ticket implementation loop.
---

# Thermo-Nuclear Code Quality Review

## Purpose

Use this skill when the review bar should be higher than "does it work." The goal is to catch changes that make the codebase harder to reason about, and to push for simpler structure when behavior can stay the same.

## Inputs

If review artifacts are provided by a parent agent, review only those artifacts unless cross-file impact requires targeted lookup.

If artifacts are not provided, gather:

1. `git status --short`
2. the relevant diff, usually `git diff HEAD`
3. changed-file stats, including line counts for files that look large
4. relevant surrounding code and usages for changed public symbols
5. validation output if available

If there is no diff or concrete code artifact to review, stop and ask for the target.

## Review Priorities

Findings should be ordered by impact:

1. Correctness, data-loss, security, or user-visible regressions.
2. Structural regressions that make the design harder to understand or extend.
3. Missed simplifications where a clearer shape would delete meaningful complexity.
4. Spaghetti growth from ad-hoc branches, scattered flags, or one-off modes.
5. Boundary, ownership, type-contract, or canonical-layer problems.
6. File-size and decomposition concerns, especially crossing roughly 1000 lines.
7. Duplication, unnecessary wrappers, and maintainability issues.

Skip cosmetic nits when larger issues exist.

## Review Questions

Ask these questions for every meaningful change:

- Can the behavior be preserved while deleting branches, helpers, modes, or concepts?
- Did the diff make an existing module more coupled, stateful, or hard to scan?
- Is new logic in the file, package, service, or layer that already owns the concept?
- Did the change add special cases into a flow that should instead get a clearer model?
- Is the abstraction earning its keep, or is it pass-through indirection?
- Are casts, `any`, `unknown`, nullable fields, or optional params hiding a real invariant?
- Is there duplicated logic or a bespoke helper where a canonical utility already exists?
- Did a file grow past a healthy size boundary, especially from below 1000 lines to above it?
- Are independent operations serialized in a way that makes orchestration more complex?
- Can related updates fail halfway, leaving state harder to reason about?
- Are tests proving the important behavior and edge cases, not just the happy path?

## What To Flag Hard

Treat these as presumptive blockers unless the diff clearly justifies them:

- A complicated design where a simpler reframing would remove a whole category of complexity.
- Ad-hoc conditionals scattered through unrelated paths.
- Feature-specific logic leaking into shared or low-level modules.
- New modes, booleans, or nullable states that make control flow harder to follow.
- A file crossing roughly 1000 lines because decomposition was skipped.
- Thin wrappers, identity helpers, or generic machinery that obscure a simple flow.
- Cast-heavy or loosely typed boundaries that hide the contract.
- Duplicated helpers or logic when the codebase has a canonical home.
- Non-atomic updates where a more coherent transaction or state transition is obvious.
- Tests omitted for changed behavior, edge cases, or integration points.

## Preferred Remedies

Prefer fixes that reduce the number of concepts a maintainer must hold:

- Delete an unnecessary layer instead of polishing it.
- Reframe the state model so conditionals disappear.
- Move logic to the layer that owns the concept.
- Extract a focused helper, module, or component when it cuts real complexity.
- Replace condition chains with a clear model, dispatcher, or table-driven flow.
- Reuse the existing canonical helper instead of adding a near-duplicate.
- Make type boundaries explicit so the implementation needs fewer fallbacks.
- Separate orchestration from business logic.
- Make related writes atomic when partial state would be risky.
- Add focused tests that prove the behavior and the edge cases.

## Output Format

Start with findings. Use this format:

```text
Findings
- [Blocker] path/to/file.ts:123 - Short issue title
  Why: Explain the concrete risk.
  Fix: Give the smallest structural fix that actually resolves it.

- [Major] path/to/file.ts:45 - Short issue title
  Why: ...
  Fix: ...

No issues found.
```

Severity guidance:

- `Blocker`: likely bug, security/data risk, broken acceptance criteria, or severe structural regression.
- `Major`: maintainability, test, boundary, or decomposition issue that should be fixed before landing.
- `Minor`: useful cleanup that does not block landing.

If there are no issues, say `No issues found.` and mention any validation gaps or residual risk separately.

## Tone

Be direct, specific, and demanding about quality without being rude. Prefer a small number of high-confidence findings over a long list of low-value notes. Every finding should include a concrete path to a better implementation.

Do not approve code just because tests pass. Approve only when there is no clear structural regression, no obvious simpler design being missed, no unjustified file sprawl, no special-case branching growth, and no unresolved validation gap for the changed behavior.
