# Plan Frontend Ticket

Generate a detailed frontend implementation plan from a Linear ticket.

## Steps

* Adopt the role defined in `ai-specs/.agents/frontend-developer.md`
* Fetch the Linear ticket using the MCP (or read the local file if one is referenced)
* Move the ticket status to **In Progress** in Linear using the MCP
* Analyze requirements and map them to components, services, and routing
* Produce a step-by-step frontend implementation plan following React/Next.js best practices from `ai-specs/specs/frontend-standards.mdc`
* Include: Step 0 (feature branch), service layer, components (Atomic Design), routing, Cypress E2E tests, and documentation updates
* If a Figma or design URL is available, analyze it using the available MCP tool
* Save the plan as a markdown file at `ai-specs/changes/[ticket_id]_frontend.md`
* Do not write implementation code — only produce the plan
