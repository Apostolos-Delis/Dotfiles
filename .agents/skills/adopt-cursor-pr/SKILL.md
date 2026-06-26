---
name: adopt-cursor-pr
description: Adopt a Cursor-created GitHub pull request under the authenticated user's GitHub identity. Use when given a GitHub PR URL or number that should be closed and recreated from an owned branch, with Thermos review/remediation run before pushing and opening the replacement PR.
---

# Adopt Cursor PR

## Overview

Recreate a Cursor-authored PR as a new PR opened by the current `gh` user, then run Thermos and push any resulting fixes before opening the replacement.

The destructive action is closing the original PR. Do not close it until the replacement branch has been created locally, Thermos has been run, fixes have been committed if needed, and the replacement PR has opened successfully.

## Workflow

### 1. Preflight

1. Require an explicit PR URL or PR number. If only a number is provided, operate in the current repository.
2. Verify authentication and identity:

```bash
gh auth status
GH_USER="$(gh api user --jq .login)"
git config user.name
git config user.email
```

3. Stop if the working tree has unrelated local changes. Ask before moving or stashing them.
4. Resolve the base repository and PR number. For a URL, derive them from the URL; for a bare number, use the current repository:

```bash
if [[ "$PR" =~ github.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
  BASE_REPO="${BASH_REMATCH[1]}"
  PR_NUMBER="${BASH_REMATCH[2]}"
else
  BASE_REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
  PR_NUMBER="$PR"
fi
```

5. Fetch PR metadata before changing anything:

```bash
gh pr view "$PR_NUMBER" --repo "$BASE_REPO" \
  --json number,url,title,body,baseRefName,headRefName,headRepository,headRepositoryOwner,author,isDraft,state,mergedAt \
  --jq '{number,url,title,body,baseRefName,headRefName,headRepository,headRepositoryOwner,author,isDraft,state,mergedAt}'
```

6. Stop if the PR was merged. If it is already closed but not merged, continue adoption and skip the close step later.
7. If the PR author does not look like Cursor/bot automation and the user did not explicitly ask to close that exact PR, confirm before proceeding.

### 2. Check Out The Target Repository

If the current directory is not the base repository, clone or enter it first:

```bash
gh repo view "$BASE_REPO" >/dev/null
```

Use an existing clean checkout when available. Otherwise clone it into the user's normal repo directory.
After entering the repo, verify `origin` points at `BASE_REPO`; if a different remote points at the base repo, use that remote name in the fetch/push commands below.

### 3. Create An Owned Branch From The Original PR

Fetch the base and PR head, then create a new branch owned by the authenticated user:

```bash
BASE_REF="$(gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json baseRefName --jq .baseRefName)"
NEW_BRANCH="${GH_USER}/adopt-cursor-pr-${PR_NUMBER}"
if git show-ref --quiet --verify "refs/heads/${NEW_BRANCH}"; then
  NEW_BRANCH="${NEW_BRANCH}-$(date +%Y%m%d%H%M)"
fi

git fetch origin "$BASE_REF"
git fetch origin "pull/${PR_NUMBER}/head"
git switch -c "$NEW_BRANCH" FETCH_HEAD
```

Verify the adopted branch contains the same intended PR diff:

```bash
git diff --stat "origin/${BASE_REF}...HEAD"
git diff --name-status "origin/${BASE_REF}...HEAD"
```

Do not force-push or mutate the original Cursor branch.

### 4. Run Thermos And Remediate

Load and use `.agents/skills/thermos/SKILL.md` from the current repo or the shared Dotfiles skills directory. Run Thermos against the replacement branch diff:

```bash
git diff "origin/${BASE_REF}...HEAD"
```

For each high-confidence Thermos finding:

1. Read the relevant code and surrounding context.
2. Make the smallest correct fix.
3. Run the narrowest meaningful validation.
4. Commit only real fixes:

```bash
git add -A
git commit -m "address review findings"
```

If Thermos finds no issues, do not create an empty commit.

### 5. Push The Owned Branch

Push the new branch under the authenticated user's credentials:

```bash
git push --set-upstream origin "$NEW_BRANCH"
```

If pushing to the base repository is denied, use a fork only after confirming the repository policy permits fork PRs for this work.

### 6. Open The Replacement PR

Create a PR with the original title and body, plus an adoption note and the validation actually run. Preserve draft status when the source PR was a draft.

```bash
TITLE="$(gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json title --jq .title)"
IS_DRAFT="$(gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json isDraft --jq .isDraft)"
BODY_FILE="$(mktemp -t adopted-pr-body.XXXXXX.md)"

gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json body --jq '.body // ""' > "$BODY_FILE"
cat >> "$BODY_FILE" <<EOF

---

Adopted from $BASE_REPO#$PR_NUMBER by @$GH_USER so this PR is authored by the account that will own follow-up changes.

Thermos:
- <summarize findings fixed, or say no high-confidence issues found>

Validation:
- <list exact commands run>
EOF

CREATE_ARGS=(--base "$BASE_REF" --head "$NEW_BRANCH" --title "$TITLE" --body-file "$BODY_FILE")
if [ "$IS_DRAFT" = "true" ]; then
  CREATE_ARGS+=(--draft)
fi
gh pr create "${CREATE_ARGS[@]}"
```

Capture the replacement PR URL from `gh pr create`.

### 7. Close The Original PR

Close the Cursor PR only after the replacement PR exists. If the original PR is already closed, leave it closed and optionally add the same cross-link comment.

```bash
ORIGINAL_STATE="$(gh pr view "$PR_NUMBER" --repo "$BASE_REPO" --json state --jq .state)"
if [ "$ORIGINAL_STATE" = "OPEN" ]; then
  gh pr close "$PR_NUMBER" --repo "$BASE_REPO" --comment "Recreated under @$GH_USER as $NEW_PR_URL. Closing this Cursor-authored PR in favor of the replacement."
else
  gh pr comment "$PR_NUMBER" --repo "$BASE_REPO" --body "Recreated under @$GH_USER as $NEW_PR_URL. Leaving this original Cursor-authored PR closed."
fi
```

Do not delete the original source branch unless the user explicitly asks.

## Final Response

Report:

- Original PR URL and close status
- Replacement PR URL
- New branch name
- Thermos findings fixed, or that no high-confidence issues were found
- Validation commands run
- Commit SHAs added by remediation
- Any permissions, review metadata, labels, or branch cleanup left unresolved
