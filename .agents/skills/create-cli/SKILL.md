---
name: create-cli
description: "Use when designing CLI parameters, flags, subcommands, or UX — before implementation, not during."
---

# Create CLI

Design CLI surface area (syntax + behavior), human-first, script-friendly.

## Do This First

- Reference the CLI guidelines at https://clig.dev/ as the default rubric.
- Ask only the minimum clarifying questions needed to lock the interface.

## Clarify (fast)

Ask, then proceed with best-guess defaults if user is unsure:

- Command name + one-sentence purpose.
- Primary user: humans, scripts, or both.
- Input sources: args vs stdin; files vs URLs; secrets (never via flags).
- Output contract: human text, `--json`, `--plain`, exit codes.
- Interactivity: prompts allowed? need `--no-input`? confirmations for destructive ops?
- Config model: flags/env/config-file; precedence; XDG vs repo-local.
- Platform/runtime constraints: macOS/Linux/Windows; single binary vs runtime.

## Deliverables (what to output)

When designing a CLI, produce a compact spec the user can implement:

- Command tree + USAGE synopsis.
- Args/flags table (types, defaults, required/optional, examples).
- Subcommand semantics (what each does; idempotence; state changes).
- Output rules: stdout vs stderr; TTY detection; `--json`/`--plain`; `--quiet`/`--verbose`.
- Error + exit code map (top failure modes).
- Safety rules: `--dry-run`, confirmations, `--force`, `--no-input`.
- Config/env rules + precedence (flags > env > project config > user config > system).
- Shell completion story (if relevant).
- 5-10 example invocations (common flows; include piped/stdin examples).

See `references/cli-spec-template.md` for the full spec template.

## Default Conventions (unless user says otherwise)

- `-h/--help` always shows help and ignores other args.
- `--version` prints version to stdout.
- Primary data to stdout; diagnostics/errors to stderr.
- Add `--json` for machine output; consider `--plain` for stable line-based text.
- Prompts only when stdin is a TTY; `--no-input` disables prompts.
- Destructive operations: interactive confirmation + non-interactive requires `--force` or explicit `--confirm=...`.
- Respect `NO_COLOR`, `TERM=dumb`; provide `--no-color`.
- Handle Ctrl-C: exit fast; bounded cleanup; be crash-only when possible.

## Notes

- Prefer recommending a parsing library (language-specific) only when asked; otherwise keep this skill language-agnostic.
- If the request is "design parameters", do not drift into implementation.
