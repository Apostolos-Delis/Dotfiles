#!/bin/bash
# SessionStart hook: Show analysis summary if available
# Reads the latest analysis report and outputs a brief summary

LATEST_REPORT="$HOME/.claude/analysis/latest.md"

# Check if report exists and is recent (within 7 days)
if [ ! -f "$LATEST_REPORT" ]; then
    exit 0
fi

# Check if report is recent (within 7 days = 604800 seconds)
REPORT_AGE=$(($(date +%s) - $(stat -f %m "$LATEST_REPORT" 2>/dev/null || stat -c %Y "$LATEST_REPORT" 2>/dev/null)))
if [ "$REPORT_AGE" -gt 604800 ]; then
    exit 0
fi

# Extract the Quick Summary section
SUMMARY=$(sed -n '/^## Quick Summary/,/^---$/p' "$LATEST_REPORT" 2>/dev/null | grep -E '^\- ' | head -5)

if [ -n "$SUMMARY" ]; then
    # Get report date from filename or first line
    REPORT_DATE=$(head -1 "$LATEST_REPORT" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

    # Output as additionalContext for Claude
    echo "{\"additionalContext\": \"Session Analysis (${REPORT_DATE:-recent}):\\n${SUMMARY}\\nRun: cat ~/.claude/analysis/latest.md for details\"}"
fi

exit 0
