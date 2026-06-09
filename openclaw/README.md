# OpenClaw Codex Orchestrator

This directory contains the Dotfiles-managed OpenClaw setup for supervising parallel Codex coding sessions.

OpenClaw owns the operator surface: Control UI, Workboard, sessions, logs, chat channels, and follow-up prompting. Codex owns implementation turns through the native Codex app-server runtime. Conductor can still own workspace creation; OpenClaw should attach to those workspaces instead of creating nested worktrees.

## Layout

```text
openclaw/
├── config.patch.json
├── workspace/
│   ├── AGENTS.md
│   ├── HEARTBEAT.md
│   ├── IDENTITY.md
│   ├── MEMORY.md
│   ├── SOUL.md
│   ├── TOOLS.md
│   └── USER.md
└── scripts/
    ├── openclaw-setup.sh
    └── openclaw-validate.sh
```

## Install

Run the normal Dotfiles installer:

```bash
./release.sh
```

That runs:

```bash
openclaw/scripts/openclaw-setup.sh --dotfiles "$DOTFILES_DIR"
```

The setup script:

- installs `openclaw` with npm if missing
- creates a local loopback gateway config on first run
- installs the official `@openclaw/codex` plugin if missing
- enables Codex and Workboard through `openclaw/config.patch.json`
- enables the bundled `coding-agent` skill for background Codex worker lanes
- links tracked workspace seed files into `~/.openclaw/workspace`
- creates an untracked live `~/.openclaw/workspace/memory` directory for daily or noisy memory
- imports the Codex CLI API key from `~/.codex/auth.json` into OpenClaw when the `openai:codex-api-key` profile is missing
- writes an explicit plugin allowlist from the currently installed OpenClaw plugin catalog

OpenClaw config itself is not symlinked. `~/.openclaw/openclaw.json` must stay a regular file because OpenClaw and the Control UI own atomic config writes.

## Useful Commands

```bash
openclaw dashboard
openclaw status
openclaw gateway status
openclaw logs --follow
openclaw sessions list
openclaw workboard list
openclaw skills check
openclaw tasks list --status running
openclaw sessions tail --follow
```

Codex runtime commands from an OpenClaw chat:

```text
/codex status
/codex models
/codex threads
/codex resume <thread-id>
/codex bind --cwd <path>
/codex stop
```

Background Codex worker workflow:

```text
Run six Codex worker lanes for /path/to/repo. Create or reuse isolated worktrees, monitor them, run adversarial review loops, and only interrupt me if blocked or when PRs are ready.
```

OpenClaw should use the bundled `coding-agent` skill for that workflow. Workboard is for visibility; it is not meant to be the normal manual control path.

## Auth

Secrets are intentionally not tracked. The setup script can copy the existing Codex CLI API key from `~/.codex/auth.json` into OpenClaw's per-agent auth store:

```bash
openclaw models auth list --provider openai
```

If the profile is missing and Codex auth is not available, configure it manually:

```bash
openclaw models auth paste-api-key --provider openai --profile-id openai:codex-api-key
```

## Dashboard

Open the local Control UI:

```bash
openclaw dashboard
```

Default URL:

```text
http://127.0.0.1:18789/
```

## Telegram

Telegram is available but not configured by default because the bot token is a secret. Configure it through the Control UI Config tab or with `openclaw config patch` after creating a bot token in BotFather.

## Validation

Run:

```bash
openclaw/scripts/openclaw-validate.sh
```

The validation checks tracked files, shell syntax, JSON syntax, seed-file secret patterns, and setup behavior against a fake OpenClaw CLI in an isolated temporary `HOME`.
