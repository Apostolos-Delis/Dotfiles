# Code Review

Review the current git changes for potential issues.

## Instructions

1. Run `git diff HEAD` to see all uncommitted changes
2. If there are staged changes, also run `git diff --cached`
3. Analyze the changes for:
   - Logic errors or bugs
   - Security vulnerabilities (SQL injection, XSS, command injection, etc.)
   - Performance issues
   - Code style inconsistencies
   - Missing error handling
   - Potential edge cases
4. Provide a summary of findings with specific line references
5. Suggest improvements if any issues are found

Be concise and focus on actual problems, not style nitpicks.
