---
description: "Restrict file edits to a specific directory for the session — prevents accidentally modifying unrelated code while debugging or focused work. Use when asked to 'only edit this folder', 'restrict edits', or 'scope changes'."
allowed-tools: Bash, Read, AskUserQuestion
---

# /freeze — Restrict Edits to a Directory

Lock file edits to a specific directory. Any Edit or Write operation targeting a file outside the allowed path will be **blocked**.

## Setup

Ask the user which directory to restrict edits to. If they invoked `/freeze <path>`, use that path directly.

1. Resolve to an absolute path:
```bash
FREEZE_DIR=$(cd "<user-provided-path>" 2>/dev/null && pwd)
echo "Freeze boundary: $FREEZE_DIR/"
```

2. Confirm: "Edits are now restricted to `<path>/`. Any Edit or Write outside this directory will be blocked. Run `/unfreeze` to remove the restriction."

## Enforcement Rules

For every Edit or Write operation for the rest of this conversation:

1. Check if the target `file_path` starts with the frozen directory path (with trailing `/` to prevent `/src` matching `/src-old`).
2. If **inside** the boundary → proceed normally.
3. If **outside** the boundary → **REFUSE the edit** and explain:
   ```
   🔒 BLOCKED: Edit to <file_path> is outside the freeze boundary (<freeze_dir>/).
   Run /unfreeze to remove the restriction, or move this edit to a separate session.
   ```

## Scope

- Applies to Edit and Write operations only — Read, Bash, Grep, Glob are unaffected.
- This prevents accidental edits, not a security boundary — Bash commands like `sed` can still modify files outside the boundary.
- Persists for the entire conversation. Run `/unfreeze` or start a new session to deactivate.

## Notes

- Use with `/careful` for maximum safety when debugging production systems.
- Especially useful during debugging to prevent accidentally "fixing" unrelated code.
- The `/investigate` skill can auto-set a freeze boundary to the affected module.
