# Plan Backend Ticket

Generate a detailed backend implementation plan from a Linear ticket.

## Steps

* Adopt the role defined in `ai-specs/.agents/backend-developer.md`
* Fetch the Linear ticket using the MCP (or read the local file if one is referenced)
* Move the ticket status to **In Progress** in Linear using the MCP
* Analyze requirements and map them to the architecture layers (Domain, Application, Infrastructure, Presentation)
* Produce a step-by-step backend implementation plan following DDD and hexagonal architecture principles from `ai-specs/specs/backend-standards.mdc`
* Include: Step 0 (feature branch), domain entities, use cases, repository ports, infrastructure adapters, controllers, unit tests (TDD), and documentation updates
* Save the plan as a markdown file at `ai-specs/changes/[ticket_id]_backend.md`
* Do not write implementation code — only produce the plan
