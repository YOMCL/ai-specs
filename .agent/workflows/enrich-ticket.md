# Enrich Linear Ticket

Enrich and improve a Linear ticket with technical detail for autonomous implementation.

## Steps

* Use the Linear MCP to fetch the ticket by ID, keyword, or status (e.g., "the one in progress")
* Act as a product expert with technical knowledge to analyze the ticket
* Evaluate completeness: does it have full functionality description, endpoint URLs, files to modify, test requirements, and non-functional requirements?
* If lacking detail: write an improved version that is clearer, more specific, and technically complete using context from `ai-specs/specs/`
* Update the ticket in Linear with the enhanced content added after the original, using **[Original]** and **[Enhanced]** section headings with proper markdown formatting
* Move the ticket status to **In Refinement** (unless already Done or Cancelled)
