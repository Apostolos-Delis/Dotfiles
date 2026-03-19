#!/usr/bin/env python3

import json
import re
import subprocess
import sys


CHECK_FIELDS = "bucket,completedAt,description,event,link,name,startedAt,state,workflow"
RUN_FIELDS = (
    "databaseId,name,workflowName,displayTitle,event,status,conclusion,"
    "createdAt,updatedAt,url,headBranch,headSha"
)
PROBLEM_BUCKETS = {"fail", "cancel", "pending"}
PROBLEM_CONCLUSIONS = {"action_required", "cancelled", "failure", "startup_failure", "timed_out"}
PROBLEM_STATUSES = {"action_required", "in_progress", "pending", "queued", "requested", "waiting"}


def run_json(command, allowed_returncodes=None):
    if allowed_returncodes is None:
        allowed_returncodes = {0}
    completed = subprocess.run(command, capture_output=True, text=True)
    if completed.returncode not in allowed_returncodes:
        message = completed.stderr.strip() or completed.stdout.strip() or "command failed"
        raise SystemExit(message)
    try:
        return json.loads(completed.stdout or "null")
    except json.JSONDecodeError as error:
        raise SystemExit(f"failed to parse JSON from {' '.join(command)}: {error}") from error


def run_text(command):
    completed = subprocess.run(command, capture_output=True, text=True)
    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip() or "command failed"
        raise SystemExit(message)
    return completed.stdout.strip()


def parse_pr_ref(value):
    if not value:
        return None
    match = re.match(r"^https://github\\.com/([^/]+)/([^/]+)/pull/(\\d+)(?:/.*)?$", value)
    if not match:
        return None
    owner, name, number = match.groups()
    return {"owner": owner, "name": name, "number": int(number)}


def owner_login(repo):
    owner = repo.get("owner")
    if isinstance(owner, dict):
        return owner.get("login") or owner.get("name")
    return owner


def normalize_text(value):
    return re.sub(r"[^a-z0-9]+", " ", (value or "").lower()).strip()


def classify_check(check):
    text = " ".join(
        [
            check.get("name") or "",
            check.get("workflow") or "",
            check.get("description") or "",
        ]
    ).lower()

    patterns = [
        ("docker", r"\b(docker|container|image)\b"),
        ("typecheck", r"\b(type|types|typecheck|tsc|pyright|mypy|sorbet)\b"),
        ("lint", r"\b(lint|eslint|rubocop|ruff|flake8|prettier|format)\b"),
        ("test", r"\b(test|tests|spec|specs|rspec|pytest|jest|vitest|unit|integration|e2e)\b"),
        ("build", r"\b(build|compile|bundle|packag|artifact)\b"),
        ("deploy", r"\b(deploy|release|helm|terraform|rollout)\b"),
        ("security", r"\b(codeql|security|snyk|trivy|scan|vuln)\b"),
        ("infra", r"\b(workflow|actions|runner|infra|setup|install)\b"),
    ]

    for category, pattern in patterns:
        if re.search(pattern, text):
            return category
    return "unknown"


def normalize_checks(checks):
    normalized = []
    for check in checks:
        normalized.append(
            {
                "name": check.get("name"),
                "workflow": check.get("workflow"),
                "bucket": check.get("bucket"),
                "state": check.get("state"),
                "description": check.get("description"),
                "event": check.get("event"),
                "link": check.get("link"),
                "startedAt": check.get("startedAt"),
                "completedAt": check.get("completedAt"),
                "category": classify_check(check),
            }
        )
    return normalized


def run_problematic(run):
    status = run.get("status")
    conclusion = run.get("conclusion")
    return conclusion in PROBLEM_CONCLUSIONS or status in PROBLEM_STATUSES


def normalize_runs(runs):
    normalized = []
    for run in runs:
        normalized.append(
            {
                "databaseId": run.get("databaseId"),
                "name": run.get("name"),
                "workflowName": run.get("workflowName"),
                "displayTitle": run.get("displayTitle"),
                "event": run.get("event"),
                "status": run.get("status"),
                "conclusion": run.get("conclusion"),
                "createdAt": run.get("createdAt"),
                "updatedAt": run.get("updatedAt"),
                "url": run.get("url"),
                "headBranch": run.get("headBranch"),
                "headSha": run.get("headSha"),
                "problematic": run_problematic(run),
            }
        )
    return normalized


def score_run_match(check, run):
    check_names = [
        check.get("workflow"),
        check.get("name"),
    ]
    run_names = [
        run.get("workflowName"),
        run.get("name"),
        run.get("displayTitle"),
    ]

    score = 0
    for check_name in check_names:
        for run_name in run_names:
            if not check_name or not run_name:
                continue
            if check_name == run_name:
                score = max(score, 5)
            elif normalize_text(check_name) == normalize_text(run_name):
                score = max(score, 4)
            elif normalize_text(check_name) and normalize_text(check_name) in normalize_text(run_name):
                score = max(score, 2)
    return score


def attach_candidate_runs(checks, runs):
    enriched = []
    for check in checks:
        matches = []
        for run in runs:
            score = score_run_match(check, run)
            if score <= 0:
                continue
            matches.append(
                {
                    "databaseId": run["databaseId"],
                    "workflowName": run["workflowName"],
                    "name": run["name"],
                    "status": run["status"],
                    "conclusion": run["conclusion"],
                    "url": run["url"],
                    "score": score,
                }
            )
        matches.sort(key=lambda item: (-item["score"], -(item["databaseId"] or 0)))
        updated = dict(check)
        updated["candidateRuns"] = matches
        enriched.append(updated)
    return enriched


def main():
    args = sys.argv[1:]
    if len(args) > 1:
        raise SystemExit("usage: collect_pr_checks.py [pr-number-or-url]")

    if args and args[0] in {"-h", "--help"}:
        print("usage: collect_pr_checks.py [pr-number-or-url]")
        return

    pr_ref = args[0] if args else None
    parsed_ref = parse_pr_ref(pr_ref)

    branch = run_text(["git", "branch", "--show-current"])
    sha = run_text(["git", "rev-parse", "HEAD"])

    pr_view_command = ["gh", "pr", "view"]
    if pr_ref:
        pr_view_command.append(pr_ref)
    pr_view_command.extend(["--json", "number,url,title,headRefName,baseRefName"])
    pull_request = run_json(pr_view_command)

    if parsed_ref:
        repo_view = run_json(
            ["gh", "repo", "view", f"{parsed_ref['owner']}/{parsed_ref['name']}", "--json", "owner,name"]
        )
    else:
        repo_view = run_json(["gh", "repo", "view", "--json", "owner,name"])

    checks_command = ["gh", "pr", "checks"]
    if pr_ref:
        checks_command.append(pr_ref)
    checks_command.extend(["--json", CHECK_FIELDS])
    checks = normalize_checks(run_json(checks_command, allowed_returncodes={0, 8}))

    runs = normalize_runs(
        run_json(
            [
                "gh",
                "run",
                "list",
                "--branch",
                branch,
                "--commit",
                sha,
                "--json",
                RUN_FIELDS,
                "--limit",
                "30",
            ]
        )
    )

    checks = attach_candidate_runs(checks, runs)
    problem_checks = [check for check in checks if check["bucket"] in PROBLEM_BUCKETS]
    failing_runs = [run for run in runs if run["problematic"]]

    owner = owner_login(repo_view)
    name = repo_view.get("name")

    payload = {
        "repository": {
            "owner": owner,
            "name": name,
            "slug": f"{owner}/{name}",
        },
        "branch": {
            "name": branch,
            "sha": sha,
        },
        "pull_request": {
            "number": pull_request.get("number"),
            "url": pull_request.get("url"),
            "title": pull_request.get("title"),
            "headRefName": pull_request.get("headRefName"),
            "baseRefName": pull_request.get("baseRefName"),
        },
        "counts": {
            "checks": len(checks),
            "problem_checks": len(problem_checks),
            "failing_checks": len([check for check in checks if check["bucket"] == "fail"]),
            "pending_checks": len([check for check in checks if check["bucket"] == "pending"]),
            "cancelled_checks": len([check for check in checks if check["bucket"] == "cancel"]),
            "runs": len(runs),
            "failing_runs": len(failing_runs),
        },
        "checks": checks,
        "problem_checks": problem_checks,
        "runs": runs,
        "failing_runs": failing_runs,
    }

    json.dump(payload, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
