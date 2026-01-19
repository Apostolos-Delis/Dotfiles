#!/bin/bash
# PostToolUse hook: Warn about console.log in edited files
# Reads JSON from stdin, checks if edited content contains console.log

# Read JSON input
INPUT=$(cat)

# Extract file path and new content
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)
NEW_STRING=$(echo "$INPUT" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('tool_input', {}).get('new_string', data.get('tool_input', {}).get('content', '')))" 2>/dev/null)

# Exit if no file path
[ -z "$FILE_PATH" ] && exit 0

# Only check JS/TS files
EXT="${FILE_PATH##*.}"
case "$EXT" in
  ts|tsx|js|jsx) ;;
  *) exit 0 ;;
esac

# Check if new content contains console.log
if echo "$NEW_STRING" | grep -q "console\.log"; then
  # Output warning as additionalContext
  echo '{"additionalContext": "⚠️ console.log detected in edit. Remember to remove before committing."}'
fi

exit 0
