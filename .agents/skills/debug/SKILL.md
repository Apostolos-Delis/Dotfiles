---
name: debug
description: "Use when hitting a bug, unexpected behavior, test failure, or error that needs systematic investigation rather than a quick fix."
---

# Debug

Systematic debugging: reproduce, isolate, root-cause, fix.

## Approach

### 1. Reproduce

Confirm the failure. Run the failing test, trigger the error, or reproduce the unexpected behavior. If you can't reproduce it, you can't fix it reliably.

- Get the exact error message, stack trace, or unexpected output
- Note the environment (test vs dev, versions, config)
- Check if it's already fixed on main

### 2. Isolate

Narrow to the smallest failing unit.

- If a test fails: can you reproduce with a simpler test case?
- If runtime error: which function/line throws? Add targeted logging or use the stack trace.
- Binary search through recent changes if the cause isn't obvious (`git bisect` or manual).

### 3. Root Cause

Understand WHY before changing anything.

- Read the code path end-to-end
- Check `references/common-patterns.md` for common root causes
- Verify your theory explains ALL symptoms, not just the first one
- If the fix seems too easy, you probably haven't found the real cause

### 4. Fix

Minimal, targeted change + regression test.

- Change one thing at a time
- Write a test that fails before the fix and passes after
- Check for other call sites that might have the same bug
- Run the full test suite, not just the failing test

## Gotchas

- **Jumping to fix before understanding**: The urge to change code immediately is strong. Resist it. A wrong fix that makes the symptom disappear can mask the real bug.
- **Changing multiple things at once**: If you change 3 things and it works, you don't know which one fixed it (or if you introduced new bugs).
- **Not checking main first**: The bug might already be fixed. Check before spending 30 minutes debugging a stale branch.
- **Fixing the test instead of the code**: If a test fails, the default assumption should be the code is wrong, not the test. Verify before "fixing" test expectations.
