---
description: Audit UI code for AI-generated design anti-patterns — catch the tells that make interfaces look obviously machine-made
allowed-tools: Read, Bash, Glob, Grep
---

# Design Review

Audit uncommitted UI changes for common design anti-patterns. Catches the visual tells that make AI-generated interfaces obvious.

> **Philosophy**: Good design is invisible. Bad design is a trust signal. Users decide if they trust your product before reading a single word.

## Instructions

### Step 1: Identify UI Files

Find frontend files in the diff:

```bash
git diff HEAD --name-only | grep -iE '\.(css|scss|sass|less|tsx|jsx|vue|svelte|html|erb)$'
```

Also check for Tailwind config, theme files, or design tokens:

```bash
find . -maxdepth 3 -name 'tailwind.config*' -o -name 'theme.*' -o -name 'design-tokens*' -o -name 'system.md' 2>/dev/null | head -10
```

If no UI files changed, tell the user: "No frontend changes detected." and stop.

### Step 2: Check for Existing Design System

Look for a design system source of truth:
- `system.md` or `DESIGN.md` in project root
- `tailwind.config.*` (custom theme values)
- `theme.ts` / `theme.js` / `tokens.json`
- CSS custom properties in a variables/tokens file

If found, load it — all review findings should reference whether they're consistent with the established system.

If none exists, note it as a 🟡 SUGGESTION: "No design system file found. Consider creating one to maintain visual consistency across sessions."

### Step 3: Scan for Anti-Patterns

Review the changed UI files for these categories:

**Typography**
- Random font sizes with no scale (14px, 17px, 22px — no ratio)
- Overuse of default fonts (Inter/system-ui everywhere without intentional selection)
- Missing font-weight variation (everything is 400 or everything is 600)
- No line-height consideration (especially on long-form text)

**Color**
- Pure black (`#000000`, `rgb(0,0,0)`, `black`) instead of softer darks (`#1a1a1a`, `#111827`)
- Gray text on colored backgrounds (low contrast)
- Too many one-off color values (no palette discipline)
- Missing dark mode consideration when the project supports it

**Spacing & Layout**
- Inconsistent spacing values (mixing 12px, 15px, 20px, 24px with no scale)
- Nested cards (card inside card inside card — "card-ception")
- No consistent padding/margin rhythm
- Missing gap properties where flex/grid is used (manual margins instead)

**Interaction States**
- Missing hover states on clickable elements
- Missing focus indicators (accessibility violation)
- Missing active/pressed states on buttons
- No loading/skeleton states for async content
- No disabled state styling

**Visual Hierarchy**
- Overuse of shadows without hierarchy (everything has the same `shadow-md`)
- Inconsistent border-radius (mixing 4px, 8px, 12px, 16px, rounded-full)
- No clear visual weight distinction between primary/secondary/tertiary actions
- Everything competing for attention (no focal point)

**Responsive**
- Hardcoded widths that will break on mobile
- Missing responsive breakpoints on layout components
- Fixed font sizes that don't scale
- Images without max-width constraints

### Step 4: Check Accessibility Basics

These are non-negotiable:
- Color contrast ratios (text must be readable — WCAG AA minimum)
- Focus indicators on interactive elements
- Semantic HTML (buttons for actions, links for navigation, headings in order)
- Alt text on images
- Form labels associated with inputs

### Step 5: Classify and Report

Use the same severity format as `/review`:

```
## Design Review Summary

[Brief overview of UI changes and overall visual quality assessment]

### Findings

🔴 **CRITICAL** (must fix — accessibility violations)
- [file:line] Missing focus indicators on interactive elements
  → Fix: Add `focus:ring-2 focus:ring-blue-500` or equivalent

🟠 **WARNING** (should fix — obvious anti-patterns)
- [file:line] Pure #000000 black used for text
  → Fix: Use #111827 or a dark from your color palette

🟡 **SUGGESTION** (consider — taste improvements)
- [file:line] Five different border-radius values in one component
  → Consider: Standardize on 2-3 radius tokens (sm: 4px, md: 8px, lg: 12px)

✅ **GOOD** (positive observations)
- Consistent spacing scale using Tailwind's default spacing

---
**Summary**: X critical, Y warnings, Z suggestions
**Design System**: [Consistent with system / No system found / Deviations noted]
```

### Severity Guidelines

- **🔴 CRITICAL**: Accessibility violations only (missing focus, insufficient contrast, no labels)
- **🟠 WARNING**: Obvious anti-patterns that hurt trust (pure blacks, nested cards, no interaction states, inconsistent spacing)
- **🟡 SUGGESTION**: Taste improvements (better font choices, shadow hierarchy, responsive polish)
- **✅ GOOD**: Intentional design decisions worth noting

## Output Guidelines

- Be concise — focus on patterns, not individual instances
- Group related findings (all color issues together, all spacing together)
- Provide specific fix suggestions with code snippets when possible
- If the design is clean, say so: "No anti-patterns detected. Looks intentional and consistent."
- Reference the design system when it exists
