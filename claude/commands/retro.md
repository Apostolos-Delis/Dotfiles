---
description: Weekly engineering retrospective — analyze commit history, work patterns, shipping velocity, and code quality
allowed-tools: Bash, Read, Write, Glob
---

# /retro — Engineering Retrospective

Generates a comprehensive engineering retrospective analyzing commit history, work patterns, and code quality metrics.

## Arguments
- `/retro` — default: last 7 days
- `/retro 24h` — last 24 hours
- `/retro 14d` — last 14 days
- `/retro 30d` — last 30 days
- `/retro compare` — compare current window vs prior same-length window

## Instructions

Parse the argument to determine the time window. Default to 7 days. Use `--since` for git log queries. Report times in the user's local timezone if known, otherwise use the system timezone.

### Step 1: Gather Raw Data

Fetch origin first, then run ALL git commands in parallel:

```bash
git fetch origin main --quiet

# All commits with timestamps, subject, hash, stats
git log origin/main --since="<window>" --format="%H|%ai|%s" --shortstat

# Per-commit test vs production LOC
git log origin/main --since="<window>" --format="COMMIT:%H" --numstat

# Timestamps for session detection
git log origin/main --since="<window>" --format="%at|%ai|%s" | sort -n

# Hotspot analysis
git log origin/main --since="<window>" --format="" --name-only | grep -v '^$' | sort | uniq -c | sort -rn

# PR numbers from commits
git log origin/main --since="<window>" --format="%s" | grep -oE '#[0-9]+' | sort -n | uniq
```

### Step 2: Summary Table

| Metric | Value |
|--------|-------|
| Commits to main | N |
| PRs merged | N |
| Total insertions / deletions | N / N |
| Net LOC | N |
| Test LOC ratio | N% |
| Active days | N |
| Detected sessions | N |
| Avg LOC/session-hour | N |

### Step 3: Time Distribution

Show hourly histogram of commits. Call out:
- Peak hours and dead zones
- Bimodal vs continuous patterns
- Late-night coding clusters

### Step 4: Session Detection

Detect coding sessions using a **45-minute gap** between commits. For each session report start/end time, commits, and duration.

Classify:
- **Deep** (50+ min)
- **Medium** (20-50 min)
- **Micro** (<20 min)

Calculate total active time, average session length, LOC per active hour.

### Step 5: Commit Type Breakdown

Categorize by conventional commit prefix (feat/fix/refactor/test/chore/docs). Show as percentage bar chart.

Flag if fix ratio exceeds 50% — signals "ship fast, fix fast" pattern.

### Step 6: Hotspot Analysis

Top 10 most-changed files. Flag:
- Files changed 5+ times (churn hotspots)
- Test vs production file balance

### Step 7: PR Size Distribution

Bucket PRs by LOC: Small (<100), Medium (100-500), Large (500-1500), XL (1500+). Flag XL PRs.

### Step 8: Focus Score + Ship of the Week

**Focus score:** % of commits in the most-changed top-level directory. Higher = deeper focus.

**Ship of the week:** Highest-LOC PR — title, LOC, and why it matters.

### Step 9: Streak Tracking

Count consecutive days with commits to origin/main:

```bash
git log origin/main --format="%ad" --date=format:"%Y-%m-%d" | sort -u
```

Count backward from today. Display: "Shipping streak: N consecutive days"

### Step 10: Save History

Save a JSON snapshot for trend tracking:

```bash
mkdir -p .context/retros
```

Save to `.context/retros/<date>-<seq>.json` with metrics, version range, streak, and a tweetable summary line.

If prior retros exist, load the most recent and show a **Trends vs Last Retro** comparison table with deltas and arrows.

### Step 11: Write the Narrative

Structure:

**Tweetable summary** (first line):
```
Week of Mar 1: 47 commits, 3.2k LOC, 38% tests, 12 PRs | Streak: 47d
```

Then sections:
1. **Summary Table**
2. **Trends vs Last Retro** (if available)
3. **Time & Session Patterns** — interpret what the patterns mean
4. **Shipping Velocity** — commit type mix, PR sizes, fix chains
5. **Code Quality Signals** — test ratio, hotspots, XL PRs
6. **Focus & Highlights** — focus score, ship of the week
7. **Top 3 Wins** — highest-impact things shipped, why they matter
8. **3 Things to Improve** — specific, actionable, anchored in commits
9. **3 Habits for Next Week** — small, practical (<5 min to adopt)

## Compare Mode

When `/retro compare`:
1. Compute current window metrics
2. Compute prior same-length window metrics (using `--since` and `--until`)
3. Side-by-side comparison with deltas
4. Brief narrative on biggest improvements and regressions

## Tone

- Encouraging but candid
- Always anchor in actual commits/code
- Skip generic praise — say exactly what was good
- Frame improvements as leveling up
- ~2500-3500 words total
- Only file written is `.context/retros/` JSON snapshot
