# AI Specs — Specs-Driven Development Framework

A portable framework of development rules, AI agent definitions, and workflow commands designed for specs-driven development. Drop this into any project to get consistent, high-quality AI-assisted development from day one.

---

## Getting Started

### Step 1 — Copy the framework into your project

```bash
cp -r ai-specs/     your-project/ai-specs/
cp    CLAUDE.md     your-project/CLAUDE.md
cp -r .agent/       your-project/.agent/
cp -r .claude/      your-project/.claude/      # Claude Code slash commands
```

> If you use Cursor, also copy `.cursor/`.

---

### Step 2 — Run the Setup Prompt

Open your AI assistant (Claude Code, Antigravity, or Cursor) **inside the target repository** and paste the following prompt exactly as-is. This triggers a full automated adaptation of the framework to your project.

```
You are an expert software architect and AI workflow specialist.
Your task is to fully adapt the ai-specs framework that was just copied into this
repository so that every agent, command, and standard reflects this project's
actual stack and conventions — with zero manual editing required from the developer.

Work in this exact sequence. Do NOT skip any step.

────────────────────────────────────────────────────────
PHASE 1 · DISCOVERY (read only, no changes yet)
────────────────────────────────────────────────────────

1. Read the entire repository structure. Identify:
   - Runtime and language versions (Node.js, Python, Go, etc.)
   - Frameworks in use (NestJS, Express, Next.js, React, FastAPI, etc.)
   - Databases and ORMs (MongoDB/Mongoose, PostgreSQL/Prisma, etc.)
   - Test tools (Jest, Vitest, Pytest, Cypress, Playwright, etc.)
   - Monorepo layout (apps/, packages/, services/, libs/, etc.)
   - Existing domain patterns (DDD entities, modules, bounded contexts)
   - CI/CD configuration (GitHub Actions, GitLab CI, etc.)
   - Package manager (npm, yarn, pnpm, bun)

2. Read ALL files in ai-specs/specs/ and identify every placeholder,
   outdated reference, or assumption that does not match this project.

3. Read ALL files in ai-specs/.agents/ and identify capabilities that
   do not match the actual stack.

4. Read ALL files in ai-specs/.commands/ (and .agent/workflows/ if present)
   and identify broken paths, incorrect tool references, or missing context.

5. Read CLAUDE.md and .agent/rules/ — note any broken links or
   references that need updating.

Before making any changes, output a structured discovery report:
   - Detected stack (confirmed facts only, no assumptions)
   - List of files that need changes, grouped by category
   - List of spec files that are missing and must be created from scratch
   - Any ambiguities that require clarification (ask me now, before proceeding)

────────────────────────────────────────────────────────
PHASE 2 · ADAPT STANDARDS
────────────────────────────────────────────────────────

Update the following files to reflect this project's actual stack.
Replace ALL generic placeholder content with specific, accurate information.

6. ai-specs/specs/backend-standards.mdc
   - Replace the Technology Stack section with the actual runtime, frameworks,
     databases, ORMs, and testing tools used in this repository
   - Replace code examples with patterns that match the real codebase
   - Keep architecture principles (DDD, hexagonal) but adjust layer names
     to match the project's module structure

7. ai-specs/specs/frontend-standards.mdc (if a frontend exists)
   - Replace framework references with the actual UI stack
   - Update component patterns, state management, and testing tools
   - If no frontend exists in this repo, note this clearly in the file

8. If ai-specs/specs/data-model.md does not exist, create it by:
   - Reading all schema files (Mongoose schemas, Prisma models, SQL migrations,
     TypeORM entities, etc.)
   - Documenting every domain entity: fields, types, relationships, constraints
   - Mapping bounded contexts if identifiable

9. If ai-specs/specs/api-spec.yml does not exist, create it by:
   - Reading all route/controller definitions
   - Generating an OpenAPI 3.0 spec covering every existing endpoint
   - Including request/response schemas, status codes, and auth requirements

10. If ai-specs/specs/development_guide.md does not exist, create it by:
    - Reading README, package.json scripts, Makefile, docker-compose.yml, etc.
    - Documenting: local setup, environment variables, how to run tests,
      how to run the dev server, how to build for production

────────────────────────────────────────────────────────
PHASE 3 · ADAPT AGENTS
────────────────────────────────────────────────────────

11. Update ai-specs/.agents/backend-developer.md:
    - Replace every framework/library reference with the actual stack
    - Update code examples to use the project's real patterns
    - Ensure NestJS injection, Mongoose schemas, and repository patterns
      match what exists in the codebase (or remove if not applicable)

12. Update ai-specs/.agents/frontend-developer.md (if frontend exists):
    - Same as above for the frontend stack

13. Update ai-specs/.agents/testing-specialist.md:
    - Replace test tool references with the actual tools used
    - Update example test patterns to match the project's test structure

14. For software-architect.md and mkdocs-specialist.md:
    - Update any framework-specific references
    - These agents are largely framework-agnostic — only update if needed

────────────────────────────────────────────────────────
PHASE 4 · ADAPT COMMANDS & WORKFLOWS
────────────────────────────────────────────────────────

15. Verify all ai-specs/.commands/ files:
    - Confirm all file paths referenced exist in this repository
    - Update any hardcoded paths or ticket ID prefixes
    - Ensure Linear MCP calls use the correct team identifier for this project

16. If .agent/workflows/ exists, apply the same verification to all files there.

17. Update CLAUDE.md:
    - Fix any broken links to standards files
    - Add any project-specific instructions that should always apply

────────────────────────────────────────────────────────
PHASE 5 · VALIDATION REPORT
────────────────────────────────────────────────────────

18. Output a final validation report with three sections:
    ✅ ADAPTED — files updated, describe what changed
    📄 CREATED — new spec files generated, describe their content
    ⚠️  MANUAL ACTION REQUIRED — things that cannot be inferred automatically
       (e.g., Linear team/project IDs, environment variables, external service URLs)

The framework is ready when all commands can run without modification
and all agents have accurate knowledge of this project's codebase.
```

> **How to run it:**
> - **Claude Code**: paste directly into the chat (no slash command needed)
> - **Antigravity**: paste directly into the chat
> - **Cursor**: paste into Composer (Cmd+I)

The AI will ask clarifying questions before making changes. Answer them, then let it complete all 5 phases. At the end, review the ⚠️ Manual Action Required section and handle those items.

---

### Step 3 — Diagnose Technical Debt

Once the framework is adapted, run the diagnostic command to get a complete health assessment of the codebase and an actionable backlog of tech debt tickets in Linear:

```
/diagnose-repo my-project --project MyProject
```

What happens:
- Scans dependencies, code quality, test coverage, architecture compliance, API gaps, CI/CD health, and security
- Generates a structured **Health Score** report (0–100)
- Creates **Linear tickets** for every finding, grouped by root cause, with severity-based priority
- Links all tickets under a parent epic: `[DIAGNOSTIC] Tech Debt — my-project`

This gives you a clear, prioritized action plan from day one — no manual audit needed.

> Add `--assignee <name>` to auto-assign all generated tickets.

---

### Step 4 — You're ready

Once the setup prompt and diagnosis are complete, the full workflow is available. Jump to [Using the Workflow](#using-the-workflow) below.

---

## Updating the Framework

When the upstream ai-specs framework releases new commands, agents, or improved standards, use the update protocol to bring your project up to date without losing your customizations.

### How it works

The framework ships a `.manifest.json` that classifies every file into:

| Category | Behavior on update |
|---|---|
| `safe_to_overwrite` | Replaced directly from upstream (commands, generic specs) |
| `adapted` | Diff generated in `.update-review/` for AI-assisted merge |
| `symlinks` | Recreated if missing |
| `ignored` | Never touched (e.g., `changes/`) |

### Step 1 — Run the update script

```bash
# From a local clone of the upstream repo
./update-ai-specs.sh /path/to/upstream/ai-specs

# Or directly from a git URL
./update-ai-specs.sh https://github.com/YOMCL/ai-specs.git
```

The script will:
- Overwrite `safe_to_overwrite` files with the upstream versions
- Generate unified diffs for `adapted` files in `.update-review/`
- Fix any missing symlinks
- Report new upstream files not yet in the manifest

### Step 2 — AI-merge adapted files

```
/update-ai-specs
```

This command reads the pending diffs and intelligently merges upstream improvements while preserving your project-specific customizations (stack references, paths, team config).

### Step 3 — Review and commit

Review the merged changes, then commit:

```
/ship-it Updated ai-specs framework to latest upstream
```

---

## Using the Workflow

<a name="using-the-workflow"></a>

Each command automatically moves the Linear ticket to the corresponding status:

```
Linear ticket
     │
     ▼
[Backlog / Todo]
     │
     ▼  /enrich-ticket PROJ-42          (optional — if ticket lacks technical detail)
     │
[In Refinement]
     │
     ▼  /plan-backend-ticket PROJ-42    (or /plan-frontend-ticket)
     │
[In Progress]  ←─ plan saved to ai-specs/changes/PROJ-42_backend.md
     │
     ▼  /develop-backend ai-specs/changes/PROJ-42_backend.md
     │
[In Review]  ←─ PR opened and linked to the ticket
     │
     ▼  merge PR
     │
[Done]
```

---

### Step 1: Enrich the Ticket (optional)

Run this if the ticket lacks technical detail — endpoint specs, validation rules, files to modify, test requirements, etc.

```
/enrich-ticket PROJ-42
```

What happens:
- Fetches the ticket from Linear via MCP
- Evaluates completeness against product best practices
- Updates the ticket with an **[Enhanced]** section containing full technical detail
- Moves the ticket to **In Refinement**

Skip this step if the ticket already has clear acceptance criteria and technical specs.

---

### Step 2: Generate the Plan

```
/plan-backend-ticket PROJ-42
```

or

```
/plan-frontend-ticket PROJ-42
```

What happens:
- Reads the ticket from Linear
- Produces `ai-specs/changes/PROJ-42_backend.md` with a step-by-step implementation plan:
  - Architecture context (layers and files involved)
  - TDD test specifications (failing tests to write first)
  - Documentation update requirements
- Moves the ticket to **In Progress**

**Review the plan before proceeding** — this is your checkpoint to validate the proposed architecture.

---

### Step 3: Implement

```
/develop-backend ai-specs/changes/PROJ-42_backend.md
```

or

```
/develop-frontend ai-specs/changes/PROJ-42_frontend.md
```

What happens:
1. Creates branch `feature/PROJ-42-backend`
2. For each step in the plan, follows TDD strictly:
   - Writes failing test first (RED)
   - Implements minimum code to pass (GREEN)
   - Refactors (REFACTOR)
3. Runs full test suite after each step
4. Updates `api-spec.yml` and `data-model.md` as needed
5. Opens a PR linked to the Linear ticket
6. Moves the ticket to **In Review**

---

## Available Commands

### Development Commands

| Command | Description |
|---|---|
| `/enrich-ticket [id]` | Enrich a Linear ticket with technical detail |
| `/plan-backend-ticket [id]` | Generate backend implementation plan |
| `/plan-frontend-ticket [id]` | Generate frontend implementation plan |
| `/develop-backend [plan.md]` | Implement backend from plan (TDD) |
| `/develop-frontend [plan.md]` | Implement frontend from plan |
| `/ship-it [context]` | Analyze, document, commit, push, and open PR autonomously |

### Quality Commands

| Command | Description |
|---|---|
| `/diagnose-repo [repo]` | Full tech debt diagnosis + Linear ticket generation |
| `/write-tests [file/module]` | Generate comprehensive test suite |
| `/review-architecture [module]` | Architectural compliance report |

### Documentation Commands

| Command | Description |
|---|---|
| `/setup-mkdocs` | Scaffold MkDocs documentation site |
| `/create-adr [description]` | Create Architecture Decision Record |
| `/update-docs` | Update technical docs from recent changes |
| `/update-ai-specs` | AI-merge upstream changes into adapted files |
| `/meta-prompt [prompt]` | Improve a prompt using best practices |

---

## Available Agents

| Agent | Specialty |
|---|---|
| `backend-developer` | NestJS, Node.js, DDD, hexagonal architecture, MongoDB/Mongoose |
| `frontend-developer` | React/Next.js, TanStack Query, Atomic Design, Cypress |
| `testing-specialist` | TDD, Jest, Cypress, test strategy, coverage |
| `software-architect` | Clean/hexagonal architecture review, ADRs, domain modeling |
| `mkdocs-specialist` | MkDocs Material, technical documentation, API docs |

---

## Core Development Principles

All development follows:

1. **TDD**: Write failing tests before implementation (red-green-refactor)
2. **Hexagonal Architecture**: Domain has zero framework dependencies; adapters implement ports
3. **DDD**: Rich domain entities with behavior, value objects, repository interfaces
4. **English Only**: All code, comments, docs, commits, and tickets in English
5. **Type Safety**: TypeScript strict mode — no `any`
6. **90%+ Test Coverage**: Across all backend layers
7. **Conventional Commits**: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
8. **Incremental Changes**: One step at a time, reviewable PRs

---

## Technology Stack (Base Template)

Adapt per project using the Setup Prompt above. The defaults are:

**Backend:**
- Runtime: Node.js 18+ / TypeScript strict
- Framework: NestJS (new services), plain Node.js (legacy)
- Database: MongoDB + Mongoose (primary), PostgreSQL + Prisma (alternative)
- Testing: Jest (unit/integration), Cypress (E2E)

**Frontend:**
- Framework: Next.js 14+ App Router (new), React SPA (legacy)
- State: TanStack Query (server), useState/Zustand (client)
- Forms: React Hook Form + Zod
- Testing: Jest + React Testing Library, Cypress

---

## Repository Structure

```
.
├── CLAUDE.md                         # Claude Code configuration (auto-loaded)
├── update-ai-specs.sh                # Framework update script
├── ai-specs/
│   ├── specs/                        # Development standards (single source of truth)
│   │   ├── base-standards.mdc        # Core principles and language rules
│   │   ├── backend-standards.mdc     # NestJS/Node.js, DDD, hexagonal, MongoDB
│   │   ├── frontend-standards.mdc    # React/Next.js, TanStack Query, Cypress
│   │   └── documentation-standards.mdc
│   ├── .agents/                      # AI agent definitions
│   │   ├── backend-developer.md      # DDD/hexagonal backend architect
│   │   ├── frontend-developer.md     # React/Next.js component architect
│   │   ├── testing-specialist.md     # TDD, Jest, Cypress expert
│   │   ├── software-architect.md     # Clean/hexagonal architecture reviewer
│   │   └── mkdocs-specialist.md      # Technical documentation with MkDocs
│   ├── .commands/                    # Claude Code slash commands
│   │   ├── diagnose-repo.md           # Tech debt diagnosis + Linear tickets
│   │   ├── enrich-us.md              # Enrich a Linear ticket
│   │   ├── plan-backend-ticket.md    # Generate backend implementation plan
│   │   ├── plan-frontend-ticket.md   # Generate frontend implementation plan
│   │   ├── develop-backend.md        # Implement from backend plan
│   │   ├── develop-frontend.md       # Implement from frontend plan
│   │   ├── write-tests.md            # Generate test suite (TDD)
│   │   ├── review-architecture.md    # Architectural compliance review
│   │   ├── setup-mkdocs.md           # Scaffold MkDocs documentation site
│   │   ├── create-adr.md             # Create Architecture Decision Record
│   │   ├── update-docs.md            # Update technical documentation
│   │   ├── meta-prompt.md            # Improve a prompt using best practices
│   │   └── ship-it.md                # Analyze, commit, push, and open PR
│   └── changes/                      # Generated implementation plans
│       └── SCRUM-10_backend.md       # Example: Position update feature plan
├── .agent/                           # Antigravity configuration
│   ├── rules/
│   │   └── development-standards.md  # Rules auto-applied in every session
│   └── workflows/                    # Slash-command workflows for Antigravity
│       ├── diagnose-repo.md
│       ├── enrich-ticket.md
│       ├── plan-backend-ticket.md
│       ├── plan-frontend-ticket.md
│       ├── develop-backend.md
│       ├── develop-frontend.md
│       ├── write-tests.md
│       ├── review-architecture.md
│       ├── setup-mkdocs.md
│       ├── create-adr.md
│       ├── update-docs.md
│       ├── meta-prompt.md
│       └── ship-it.md
└── .cursor/rules/                    # Cursor configuration
    └── use-base-rules.mdc
```

## Multi-Copilot Support

| AI Tool | Configuration File | Auto-loads |
|---|---|---|
| Claude Code | `CLAUDE.md` | Yes |
| Antigravity | `.agent/rules/development-standards.md` | Yes |
| Cursor | `.cursor/rules/use-base-rules.mdc` | Yes |

All tools reference the same core rules in `ai-specs/specs/`, ensuring consistency.

---

## Reference Examples

The following files are included as examples from a reference ATS project:
- `ai-specs/specs/api-spec.yml` — OpenAPI 3.0 example
- `ai-specs/specs/data-model.md` — Domain model documentation example
- `ai-specs/changes/SCRUM-10_backend.md` — Complete backend implementation plan example
- `ai-specs/changes/SCRUM-10-Position-Update.md` — Enriched user story example

---

## License

Copyright (c) 2025 LIDR.co — MIT License

Part of the AI4Devs program by LIDR.co: https://lidr.co/ia-devs
