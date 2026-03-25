---
description: "Safety guardrails for destructive commands — warns before rm -rf, DROP TABLE, force-push, git reset --hard, kubectl delete. Use when touching prod, debugging live systems, or working in shared environments."
allowed-tools: Bash, Read
---

# /careful — Destructive Command Guardrails

Safety mode is now **active**. Every bash command must be checked for destructive patterns before running.

## Protected Patterns

| Pattern | Example | Risk |
|---------|---------|------|
| `rm -rf` / `rm -r` / `rm --recursive` | `rm -rf /var/data` | Recursive delete |
| `DROP TABLE` / `DROP DATABASE` | `DROP TABLE users;` | Data loss |
| `TRUNCATE` | `TRUNCATE orders;` | Data loss |
| `git push --force` / `-f` | `git push -f origin main` | History rewrite |
| `git reset --hard` | `git reset --hard HEAD~3` | Uncommitted work loss |
| `git checkout .` / `git restore .` | `git checkout .` | Uncommitted work loss |
| `kubectl delete` | `kubectl delete pod` | Production impact |
| `docker rm -f` / `docker system prune` | `docker system prune -a` | Container/image loss |
| `helm uninstall` / `helm delete` | `helm uninstall my-release` | Production impact |

## Safe Exceptions (no warning needed)

- `rm -rf node_modules` / `.next` / `dist` / `__pycache__` / `.cache` / `build` / `.turbo` / `coverage` / `tmp`

## How It Works

Before executing ANY bash command, check it against the patterns above:

1. If the command matches a protected pattern AND is not a safe exception → **STOP and warn the user**:
   ```
   ⚠️ DESTRUCTIVE COMMAND DETECTED
   Command: <the command>
   Risk: <what could go wrong>
   ```
   Then ask: "Proceed anyway? (yes/no)"

2. If the user confirms → execute.
3. If the command doesn't match → execute normally.

## Scope

This mode stays active for the entire conversation. To deactivate, start a new session.

**Note:** This is a behavioral guardrail, not a sandboxed environment. It relies on checking commands before execution. Use alongside `/freeze` for maximum safety.
