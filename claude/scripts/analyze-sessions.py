#!/usr/bin/env python3
"""
Claude Code Session Analyzer

Analyzes past Claude Code conversations using the Claude Code CLI to propose
improvements to your configuration (hooks, agents, CLAUDE.md, etc.)

Usage:
    ./analyze-sessions.py [--days N] [--dry-run]
"""

import argparse
import json
import re
import subprocess
import tempfile
from datetime import datetime, timedelta
from pathlib import Path


# Configuration
CONFIG = {
    "days_to_analyze": 7,
    "max_tokens_per_message": 500,
    "max_messages_per_session": 50,
    "projects_to_exclude": [],
    "output_dir": Path.home() / ".claude" / "analysis",
    "projects_dir": Path.home() / ".claude" / "projects",
    "config_dir": Path.home() / ".claude",
}


def gather_sessions(days: int) -> list[dict]:
    """Collect JSONL files from recent sessions."""
    cutoff = datetime.now() - timedelta(days=days)
    sessions = []

    projects_dir = CONFIG["projects_dir"]
    if not projects_dir.exists():
        return sessions

    for jsonl in projects_dir.glob("**/*.jsonl"):
        if jsonl.stat().st_mtime < cutoff.timestamp():
            continue

        # Extract project name from path
        project_name = jsonl.parent.name.replace("-", "/")

        if any(exc in project_name for exc in CONFIG["projects_to_exclude"]):
            continue

        sessions.append({
            "path": jsonl,
            "project": project_name,
            "modified": datetime.fromtimestamp(jsonl.stat().st_mtime),
            "size": jsonl.stat().st_size,
        })

    return sorted(sessions, key=lambda x: x["modified"], reverse=True)


def extract_messages(jsonl_path: Path) -> list[dict]:
    """Extract user/assistant messages from JSONL file."""
    messages = []

    with open(jsonl_path) as f:
        for line in f:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg_type = entry.get("type")
            if msg_type not in ("user", "assistant"):
                continue

            message = entry.get("message", {})
            role = message.get("role", msg_type)
            content = message.get("content", "")

            # Handle content blocks (assistant messages)
            if isinstance(content, list):
                text_parts = []
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "text":
                        text_parts.append(block.get("text", ""))
                content = "\n".join(text_parts)

            # Skip meta messages
            if entry.get("isMeta"):
                continue

            # Truncate long messages
            if len(content) > CONFIG["max_tokens_per_message"] * 4:
                content = content[: CONFIG["max_tokens_per_message"] * 4] + "..."

            messages.append({
                "role": role,
                "content": content,
                "timestamp": entry.get("timestamp"),
            })

    # Limit messages per session
    return messages[: CONFIG["max_messages_per_session"]]


def load_current_config() -> dict:
    """Load current Claude Code configuration."""
    config = {
        "settings": {},
        "claude_md": "",
        "agents": [],
        "commands": [],
    }

    # settings.json
    settings_path = CONFIG["config_dir"] / "settings.json"
    if settings_path.exists():
        with open(settings_path) as f:
            config["settings"] = json.load(f)

    # CLAUDE.md
    claude_md_path = CONFIG["config_dir"] / "CLAUDE.md"
    if claude_md_path.exists():
        with open(claude_md_path) as f:
            config["claude_md"] = f.read()

    # Agents
    agents_dir = CONFIG["config_dir"] / "agents"
    if agents_dir.exists():
        for agent_file in agents_dir.glob("*.md"):
            if agent_file.name == "CLAUDE.md":
                continue
            with open(agent_file) as f:
                config["agents"].append({
                    "name": agent_file.stem,
                    "content": f.read()[:1000],  # Truncate
                })

    # Commands
    commands_dir = CONFIG["config_dir"] / "commands"
    if commands_dir.exists():
        for cmd_file in commands_dir.glob("*.md"):
            with open(cmd_file) as f:
                config["commands"].append({
                    "name": cmd_file.stem,
                    "content": f.read()[:500],  # Truncate
                })

    return config


def format_sessions_for_prompt(sessions: list[dict]) -> str:
    """Format session data for the LLM prompt."""
    output = []

    for session in sessions[:20]:  # Limit to 20 most recent
        messages = extract_messages(session["path"])
        if not messages:
            continue

        # Extract project name more cleanly
        project = session["project"].split("/")[-1] if "/" in session["project"] else session["project"]

        output.append(f"\n### Session: {project}")
        output.append(f"Date: {session['modified'].strftime('%Y-%m-%d %H:%M')}")
        output.append(f"Messages: {len(messages)}")
        output.append("")

        for msg in messages:
            role_prefix = "USER" if msg["role"] == "user" else "CLAUDE"
            content = msg["content"][:300] if msg["content"] else "[empty]"
            content = content.replace("\n", " ")
            output.append(f"**{role_prefix}**: {content}")

        output.append("")

    return "\n".join(output)


def build_analysis_prompt(sessions_text: str, config: dict) -> str:
    """Build the analysis prompt for Claude."""
    agents_list = "\n".join(
        f"- `{a['name']}`: {a['content'][:200]}..."
        for a in config["agents"]
    ) or "No agents configured"

    commands_list = "\n".join(
        f"- `/{c['name']}`: {c['content'][:150]}..."
        for c in config["commands"]
    ) or "No commands configured"

    return f"""You are analyzing Claude Code conversation history to improve the user's configuration.

## Current Configuration

### settings.json
```json
{json.dumps(config['settings'], indent=2)[:2000]}
```

### CLAUDE.md (truncated)
```markdown
{config['claude_md'][:1500]}
```

### Available Agents
{agents_list}

### Available Commands
{commands_list}

## Recent Conversations

{sessions_text}

## Analysis Task

Analyze these conversations and identify:

1. **Repeated Requests** - What does the user ask for frequently that could become a command or agent?
2. **Pain Points** - Where did things take multiple turns or go wrong?
3. **Missing Context** - What did the user have to re-explain that should be in CLAUDE.md?
4. **Agent Effectiveness** - Which agents were used? Which weren't? How did they perform?
5. **Hook Opportunities** - What manual actions could be automated with hooks?
6. **Workflow Friction** - What patterns suggest inefficiency?
7. **External Resources** - What plugins, skills, or tools from the ecosystem would help?

## Known External Resources (suggest these when relevant)

**Plugins:**
- `context7` - Live documentation lookup (useful if user frequently asks about API docs)
- `hookify` - Create hooks conversationally (useful if user creates hooks often)
- `pr-review-toolkit` - PR automation (useful for PR-heavy workflows)
- `mgrep` - Semantic code search (useful for large codebases)

**Skills/Agents (from github):**
- `obra/superpowers` - SDLC bundle: planning, reviewing, testing, debugging
- `glittercowboy/taches-cc-resources` - Meta-skills: skill-auditor, hook creation
- `fcakyon/claude-codex-settings` - Hooks for code quality and tool regulation
- `affaan-m/everything-claude-code` - security-reviewer, e2e-runner, tdd-guide agents

Provide your response as JSON with this structure:
{{
    "statistics": {{
        "sessions_analyzed": <number>,
        "total_user_messages": <number>,
        "projects_touched": [<list of project names>]
    }},
    "findings": [
        {{
            "severity": "critical|medium|low|positive",
            "category": "repeated_requests|pain_points|missing_context|agent_effectiveness|hook_opportunities|workflow_friction|external_resources",
            "title": "<short title>",
            "evidence": "<specific examples from conversations>",
            "impact": "<how this affects productivity>",
            "recommendation": "<what to do about it>"
        }}
    ],
    "proposed_changes": [
        {{
            "file": "<exact file path or 'INSTALL_PLUGIN' or 'INSTALL_SKILL'>",
            "action": "CREATE|EDIT|DELETE|INSTALL",
            "reason": "<why this change helps>",
            "content": "<the actual content, diff, or install command>"
        }}
    ]
}}

Be specific and actionable. Propose real changes with real content, not vague suggestions.
Focus on the most impactful improvements (limit to top 5 findings and 3 proposed changes)."""


def analyze_with_claude(prompt: str, dry_run: bool = False) -> dict:
    """Send prompt to Claude Code CLI and parse response."""
    if dry_run:
        print("\n[DRY RUN] Would send prompt to Claude CLI")
        print(f"Prompt length: {len(prompt)} chars")
        return {
            "statistics": {"sessions_analyzed": 0, "dry_run": True},
            "findings": [],
            "proposed_changes": [],
        }

    # Write prompt to temp file (too large for command line)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        f.write(prompt)
        prompt_file = f.name

    try:
        # Use claude CLI in print mode with sonnet for cost efficiency
        result = subprocess.run(
            [
                "claude",
                "-p",  # Print mode (non-interactive)
                "--model", "sonnet",
                "--output-format", "text",
            ],
            stdin=open(prompt_file),
            capture_output=True,
            text=True,
            timeout=300,  # 5 minute timeout
        )

        if result.returncode != 0:
            print(f"Warning: Claude CLI returned non-zero: {result.returncode}")
            print(f"Stderr: {result.stderr[:500]}")
            return {
                "statistics": {"error": "cli_error"},
                "findings": [],
                "proposed_changes": [],
                "raw_response": result.stderr[:500],
            }

        response_text = result.stdout
    finally:
        Path(prompt_file).unlink()  # Clean up temp file

    # Try to parse JSON (handle markdown code blocks)
    json_match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", response_text, re.DOTALL)
    if json_match:
        response_text = json_match.group(1)
    elif response_text.strip().startswith("{"):
        pass  # Already JSON
    else:
        # Try to find JSON object in response
        start = response_text.find("{")
        end = response_text.rfind("}") + 1
        if start != -1 and end > start:
            response_text = response_text[start:end]

    try:
        return json.loads(response_text)
    except json.JSONDecodeError as e:
        print(f"Warning: Could not parse JSON response: {e}")
        return {
            "statistics": {"error": "parse_failed"},
            "findings": [],
            "proposed_changes": [],
            "raw_response": result.stdout[:1000],
        }


def generate_report(analysis: dict, sessions_count: int, days: int) -> str:
    """Generate markdown report from analysis."""
    now = datetime.now()
    report = [
        f"# Claude Code Session Analysis",
        f"Generated: {now.strftime('%Y-%m-%d %H:%M')} | Analyzed: {sessions_count} sessions over {days} days",
        "",
    ]

    # Statistics
    stats = analysis.get("statistics", {})
    report.extend([
        "## Statistics",
        f"- **Sessions analyzed**: {stats.get('sessions_analyzed', sessions_count)}",
        f"- **User messages**: {stats.get('total_user_messages', 'N/A')}",
        f"- **Projects**: {', '.join(stats.get('projects_touched', ['N/A']))}",
        "",
    ])

    # Findings
    findings = analysis.get("findings", [])
    if findings:
        report.append("## Key Findings")
        report.append("")

        severity_emoji = {
            "critical": "\U0001F534",  # red circle
            "medium": "\U0001F7E1",    # yellow circle
            "low": "\U0001F535",       # blue circle
            "positive": "\U0001F7E2",  # green circle
        }

        for finding in findings:
            emoji = severity_emoji.get(finding.get("severity", "low"), "\u2022")
            report.extend([
                f"### {emoji} {finding.get('title', 'Finding')}",
                f"**Category**: {finding.get('category', 'general')}",
                f"- **Evidence**: {finding.get('evidence', 'N/A')}",
                f"- **Impact**: {finding.get('impact', 'N/A')}",
                f"- **Recommendation**: {finding.get('recommendation', 'N/A')}",
                "",
            ])

    # Proposed Changes
    changes = analysis.get("proposed_changes", [])
    if changes:
        report.append("## Proposed Changes")
        report.append("")

        for i, change in enumerate(changes, 1):
            report.extend([
                f"### {i}. {change.get('action', 'EDIT')}: `{change.get('file', 'unknown')}`",
                f"**Reason**: {change.get('reason', 'N/A')}",
                "",
                "```",
                change.get("content", "No content provided"),
                "```",
                "",
            ])

    # Summary for SessionStart hook
    report.extend([
        "---",
        "## Quick Summary (for SessionStart)",
        "",
    ])

    critical_count = sum(1 for f in findings if f.get("severity") == "critical")
    medium_count = sum(1 for f in findings if f.get("severity") == "medium")
    changes_count = len(changes)

    if critical_count > 0:
        report.append(f"- \U0001F534 {critical_count} critical finding(s)")
    if medium_count > 0:
        report.append(f"- \U0001F7E1 {medium_count} medium finding(s)")
    if changes_count > 0:
        report.append(f"- \U0001F4DD {changes_count} proposed change(s)")
    if not findings and not changes:
        report.append("- \u2705 No significant issues found")

    return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(description="Analyze Claude Code sessions")
    parser.add_argument("--days", type=int, default=CONFIG["days_to_analyze"],
                        help="Number of days to analyze")
    parser.add_argument("--dry-run", action="store_true",
                        help="Don't call Claude API, just show what would be analyzed")
    args = parser.parse_args()

    print(f"Gathering sessions from last {args.days} days...")
    sessions = gather_sessions(args.days)
    print(f"Found {len(sessions)} sessions")

    if not sessions:
        print("No sessions found to analyze")
        return

    print("Loading current configuration...")
    config = load_current_config()

    print("Formatting sessions for analysis...")
    sessions_text = format_sessions_for_prompt(sessions)

    print("Building analysis prompt...")
    prompt = build_analysis_prompt(sessions_text, config)
    print(f"Prompt size: {len(prompt)} characters")

    print("Analyzing with Claude..." if not args.dry_run else "[DRY RUN]")
    analysis = analyze_with_claude(prompt, dry_run=args.dry_run)

    print("Generating report...")
    report = generate_report(analysis, len(sessions), args.days)

    # Save report
    output_dir = CONFIG["output_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)

    report_path = output_dir / f"{datetime.now().strftime('%Y-%m-%d')}.md"
    with open(report_path, "w") as f:
        f.write(report)

    print(f"\nReport saved to: {report_path}")

    # Also save as latest.md for easy access
    latest_path = output_dir / "latest.md"
    with open(latest_path, "w") as f:
        f.write(report)

    print(f"Also saved to: {latest_path}")

    # Print summary
    findings = analysis.get("findings", [])
    changes = analysis.get("proposed_changes", [])
    print(f"\nSummary: {len(findings)} findings, {len(changes)} proposed changes")


if __name__ == "__main__":
    main()
