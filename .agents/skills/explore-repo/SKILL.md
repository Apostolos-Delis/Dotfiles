---
name: explore-repo
description: Perform comprehensive single-pass repository exploration and produce a structured report.
---

# Explore Repository

Perform a comprehensive exploration of a repository and generate a structured report.

## Instructions

1. Take target path and objectives from the user.
2. Execute a single-pass exploration (do not split into parallel agent explorations):
   - Map directory structure
   - Identify key files (README, configs, catalogs)
   - Sample representative files from each category
   - Search for objective-specific patterns
3. Generate a structured Markdown report:
   - Executive summary
   - Directory structure overview
   - Resource catalog by category
   - Key findings tied to objectives
   - Actionable recommendations
4. Write report to user-specified path if provided.
5. Present concise summary and report path.

## Rules

- One pass, broad and efficient
- Prefer direct Read/Grep/Glob/Bash over spawning extra agent explorers
- Prioritize breadth first, then depth where requested
