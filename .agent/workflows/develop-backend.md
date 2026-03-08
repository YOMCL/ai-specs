# Develop Backend

Implement backend feature following the plan file.

## Steps

* Read the implementation plan file provided (run `/plan-backend-ticket` first if no plan exists)
* Switch to the feature branch from Step 0 of the plan (create if it doesn't exist)
* For each implementation step, follow TDD strictly:
  - Write failing unit test first (RED)
  - Implement minimum code to pass the test (GREEN)
  - Refactor while keeping tests green (REFACTOR)
* Run the full test suite after each step before proceeding
* Ensure TypeScript compiles with no errors and linting passes
* Follow all rules in `ai-specs/specs/backend-standards.mdc`
* Complete the documentation update step (mandatory)
* Stage only the files changed by this ticket
* Commit using Conventional Commits format
* Push and open a PR linked to the Linear ticket using `gh pr create`
* Move the ticket status to **In Review** in Linear using the MCP
