#!/bin/bash
# PostToolUse hook: Auto-format files after Edit/Write
# Reads JSON from stdin, extracts file_path, formats if supported

# Read JSON input
INPUT=$(cat)

# Extract file path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

# Exit if no file path
[ -z "$FILE_PATH" ] && exit 0

# Check if file exists
[ ! -f "$FILE_PATH" ] && exit 0

# Get file extension
EXT="${FILE_PATH##*.}"

# Format based on extension
case "$EXT" in
  ts|tsx|js|jsx|json|css|scss|md)
    # Check if prettier is available in project
    if [ -f "$(dirname "$FILE_PATH")/node_modules/.bin/prettier" ]; then
      npx prettier --write "$FILE_PATH" 2>/dev/null
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null
    fi
    ;;
  py)
    # Format Python files with black and isort if available
    if command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null
    fi
    if command -v isort &>/dev/null; then
      isort --quiet "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rb)
    # Format Ruby files with rubocop if available
    if command -v rubocop &>/dev/null; then
      rubocop -a --fail-level E "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

exit 0
