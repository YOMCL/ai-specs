# Develop Frontend

Implement frontend feature following the plan file.

## Steps

* Read the implementation plan file provided (run `/plan-frontend-ticket` first if no plan exists)
* If a design URL is provided (Figma, Excalidraw), analyze it using the appropriate MCP tool
* Switch to the feature branch from Step 0 of the plan (create if it doesn't exist)
* For each step, implement: service layer functions, React/Next.js components, and routing changes
* Write Cypress E2E tests for each user-facing feature
* Use TypeScript for all new files; ensure strict typing throughout
* Follow all rules in `ai-specs/specs/frontend-standards.mdc`
* Do not introduce new dependencies unless strictly necessary (justify each one)
* Complete the documentation update step (mandatory)
* Stage only the files changed by this ticket
* Commit using Conventional Commits format
* Push and open a PR linked to the Linear ticket using `gh pr create`
* Move the ticket status to **In Review** in Linear using the MCP
