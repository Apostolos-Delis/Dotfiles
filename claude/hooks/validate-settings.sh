#!/bin/bash
# PostToolUse hook: Validate settings.json after edits
# Only runs for settings.json files, validates JSON syntax

# Read JSON input
INPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null)

# Only check settings.json files
[[ "$FILE_PATH" != *"settings.json" ]] && exit 0

# Check if file exists
[ ! -f "$FILE_PATH" ] && exit 0

# Validate JSON syntax
if ! python3 -m json.tool "$FILE_PATH" > /dev/null 2>&1; then
    echo '{"additionalContext": "ERROR: settings.json has invalid JSON syntax. Please fix before continuing."}'
    exit 0
fi

# Check for common structure issues
VALIDATION=$(python3 -c "
import json
import sys

with open('$FILE_PATH') as f:
    try:
        data = json.load(f)
    except:
        print('invalid_json')
        sys.exit(0)

errors = []

# Check hooks structure
if 'hooks' in data:
    hooks = data['hooks']
    for event, entries in hooks.items():
        if not isinstance(entries, list):
            errors.append(f'{event}: should be array')
            continue
        for i, entry in enumerate(entries):
            if 'hooks' not in entry:
                errors.append(f'{event}[{i}]: missing hooks array')
            elif not isinstance(entry.get('hooks'), list):
                errors.append(f'{event}[{i}].hooks: should be array')
            if 'matcher' in entry and not isinstance(entry['matcher'], str):
                errors.append(f'{event}[{i}].matcher: should be string')

if errors:
    print('\\n'.join(errors))
" 2>/dev/null)

if [ -n "$VALIDATION" ]; then
    echo "{\"additionalContext\": \"WARNING: settings.json structure issues:\\n$VALIDATION\"}"
fi

exit 0
