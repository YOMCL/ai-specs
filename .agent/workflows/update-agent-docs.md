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

For each **new feature** detected in the diff:

1. Check if a corresponding doc already exists in `.agent/Features/`
2. If not, create `agent/Features/<feature-name>.md` using `.agent/Features/_template.md` as the base — populate with real information from the code, no placeholders
3. If it exists, update the relevant sections
4. Add or update the entry in `.agent/Features/README.md`

Skip if no new features were added.

## Step 4: Update System Docs

Update only the files affected by the changes:

- **`architecture-overview.md`** — if a new module, service, or integration was added
- **`database-schema.md`** — if new collections, tables, schemas, or fields were added/changed
- **`deployment-guide.md`** — if environment variables, Docker config, or deployment steps changed
- **`project_architecture.md`** — if the tech stack, directory structure, or patterns changed

For each file updated, also update **`.agent/System/README.md`** if new files were added.

## Step 5: Update Root Index

If new files were added anywhere under `.agent/`, update **`.agent/README.md`** to include them in the relevant index table.

## Step 6: Report

Print a summary of what was updated:

```
✅ .agent/ docs updated
📄 Features: <list of created/updated files or "no changes">
🏗️ System: <list of updated files or "no changes">
```
