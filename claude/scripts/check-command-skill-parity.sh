#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMMANDS_DIR="$ROOT_DIR/claude/commands"
SKILLS_DIR="$ROOT_DIR/.agents/skills"

MAPPED_COMMANDS=(
  branch
  create-hook
  create-pr
  explain
  explore-repo
  plan-review
  rebase
  review
  test
)

is_mapped_command() {
  local value="$1"
  local candidate
  for candidate in "${MAPPED_COMMANDS[@]}"; do
    if [[ "$candidate" == "$value" ]]; then
      return 0
    fi
  done
  return 1
}

status=0

for command in "${MAPPED_COMMANDS[@]}"; do
  command_file="$COMMANDS_DIR/$command.md"
  skill_file="$SKILLS_DIR/$command/SKILL.md"

  if [[ ! -f "$command_file" ]]; then
    echo "Missing command file: claude/commands/$command.md"
    status=1
  fi

  if [[ ! -f "$skill_file" ]]; then
    echo "Missing skill file: .agents/skills/$command/SKILL.md"
    status=1
  fi
done

for command_file in "$COMMANDS_DIR"/*.md; do
  command_name="$(basename "$command_file" .md)"

  if [[ "$command_name" == "CLAUDE" ]]; then
    continue
  fi

  if ! is_mapped_command "$command_name"; then
    echo "Unmapped command detected: claude/commands/$command_name.md"
    status=1
  fi
done

if [[ "$status" -eq 0 ]]; then
  echo "Command/skill parity check passed"
fi

exit "$status"
