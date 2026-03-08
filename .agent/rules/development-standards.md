# Development Standards

## Core Principles
* Work in baby steps — one task at a time, never skip ahead
* Follow TDD: write a failing test FIRST, then implement, then refactor (red-green-refactor)
* All code must be fully typed with TypeScript (strict mode)
* Use clear, descriptive names for all variables, functions, and classes
* Prefer incremental, focused changes over large modifications
* Question assumptions before writing code
* Detect and highlight repeated code patterns

## Language
* ALL technical artifacts must be in English: code, comments, error messages, logs, documentation, commit messages, test names, Linear ticket content, and configuration files

## Architecture
* Follow Clean/Hexagonal Architecture: Domain → Application → Infrastructure → Presentation
* Keep domain layer framework-agnostic
* Define repository interfaces as ports in the domain layer
* Infrastructure adapters implement domain ports
* Controllers are thin — delegate to application services

## Testing
* Minimum 90% test coverage across all layers
* Unit tests: Jest (Node.js/NestJS projects)
* E2E tests: Cypress
* Follow AAA pattern (Arrange, Act, Assert)
* Tests must be independent, deterministic, and fast

## Git & Workflow
* Branch naming: `feature/[ticket-id]-backend` or `feature/[ticket-id]-frontend`
* Commit messages follow Conventional Commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
* Never commit directly to main
* Open PRs linked to Linear tickets

## Documentation
* Update `ai-specs/specs/api-spec.yml` for any API changes
* Update `ai-specs/specs/data-model.md` for any schema changes
* Follow `ai-specs/specs/documentation-standards.mdc` for all documentation rules
* Documentation updates are mandatory before marking any task complete

## Full Standards
* Backend: see `ai-specs/specs/backend-standards.mdc`
* Frontend: see `ai-specs/specs/frontend-standards.mdc`
* Documentation: see `ai-specs/specs/documentation-standards.mdc`
