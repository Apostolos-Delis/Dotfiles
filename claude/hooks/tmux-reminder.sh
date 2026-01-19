#!/bin/bash
# PreToolUse hook: Remind about tmux for long-running commands
# Triggers on npm/pnpm/yarn/cargo/pytest/bundle commands

# Read JSON input
INPUT=$(cat)

# Extract command
COMMAND=$(echo "$INPUT" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('tool_input', {}).get('command', ''))" 2>/dev/null)

# Check if command matches long-running patterns
if echo "$COMMAND" | grep -qE "(npm (run|test|start|build)|pnpm (run|test|start|build)|yarn (run|test|start|build)|cargo (build|test|run)|pytest|bundle (install|exec)|rails (server|console))"; then
  # Check if NOT in tmux
  if [ -z "$TMUX" ]; then
    echo '{"additionalContext": "💡 Consider running in tmux for session persistence: tmux new -s dev"}'
  fi
fi

exit 0
