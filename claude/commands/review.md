---
description: Review uncommitted changes before committing - catch issues early
allowed-tools: Read, Bash, Glob, Grep
---

# Code Review

Review your uncommitted changes before committing. Catch issues early with multi-perspective analysis.

> **Philosophy**: "The future is now" - If something should be fixed, fix it before committing. No deferrals.

> **Mindset**: Be a hostile reviewer. Assume there ARE issues and look hard to find them. Think like:
> - A malicious attacker trying to break the system
> - A careless user making mistakes
> - A future developer inheriting this code
> - A production system under heavy load

## Instructions

### Step 1: Gather Changes

Get all uncommitted changes:

```bash
git diff HEAD
```

If there are staged changes, also check:

```bash
git diff --cached
```

If no changes exist, tell the user: "No uncommitted changes to review." and stop.

### Step 2: Analyze Change Types

Before reviewing, identify what types of changes are present:
- **Logic changes**: New functions, modified algorithms, conditional changes
- **Data handling**: Database queries, API calls, file I/O
- **Configuration**: Environment variables, config files, dependencies
- **UI/Frontend**: Templates, styles, client-side code
- **Tests**: Test files, test utilities

This determines which contextual reviews to apply.

### Step 3: Developer Review (Always Applied)

Evaluate the code from a senior engineer perspective:

1. **Code Quality & Maintainability**
   - Is the code readable and well-structured?
   - Are functions/methods appropriately sized?
   - Is there unnecessary complexity?

2. **Performance**
   - Any obvious inefficiencies (N+1 queries, unnecessary loops)?
   - Memory concerns (large allocations, leaks)?
   - Blocking operations that could be async?

3. **Best Practices**
   - Does it follow the project's coding conventions?
   - Are there code smells (magic numbers, deep nesting, long parameter lists)?
   - Is error handling appropriate?

4. **Logic Errors**
   - Off-by-one errors
   - Null/undefined handling
   - Race conditions
   - Incorrect assumptions

### Step 4: Security Review (Always Applied)

Check for security vulnerabilities:

1. **Injection Risks**
   - SQL injection (raw queries with user input)
   - Command injection (shell commands with user input)
   - XSS (unescaped output in templates)

2. **Data Handling**
   - Sensitive data exposure (logging passwords, tokens in URLs)
   - Hardcoded secrets or credentials
   - Improper encryption/hashing

3. **Authentication & Authorization**
   - Missing auth checks
   - Privilege escalation risks
   - Session management issues

4. **Input Validation**
   - Missing validation on user input
   - Type coercion issues
   - Path traversal vulnerabilities

### Step 5: Contextual Reviews (When Relevant)

**If logic changes detected - Test Coverage Review:**
- Are new code paths covered by tests?
- Are edge cases tested?
- Would this change break existing tests?

**If conditionals/loops present - Edge Case Review:**
- Boundary conditions (empty arrays, zero values, null)
- Maximum/minimum values
- Error states and recovery

**If data handling present - Data Integrity Review:**
- Transaction handling
- Data validation before persistence
- Rollback scenarios

**If configuration changes - Config Review:**
- Environment-specific values handled?
- Secrets properly externalized?
- Backward compatibility?

### Step 6: Integration Impact Check

When changes touch certain file types, check for related files that may also need updates:

| Changed | Also Check |
|---------|------------|
| Routes/endpoints | CORS config, API docs, client code |
| Auth/permissions | All entry points, middleware, role definitions |
| Env vars | Deployment configs, CI/CD, documentation |
| API paths/contracts | Frontend clients, API docs, integration tests |
| Database schema | Migrations, seeds, related models |
| Config files | Environment overlays (staging.yaml, production.yaml) |

**Process**: For each category of change detected, grep/glob for related files and verify they're consistent. Report any files that reference the old values but weren't updated.

### Step 7: Classify and Report Findings

Report findings using severity classification:

**Format:**
```
## Review Summary

[Brief overview of changes and overall assessment]

### Findings

🔴 **CRITICAL** (must fix before commit)
- [file:line] Issue description
  → Fix: Suggested solution

🟠 **WARNING** (should fix)
- [file:line] Issue description
  → Fix: Suggested solution

🟡 **SUGGESTION** (consider improving)
- [file:line] Issue description
  → Consider: Alternative approach

✅ **GOOD** (positive observations)
- Well-structured error handling in [file]
- Good test coverage for edge cases

---
**Summary**: X critical, Y warnings, Z suggestions
**Recommendation**: [Ready to commit / Fix critical issues first / Consider addressing warnings]
```

### Severity Guidelines

**🔴 CRITICAL** - Must fix before committing:
- Security vulnerabilities (injection, exposed secrets)
- Data loss or corruption risks
- Crashes or unhandled exceptions in critical paths
- Breaking changes without migration

**🟠 WARNING** - Should fix:
- Bugs that affect functionality
- Missing error handling
- Performance issues
- Missing tests for new logic

**🟡 SUGGESTION** - Consider improving:
- Code style inconsistencies
- Minor optimizations
- Documentation gaps
- Refactoring opportunities

**✅ GOOD** - Positive observations:
- Well-designed solutions
- Good patterns worth noting
- Thorough error handling
- Comprehensive tests

## Output Guidelines

- Be **concise** - focus on actual problems, not style nitpicks
- Provide **specific line references** for each finding
- Include **actionable fix suggestions**
- If clean code, say so briefly: "No issues found. Ready to commit."
- Group related findings together
- Prioritize by severity (critical first)

## Example Output

```
## Review Summary

Adding user authentication endpoint with password validation.

### Findings

🔴 **CRITICAL**
- app/controllers/auth_controller.rb:45 - Password logged in plaintext
  → Fix: Remove `logger.info("Password: #{password}")` or use `[FILTERED]`

🟠 **WARNING**
- app/models/user.rb:23 - Missing index on email column used in login query
  → Fix: Add `add_index :users, :email` migration

🟡 **SUGGESTION**
- app/controllers/auth_controller.rb:30 - Magic number for token expiry
  → Consider: Extract `TOKEN_EXPIRY_HOURS = 24` as a constant

✅ **GOOD**
- Proper bcrypt password hashing implemented
- Rate limiting applied to login endpoint

---
**Summary**: 1 critical, 1 warning, 1 suggestion
**Recommendation**: Fix critical issue (password logging) before committing
```
