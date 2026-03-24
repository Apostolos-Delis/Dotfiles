---
description: Load reference patterns and best practices before starting work in an unfamiliar domain — warm up context before executing
allowed-tools: Read, Bash, Glob, Grep, WebSearch, WebFetch
---

# Reference

Gather reference material and established patterns before starting work in a domain. This is a warm-up step — build context first, then execute.

> **Philosophy**: You don't need to become an expert. You need the right references loaded before you start.

## Usage

```
/reference <domain> [optional focus]
```

Examples:
- `/reference auth` — authentication patterns for this project
- `/reference payments stripe` — payment integration with Stripe focus
- `/reference design onboarding` — design patterns for onboarding flows
- `/reference graphql mutations` — GraphQL mutation patterns in this codebase

## Instructions

### Step 1: Check Local References

Look for existing reference material in the project:

```bash
# Check for references/ directory
find . -maxdepth 3 -type d -name 'references' -o -name 'docs' -o -name 'examples' 2>/dev/null

# Check for domain-specific files
grep -rl "<domain>" --include='*.md' --include='*.txt' -l . 2>/dev/null | head -10
```

Also check:
- README files mentioning the domain
- Existing code in the domain area (grep for related modules/services)
- Test files that demonstrate usage patterns
- Configuration files (e.g., auth config, payment config)

### Step 2: Scan Existing Codebase Patterns

Search for how this project already handles the domain:

```bash
# Find related files
find . -type f -name '*<domain>*' | grep -v node_modules | grep -v .git | head -20

# Look for related code
grep -rn '<domain-keywords>' --include='*.ts' --include='*.tsx' --include='*.rb' --include='*.py' -l | head -15
```

When existing patterns are found, extract:
- Which libraries/frameworks are used
- Naming conventions
- File organization patterns
- Error handling approaches
- Test patterns

### Step 3: External Best Practices (if WebSearch available)

Search for current best practices. Keep it focused:
- "best practices <domain> <framework> 2025 2026"
- "<domain> common pitfalls <language>"

Summarize — don't dump raw search results.

### Step 4: Compile Reference Brief

Output a concise brief:

```
## Reference Brief: <Domain>

### Existing Patterns in This Project
- [What's already established, with file references]
- [Libraries/frameworks in use]
- [Conventions to follow]

### Key Patterns
- [2-4 established best practices for this domain]
- [With brief explanations of why]

### Common Pitfalls
- [2-3 mistakes to avoid]
- [Specific to this domain + tech stack]

### Recommended Approach
- [Based on existing patterns + best practices]
- [Concrete next steps if the user wants to proceed]
```

### Step 5: Handoff

Ask the user:
> "Reference brief ready. Want to proceed with a specific task using these patterns, or do you want me to dig deeper into any area?"

## Important

- Keep the brief **concise** — this is a warm-up, not a research paper
- Prioritize **existing project patterns** over generic best practices
- If the project already has strong conventions in this domain, lead with those
- Don't generate code — only gather and synthesize reference material
- If no relevant references are found locally or externally, say so honestly
