# Hermes Codex Orchestrator

This directory contains the Dotfiles-managed Hermes setup for supervising parallel Codex coding sessions through Hermes Kanban.

The intended ownership boundary is:

- Hermes owns task lifecycle, monitoring, verification, PR handoff, memory, and audit trail.
- Codex CLI is a bounded implementation lane.
- Conductor can still own workspace creation, but Hermes should register those workspaces instead of creating nested worktrees.

## Layout

```text
hermes/
├── config.yaml
├── SOUL.md
├── memories/
│   ├── MEMORY.md
│   └── USER.md
├── profiles/
│   └── codex-worker/
│       ├── config.yaml
│       ├── SOUL.md
│       ├── profile.yaml
│       └── memories/
├── skill-bundles/
│   └── codex-pr-lane.yaml
└── scripts/
    ├── hermes-bootstrap.sh
    ├── hermes-kanban-create-codex-task
    ├── hermes-conductor-register-workspace
    └── hermes-validate.sh
```

## Install

Run the normal Dotfiles installer:

```bash
./release.sh
```

That links:

```text
~/.hermes/config.yaml                         -> hermes/config.yaml
~/.hermes/SOUL.md                             -> hermes/SOUL.md
~/.hermes/memories                            -> hermes/memories
~/.hermes/skill-bundles                       -> hermes/skill-bundles
~/.hermes/profiles/codex-worker/config.yaml   -> hermes/profiles/codex-worker/config.yaml
~/.hermes/profiles/codex-worker/SOUL.md       -> hermes/profiles/codex-worker/SOUL.md
~/.hermes/profiles/codex-worker/profile.yaml  -> hermes/profiles/codex-worker/profile.yaml
~/.hermes/profiles/codex-worker/memories      -> hermes/profiles/codex-worker/memories
~/.agents/dotfiles-skills                     -> .agents/skills
~/.local/bin/codex-worker                     -> hermes -p codex-worker
```

Hermes reads both `~/.agents/skills` and `~/.agents/dotfiles-skills`, so existing personal skills can stay in place while Dotfiles-managed skills are added separately. Hermes auth, `.env`, session databases, Kanban databases, logs, and worker artifacts are intentionally not tracked.

If Hermes is not installed yet:

```bash
hermes/scripts/hermes-bootstrap.sh --install-hermes
```

The bootstrap script uses a local `~/Documents/repos/hermes-agent` checkout when present. Otherwise it falls back to the official Hermes installer with setup skipped.

## Model/Auth Setup

Codex CLI is already managed separately by Codex:

```bash
codex --version
codex login
```

Hermes has its own OpenAI Codex provider auth store. Configure it after install:

```bash
hermes auth add openai-codex
hermes model
```

Choose the OpenAI Codex provider and a Codex-capable model. The tracked config defaults to `openai-codex` / `gpt-5.5`, but credentials are never stored in this repo.

## Start The Board

```bash
hermes kanban init
hermes gateway start
```

The gateway hosts the Kanban dispatcher. The default profile has dispatcher enabled; `codex-worker` has dispatcher disabled so it only runs when spawned.

Useful views:

```bash
hermes kanban list
hermes kanban watch
hermes kanban stats
hermes dashboard
```

## Create A New Codex Worktree Task

From a git repo:

```bash
hermes/scripts/hermes-kanban-create-codex-task \
  --body "Implement the requested README cleanup and open a PR." \
  "README cleanup"
```

This creates a Kanban task assigned to `codex-worker` with:

- `--workspace worktree`
- a generated `apostolos/hermes_<task>_<timestamp>_<pid>` branch
- forced `codex` and `github-pr-workflow` skills
- a prompt that tells Hermes to supervise Codex, rerun checks, and create a PR handoff

Override the branch or board when needed:

```bash
hermes/scripts/hermes-kanban-create-codex-task \
  --board mortgages \
  --branch apostolos/fix_checkout_copy \
  --max-runtime 3h \
  --body-file /tmp/task.md \
  "Fix checkout copy"
```

## Register An Existing Conductor Workspace

When Conductor already created the worktree:

```bash
hermes/scripts/hermes-conductor-register-workspace \
  ~/conductor/workspaces/mortgages/philadelphia-v1 \
  "Continue dashboard side chat work"
```

The task is registered as `worktree:<absolute path>`, with the current branch recorded. The task body explicitly tells Hermes and Codex not to create a nested worktree.

## Worker Contract

The `codex-worker` profile should:

1. Read the active Kanban task and comments.
2. Confirm the workspace is isolated.
3. Spawn Codex CLI only for bounded implementation work.
4. Monitor Codex without treating its output as truth.
5. Inspect `git status`, `git diff --stat`, and `git diff`.
6. Reject unrelated or unsafe changes.
7. Run relevant checks from Hermes.
8. Commit and create a PR when appropriate.
9. Block with `review-required:` and structured metadata for human review.

## Validation

Run:

```bash
hermes/scripts/hermes-validate.sh
```

The validation checks:

- tracked Hermes files exist
- shell scripts parse
- YAML parses
- memory seeds stay under Hermes memory budgets
- bootstrap links work in an isolated temporary `HOME`
- task helper scripts compose the expected `hermes kanban create` commands using a fake Hermes binary and temporary git repositories

This does not require real Hermes auth or a live model.
