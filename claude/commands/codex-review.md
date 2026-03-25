---
description: "Multi-AI second opinion via OpenAI Codex CLI — three modes: review (independent diff review with pass/fail gate), challenge (adversarial, tries to break your code), consult (ask anything with session continuity). Use when asked for 'second opinion', 'codex review', 'codex challenge', or cross-model validation."
allowed-tools: Bash, Read, Write, Glob, Grep, AskUserQuestion
---

# /codex-review — Multi-AI Second Opinion

Wraps the OpenAI Codex CLI to get an independent, brutally honest second opinion from a different AI system. Present Codex output faithfully and verbatim — do not summarize or editorialize before showing it.

## Step 0: Check codex binary

```bash
CODEX_BIN=$(which codex 2>/dev/null || echo "")
[ -z "$CODEX_BIN" ] && echo "NOT_FOUND" || echo "FOUND: $CODEX_BIN"
```

If `NOT_FOUND`: stop. "Codex CLI not found. Install: `npm install -g @openai/codex`"

## Step 1: Detect mode

Parse the user's input:

1. `/codex-review` or `/codex-review review` → **Review mode** (Step 2A)
2. `/codex-review challenge` or `/codex-review challenge <focus>` → **Challenge mode** (Step 2B)
3. `/codex-review consult <prompt>` or `/codex-review <prompt>` → **Consult mode** (Step 2C)
4. No arguments + diff exists → ask:
   ```
   Codex detected changes against the base branch. What should it do?
   A) Review the diff (code review with pass/fail gate)
   B) Challenge the diff (adversarial — try to break it)
   C) Something else — I'll provide a prompt
   ```

Detect base branch:
```bash
BASE=$(git rev-parse --verify origin/main 2>/dev/null && echo "main" || echo "master")
```

---

## Step 2A: Review Mode

Run Codex code review against the current branch diff.

```bash
TMPERR=$(mktemp /tmp/codex-err-XXXXXX.txt)
codex review --base "$BASE" -c 'model_reasoning_effort="xhigh"' --enable web_search_cached 2>"$TMPERR"
```

If custom instructions provided (e.g., `/codex-review review focus on security`):
```bash
codex review "focus on security" --base "$BASE" -c 'model_reasoning_effort="xhigh"' --enable web_search_cached 2>"$TMPERR"
```

Timeout: 5 minutes.

Parse cost from stderr:
```bash
grep "tokens used" "$TMPERR" 2>/dev/null || echo "tokens: unknown"
```

Determine gate verdict: `[P1]` findings = **FAIL**, only `[P2]` or none = **PASS**.

Present:
```
CODEX SAYS (code review):
════════════════════════════════════════════════════════════
<full codex output, verbatim>
════════════════════════════════════════════════════════════
GATE: PASS                    Tokens: N
```

**Cross-model comparison:** If `/review` was already run in this conversation, compare:
```
CROSS-MODEL ANALYSIS:
  Both found: [overlapping findings]
  Only Codex found: [unique to Codex]
  Only Claude found: [unique to Claude's /review]
  Agreement rate: X%
```

Clean up: `rm -f "$TMPERR"`

---

## Step 2B: Challenge (Adversarial) Mode

Codex tries to break your code — edge cases, race conditions, security holes, failure modes.

Default prompt:
"Review the changes on this branch against the base branch. Run `git diff origin/$BASE` to see the diff. Your job is to find ways this code will fail in production. Think like an attacker and a chaos engineer. Find edge cases, race conditions, security holes, resource leaks, failure modes, and silent data corruption paths. Be adversarial. Be thorough. No compliments — just the problems."

With focus (e.g., `/codex-review challenge security`):
"...Focus specifically on SECURITY. Find every way an attacker could exploit this code..."

```bash
codex exec "<prompt>" -s read-only -c 'model_reasoning_effort="xhigh"' --enable web_search_cached 2>/dev/null
```

Timeout: 5 minutes.

Present:
```
CODEX SAYS (adversarial challenge):
════════════════════════════════════════════════════════════
<full codex output, verbatim>
════════════════════════════════════════════════════════════
Tokens: N
```

---

## Step 2C: Consult Mode

Ask Codex anything about the codebase. Supports follow-ups.

```bash
codex exec "<user's prompt>" -s read-only -c 'model_reasoning_effort="xhigh"' --enable web_search_cached 2>/dev/null
```

Timeout: 5 minutes.

Present:
```
CODEX SAYS (consult):
════════════════════════════════════════════════════════════
<full codex output, verbatim>
════════════════════════════════════════════════════════════
Tokens: N
```

After presenting, note any disagreements: "Note: Claude Code disagrees on X because Y."

---

## Rules

- **Never modify files.** This skill is read-only. Codex runs in read-only sandbox mode.
- **Present output verbatim.** Do not truncate, summarize, or editorialize before showing it.
- **Add synthesis after, not instead of.** Any Claude commentary comes after the full output.
- **5-minute timeout** on all Bash calls to codex.
- **No double-reviewing.** If the user already ran `/review`, Codex provides a second independent opinion. Do not re-run Claude's own review.
- **Max reasoning.** All modes use `model_reasoning_effort="xhigh"` — maximum reasoning power for reviews.
