---
description: 'Update .agent/ documentation based on recent code changes'
argument-hint: '[optional context about what changed]'
---

# /update-agent-docs — Update Agent Documentation

You are executing the `/update-agent-docs` workflow. Analyze recent changes in the codebase and update the `.agent/` documentation to reflect them. Only update docs that are actually affected by the changes.

**User context (if provided):** $ARGUMENTS

## Step 1: Understand What Changed

Run `git diff main..HEAD --name-only` and `git log main..HEAD --oneline` to identify what changed. If no context was provided by the user, infer the nature of changes from the diff.

## Step 2: Check .agent/ Exists

If no `.agent/` directory exists in the project root, stop and suggest running `/init-agent-docs` first.

## Step 3: Update Features

If new features were added, spawn the `feature-documenter` agent to handle `.agent/Features/` updates. Provide it with:
- The target directory path
- The list of new/changed feature modules identified in Step 1

Skip if no new features were added.

## Step 4: Update System Docs

If architecture, DB schema, deployment, or stack changes were detected, spawn the `doc-specialist` agent to handle `.agent/System/` updates. Provide it with:
- The target directory path
- Which specific docs need updating (architecture, database, deployment, stack)
- A summary of what changed

Skip if no system-level changes were detected.

## Step 5: Update Root Index

If new files were added anywhere under `.agent/`, update **`.agent/README.md`** to include them in the relevant index table.

## Step 6: Report

Print a summary of what was updated:

```
✅ .agent/ docs updated
📄 Features: <list of created/updated files or "no changes">
🏗️ System: <list of updated files or "no changes">
```
