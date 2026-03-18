---
name: address-pr-comments
description: Fetch all actionable GitHub PR conversation comments, review summaries, and inline review threads; address feedback item by item; resolve addressed threads with gh CLI; validate, commit, and push.
argument-hint: [pr-number-or-url]
allowed-tools: Read, Bash, Glob, Grep, Edit, Write
disable-model-invocation: true
---

# Address PR Comments

Handle GitHub pull request feedback end to end. Be methodical, conservative, and complete.

## Supporting File

Use `scripts/collect_pr_feedback.py` to fetch and normalize:
- PR metadata
- top-level PR conversation comments
- submitted review bodies
- inline review threads

Use this shell setup when you need the bundled script path:

```bash
SKILL_DIR="${CLAUDE_SKILL_DIR:-.agents/skills/address-pr-comments}"
FEEDBACK_FILE="$(mktemp -t address-pr-comments.XXXXXX.json)"
```

If the skill was invoked with a PR number or PR URL, pass that exact value as the single argument to `collect_pr_feedback.py`. If not, omit the argument so the script auto-detects the PR from the current branch.

## Goal

1. Fetch all actionable feedback from the PR.
2. Build a numbered checklist of actionable items.
3. Work through them one by one.
4. Make the smallest correct code or test changes.
5. Run validation.
6. Commit and push when code changed.
7. Reply on GitHub where needed.
8. Resolve addressed review threads.

## Hard Rules

- Do not rely only on built-in PR comment collection.
- Ignore approvals, praise, bot noise, empty comments, and duplicates.
- Ignore resolved or outdated threads unless the current diff reintroduced the problem.
- If feedback is a question, answer it instead of changing code.
- Do not resolve a thread unless the code or explanation fully addresses it.
- Prefer a single commit: `address PR review feedback`.
- Never force-push unless the user explicitly asks.
- Do not create an empty commit.
- If GitHub permissions or failing checks block progress, report that clearly and leave the item unresolved.

## Step 1: Collect Normalized Feedback

Run the bundled script and inspect the JSON it returns. The JSON includes:
- `repository`
- `pull_request`
- `counts`
- `issue_comments`
- `reviews`
- `review_threads`
- `items`

Stop immediately if the fetch fails.

## Step 2: Build the Checklist

Create a scratch checklist with one row per actionable item. Capture:
- stable identifier
- source type: `issue-comment`, `review-body`, or `review-thread`
- reviewer
- URL
- file path if present
- concise request
- response plan: `code-change`, `test-change`, `reply-only`, or `skip`
- status: `todo`, `doing`, `done`, `skipped`, or `blocked`
- linked items that share the same root cause

Deduplicate aggressively:
- Prefer an unresolved inline thread over the same point repeated in a review body.
- If multiple comments point to one bug, fix it once and mark every linked item together.
- Skip bot summaries that only restate already captured inline comments.

## Step 3: Process Items in Order

For each checklist item:

1. Read the relevant code before editing.
2. Decide whether the right answer is a code change, a test change, a reply, or a deliberate skip.
3. Make the smallest correct change.
4. Re-read the original feedback and verify the change actually addresses it.
5. Update the checklist status.

After any meaningful code change, run the narrowest useful validation first:
- touched test file
- relevant package or target
- linter or formatter for touched files
- typecheck for the touched package
- broader suite only if needed

## Step 4: Verify Before Commit

Before committing:
- inspect `git diff --stat`
- inspect `git diff`
- inspect `git status`
- ensure no unrelated files were changed
- run relevant tests or checks
- confirm each completed checklist item is actually addressed
- leave blocked or disputed items unresolved

If a requested change should not be made, prepare a clear GitHub reply explaining why and mark the item as `skipped` or `blocked`.

## Step 5: Commit and Push

If there are code changes:

```bash
git add -A
git commit -m "address PR review feedback"
git push
```

If there are only GitHub replies and no code changes, skip the commit.

## Step 6: Reply and Resolve on GitHub

### Inline Review Threads

After the relevant code is pushed or the explanation is final, post a brief reply that says what changed and where it changed:

```bash
gh api graphql \
  -f query='
mutation($threadId:ID!, $body:String!) {
  addPullRequestReviewThreadReply(input:{
    pullRequestReviewThreadId:$threadId,
    body:$body
  }) {
    comment { url }
  }
}' \
  -f threadId="THREAD_NODE_ID" \
  -f body="Addressed in the latest commit: <short explanation>"
```

Then resolve the thread:

```bash
gh api graphql \
  -f query='
mutation($threadId:ID!) {
  resolveReviewThread(input:{threadId:$threadId}) {
    thread { id isResolved }
  }
}' \
  -f threadId="THREAD_NODE_ID"
```

If either mutation fails because of permissions or API errors, leave the thread unresolved and record the blocker.

### Top-Level Comments and Review Summaries

If an issue comment or review body needs a response, post one concise PR comment. Do not spam duplicate replies.

```bash
gh api "repos/OWNER/REPO/issues/PR_NUMBER/comments" \
  -f body="Addressed: <short explanation>"
```

If a requested change should not be made, explain why in the GitHub reply. Leave related inline threads unresolved unless the explanation fully closes the loop.

## Final Response

Return a compact summary with:
- PR number and URL
- items addressed
- reply-only items
- skipped items
- blocked or unresolved items
- validations run
- commit SHA and branch pushed, if any
- threads intentionally left unresolved
