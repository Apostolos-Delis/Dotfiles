---
description: "Post-ship documentation update — reads all project docs, cross-references the diff, updates README/ARCHITECTURE/CONTRIBUTING/CLAUDE.md, polishes CHANGELOG voice, cleans TODOS. Use after shipping code, merging a PR, or when asked to 'sync docs' or 'update documentation'."
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion
---

# /document-release — Post-Ship Documentation Update

Runs **after `/ship`** (code committed, PR exists) but **before merge**. Ensure every documentation file is accurate, up to date, and written in a user-forward voice.

## Automation Rules

**Make directly (no asking):**
- Factual corrections clearly from the diff (paths, counts, version numbers)
- Adding items to tables/lists
- Updating project structure trees
- Fixing stale cross-references
- CHANGELOG voice polish (minor wording adjustments)
- Marking TODOS complete
- Cross-doc factual inconsistencies (e.g., version mismatch)

**Stop and ask:**
- Narrative changes, philosophy, or security model descriptions
- VERSION bump decisions
- Large rewrites (>10 lines in one section)
- Removing entire sections
- New TODOS items to add

**Never do:**
- Overwrite or regenerate CHANGELOG entries — polish wording only
- Bump VERSION without asking
- Use `Write` on CHANGELOG.md — always use `Edit` with exact `old_string` matches

---

## Step 1: Pre-flight & Diff Analysis

1. Check branch — abort if on the base branch.
2. Gather context:
```bash
BASE=$(git rev-parse --verify origin/main 2>/dev/null && echo "main" || echo "master")
git diff "$BASE"...HEAD --stat
git log "$BASE"..HEAD --oneline
git diff "$BASE"...HEAD --name-only
```

3. Discover all documentation files:
```bash
find . -maxdepth 2 -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" | sort
```

4. Classify changes: new features, changed behavior, removed functionality, infrastructure.

5. Output: "Analyzing N files changed across M commits. Found K documentation files to review."

---

## Step 2: Per-File Documentation Audit

Read each doc file and cross-reference against the diff:

**README.md:**
- Does it describe all features visible in the diff?
- Are install/setup instructions consistent with changes?
- Are examples and usage descriptions still valid?

**ARCHITECTURE.md:**
- Do diagrams and component descriptions match current code?
- Be conservative — only update things clearly contradicted by the diff.

**CONTRIBUTING.md — New contributor smoke test:**
- Walk through setup instructions as if you're a brand new contributor.
- Would each step succeed? Are test tier descriptions current?

**CLAUDE.md / project instructions:**
- Does the project structure section match the actual file tree?
- Are listed commands and scripts accurate?

**Any other .md files:**
- Read, determine purpose, cross-reference against diff for contradictions.

For each file, classify updates as **auto-update** (factual, from diff) or **ask user** (narrative, risky).

---

## Step 3: Apply Auto-Updates

Make all clear, factual updates directly. For each file modified, output a one-line summary: not "Updated README.md" but "README.md: added /new-command to commands table, updated command count from 12 to 14."

---

## Step 4: Ask About Risky Changes

For each risky update, ask with context + recommendation + options (including "Skip — leave as-is").

---

## Step 5: CHANGELOG Voice Polish

**CRITICAL — NEVER CLOBBER CHANGELOG ENTRIES.**

If CHANGELOG was modified on this branch:
- **Sell test:** Would a user reading each bullet think "oh nice, I want to try that"?
- Lead with what the user can now **do** — not implementation details
- "You can now..." not "Refactored the..."
- Flag entries that read like commit messages
- Internal/contributor changes → separate "### For contributors" subsection
- Auto-fix minor voice. Ask if a rewrite would alter meaning.

If CHANGELOG was NOT modified: skip.

---

## Step 6: Cross-Doc Consistency

1. README feature list ↔ CLAUDE.md descriptions
2. ARCHITECTURE components ↔ CONTRIBUTING project structure
3. CHANGELOG version ↔ VERSION file
4. **Discoverability:** Is every doc reachable from README or CLAUDE.md? If not, flag it.
5. Auto-fix factual inconsistencies. Ask about narrative contradictions.

---

## Step 7: TODOS.md Cleanup

If TODOS.md exists:

1. **Completed items:** Cross-reference diff. If a TODO is clearly completed, mark it done. Be conservative.
2. **Stale descriptions:** If a TODO references significantly changed files, ask whether to update/complete/leave.
3. **New deferred work:** Check diff for `TODO`, `FIXME`, `HACK` comments. For meaningful deferred work, ask whether to capture in TODOS.md.

---

## Step 8: VERSION Bump

If VERSION file exists and was NOT bumped on this branch, ask:
- A) Bump PATCH
- B) Bump MINOR
- C) Skip — no version bump needed (recommended for docs-only changes)

If VERSION was already bumped, check if the bump covers the full scope. If significant uncovered changes exist, flag.

---

## Step 9: Commit & Output

If no docs were modified: "All documentation is up to date." Exit.

Otherwise:
1. Stage modified docs by name (never `git add -A`).
2. Commit: `docs: update project documentation`
3. Push to current branch.
4. If a PR exists, update the PR body with a `## Documentation` section listing what changed.

Output a scannable health summary:
```
Documentation health:
  README.md       [Updated / Current / Skipped]
  ARCHITECTURE.md [Updated / Current / Skipped]
  CONTRIBUTING.md [Updated / Current / Skipped]
  CHANGELOG.md    [Voice polished / Current / Skipped]
  TODOS.md        [Updated / Current / Skipped]
  VERSION         [Bumped / Not bumped / Skipped]
```
