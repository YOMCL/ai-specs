---
description: 'Review and fix GitHub PR review comments on the current branch'
argument-hint: '[optional PR number or URL]'
---

# /fix-review-comments — Fix PR Review Comments

You are executing the `/fix-review-comments` workflow. Your job is to fetch all unresolved review comments from the current PR and fix them one by one.

**User context (if provided):** $ARGUMENTS

## Phase 1: Identify the PR

1. Run `git branch --show-current` to get the current branch.
2. If $ARGUMENTS contains a PR number or URL, use that. Otherwise, detect the PR automatically:
   ```bash
   gh pr view --json number,title,url,headRefName
   ```
3. If no PR is found for the current branch, stop and inform the user.

## Phase 2: Fetch Review Comments

1. Fetch all review comments on the PR:
   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | select(.position != null or .line != null) | {id, path, line: (.line // .original_line), side: (.side // "RIGHT"), body, user: .user.login, in_reply_to_id, diff_hunk}'
   ```
2. Also fetch top-level PR review comments (review summaries):
   ```bash
   gh pr view {number} --json reviews --jq '.reviews[] | select(.state == "CHANGES_REQUESTED" or .state == "COMMENTED") | {author: .author.login, state: .state, body: .body}'
   ```
3. Group comments by file path. Ignore comments that are just approvals or simple acknowledgments (e.g., "LGTM", "looks good").
4. Present a summary to the user:
   ```
   Found X review comments on PR #N:
   - file/path.ts (Y comments)
   - other/file.ts (Z comments)
   ```

## Phase 3: Fix Each Comment

For each file with comments, in order:

1. Read the file.
2. Read each comment and understand what change is being requested.
3. Categorize the comment:
   - **Code change requested**: Fix the code as requested.
   - **Question/clarification**: If you can address it with a code comment or improvement, do so. If it requires human input, skip it and note it at the end.
   - **Nitpick/style**: Apply the suggested style change.
   - **Disagreement/discussion**: Skip — do NOT change code for comments that are discussions. Note them at the end.
4. Apply the fix, ensuring:
   - The fix addresses exactly what the reviewer asked for.
   - No unrelated changes are introduced.
   - All project standards are followed (reference `ai-specs/specs/` as needed).
   - Tests still pass after the change.

## Phase 4: Verify

1. Run the project's test suite to make sure nothing is broken.
2. Run linting/type checking if available.
3. If any test fails, fix the issue before continuing.

## Phase 5: Commit & Push

1. Stage all changed files.
2. Create a single commit with the format:
   ```bash
   git commit -m "$(cat <<'EOF'
   ♻️ refactor: address PR review comments

   Fixes review feedback on PR #<number>:
   - <brief description of each fix>
   EOF
   )"
   ```
   If changes span multiple concerns, split into multiple commits grouped logically.
3. Push to the current branch:
   ```bash
   git push
   ```

**CRITICAL: NEVER include "Co-Authored-By: Claude" or "Generated with Claude Code" in commit messages.**

## Phase 6: Report

Print a summary:

```
Done! Fixed review comments on PR #<number>

Addressed:
- <file>: <what was fixed>
- <file>: <what was fixed>

Skipped (needs human input):
- <file>: <comment summary and why it was skipped>

Verify: <PR URL>
```

If all comments were addressed, suggest the user can re-request review.
