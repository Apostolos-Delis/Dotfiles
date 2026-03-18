#!/usr/bin/env python3

import json
import re
import subprocess
import sys


THREAD_QUERY = """
query($owner:String!, $repo:String!, $pr:Int!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first:100, after:$endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
          path
          comments(first:100) {
            nodes {
              id
              url
              body
              createdAt
              author { login }
            }
          }
        }
      }
    }
  }
}
""".strip()


def run_json(command):
    completed = subprocess.run(command, capture_output=True, text=True)
    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip() or "command failed"
        raise SystemExit(message)
    try:
        return json.loads(completed.stdout or "null")
    except json.JSONDecodeError as error:
        raise SystemExit(f"failed to parse JSON from {' '.join(command)}: {error}") from error


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


def flatten_pages(payload):
    items = []
    for page in payload or []:
        if isinstance(page, list):
            items.extend(page)
        elif page is not None:
            items.append(page)
    return items


def flatten_review_threads(payload):
    threads = []
    for page in payload or []:
        review_threads = (
            ((page or {}).get("data") or {})
            .get("repository", {})
            .get("pullRequest", {})
            .get("reviewThreads", {})
        )
        threads.extend(review_threads.get("nodes") or [])
    return threads


def normalize_issue_comments(comments):
    normalized = []
    for comment in comments:
        normalized.append(
            {
                "id": comment.get("id"),
                "url": comment.get("html_url"),
                "body": comment.get("body") or "",
                "createdAt": comment.get("created_at"),
                "updatedAt": comment.get("updated_at"),
                "author": ((comment.get("user") or {}).get("login")),
                "authorAssociation": comment.get("author_association"),
            }
        )
    return normalized


def normalize_reviews(reviews):
    normalized = []
    for review in reviews:
        normalized.append(
            {
                "id": review.get("id"),
                "url": review.get("html_url"),
                "body": review.get("body") or "",
                "state": review.get("state"),
                "submittedAt": review.get("submitted_at"),
                "author": ((review.get("user") or {}).get("login")),
                "commitId": review.get("commit_id"),
            }
        )
    return normalized


def normalize_review_threads(threads):
    normalized = []
    for thread in threads:
        comments = []
        for comment in ((thread.get("comments") or {}).get("nodes") or []):
            comments.append(
                {
                    "id": comment.get("id"),
                    "url": comment.get("url"),
                    "body": comment.get("body") or "",
                    "createdAt": comment.get("createdAt"),
                    "author": ((comment.get("author") or {}).get("login")),
                }
            )
        normalized.append(
            {
                "id": thread.get("id"),
                "isResolved": bool(thread.get("isResolved")),
                "isOutdated": bool(thread.get("isOutdated")),
                "path": thread.get("path"),
                "latestComment": comments[-1] if comments else None,
                "comments": comments,
            }
        )
    return normalized


def build_items(issue_comments, reviews, review_threads):
    items = []

    for comment in issue_comments:
        if not comment["body"].strip():
            continue
        items.append(
            {
                "id": f"issue-comment:{comment['id']}",
                "source_type": "issue-comment",
                "reviewer": comment["author"],
                "url": comment["url"],
                "path": None,
                "body": comment["body"],
                "createdAt": comment["createdAt"],
            }
        )

    for review in reviews:
        if not review["body"].strip():
            continue
        items.append(
            {
                "id": f"review-body:{review['id']}",
                "source_type": "review-body",
                "reviewer": review["author"],
                "url": review["url"],
                "path": None,
                "body": review["body"],
                "createdAt": review["submittedAt"],
                "state": review["state"],
            }
        )

    for thread in review_threads:
        bodies = [comment["body"].strip() for comment in thread["comments"] if comment["body"].strip()]
        latest = thread["latestComment"] or {}
        items.append(
            {
                "id": f"review-thread:{thread['id']}",
                "source_type": "review-thread",
                "reviewer": latest.get("author"),
                "url": latest.get("url"),
                "path": thread["path"],
                "body": "\n\n".join(bodies),
                "createdAt": latest.get("createdAt"),
                "threadId": thread["id"],
                "isResolved": thread["isResolved"],
                "isOutdated": thread["isOutdated"],
            }
        )

    return sorted(items, key=lambda item: item.get("createdAt") or "")


def main():
    args = sys.argv[1:]
    if len(args) > 1:
        raise SystemExit("usage: collect_pr_feedback.py [pr-number-or-url]")

    if args and args[0] in {"-h", "--help"}:
        print("usage: collect_pr_feedback.py [pr-number-or-url]")
        return

    pr_ref = args[0] if args else None
    parsed_ref = parse_pr_ref(pr_ref)

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

    owner = owner_login(repo_view)
    name = repo_view.get("name")
    number = pull_request.get("number")

    issue_comments = normalize_issue_comments(
        flatten_pages(
            run_json(
                [
                    "gh",
                    "api",
                    "--paginate",
                    "--slurp",
                    f"repos/{owner}/{name}/issues/{number}/comments?per_page=100",
                ]
            )
        )
    )
    reviews = normalize_reviews(
        flatten_pages(
            run_json(
                [
                    "gh",
                    "api",
                    "--paginate",
                    "--slurp",
                    f"repos/{owner}/{name}/pulls/{number}/reviews?per_page=100",
                ]
            )
        )
    )
    review_threads = normalize_review_threads(
        flatten_review_threads(
            run_json(
                [
                    "gh",
                    "api",
                    "graphql",
                    "--paginate",
                    "--slurp",
                    "-f",
                    f"owner={owner}",
                    "-f",
                    f"repo={name}",
                    "-F",
                    f"pr={number}",
                    "-f",
                    f"query={THREAD_QUERY}",
                ]
            )
        )
    )
    items = build_items(issue_comments, reviews, review_threads)

    payload = {
        "repository": {
            "owner": owner,
            "name": name,
            "slug": f"{owner}/{name}",
        },
        "pull_request": {
            "number": number,
            "url": pull_request.get("url"),
            "title": pull_request.get("title"),
            "headRefName": pull_request.get("headRefName"),
            "baseRefName": pull_request.get("baseRefName"),
        },
        "counts": {
            "issue_comments": len(issue_comments),
            "reviews": len(reviews),
            "review_threads": len(review_threads),
            "unresolved_review_threads": len(
                [thread for thread in review_threads if not thread["isResolved"] and not thread["isOutdated"]]
            ),
            "items": len(items),
        },
        "issue_comments": issue_comments,
        "reviews": reviews,
        "review_threads": review_threads,
        "items": items,
    }

    json.dump(payload, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
