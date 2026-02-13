---
name: 1password
description: Set up and use 1Password CLI (op). Use when installing the CLI, enabling desktop app integration, signing in, or reading/injecting/running secrets via op.
---

# 1Password CLI

## Install

```bash
brew install 1password-cli
op --version
```

## Setup

1. Open and unlock the 1Password desktop app
2. Settings > Developer > "Integrate with 1Password CLI"
3. Verify: `op vault list` (will prompt for auth in the app)

## Workflow

1. Check `op --version` is installed
2. Confirm desktop app integration is enabled and the app is unlocked
3. Sign in: `op signin` (or `op signin --account <shorthand>` for multi-account)
4. Verify: `op whoami`

## Common Commands

```bash
# Auth
op signin
op signin --account <shorthand|signin-address|account-id>
op whoami
op account list

# Read secrets
op read op://vault/item/field
op read "op://vault/item/one-time password?attribute=otp"
op read --out-file ./key.pem op://vault/server/ssh/key.pem

# Run with injected secrets
export DB_PASSWORD="op://app-prod/db/password"
op run -- printenv DB_PASSWORD
op run --env-file="./.env" -- your-command

# Inject into templates
echo "db_password: {{ op://vault/db/password }}" | op inject
op inject -i config.yml.tpl -o config.yml
```

## Multi-Account

Use `--account` flag or `OP_ACCOUNT` env var to target a specific account.

## Guardrails

- Never paste secrets into logs, chat, or code
- Prefer `op run` / `op inject` over writing secrets to disk
- If "account is not signed in", re-run `op signin` and authorize in the app
