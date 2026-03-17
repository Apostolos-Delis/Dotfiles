# Review Output Format

```text
## Review Summary

[Brief overview of changes and overall assessment]

### Findings

CRITICAL (must fix before commit)
- [file:line] Issue description
  -> Fix: Suggested solution

WARNING (should fix)
- [file:line] Issue description
  -> Fix: Suggested solution

SUGGESTION (optional improvement)
- [file:line] Issue description
  -> Consider: Alternative approach

GOOD (positive observations)
- [file] Positive observation

---
Summary: X critical, Y warnings, Z suggestions
Recommendation: [Ready to commit / Fix critical issues first / Consider warnings]
```
