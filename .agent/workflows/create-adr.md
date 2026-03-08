# Create ADR

Create an Architecture Decision Record for a significant technical decision.

## Steps

* Ask for or receive the architectural decision to document
* Create the file at `docs/architecture/decisions/ADR-[NNN]-[short-title].md` using sequential numbering
* Use the following ADR template structure:
  - **Title**: ADR-NNN: Short descriptive title
  - **Date**: Current date
  - **Status**: Proposed | Accepted | Deprecated | Superseded
  - **Context**: What situation or problem prompted this decision?
  - **Decision**: What was decided?
  - **Rationale**: Why was this option chosen over alternatives?
  - **Alternatives Considered**: What other options were evaluated?
  - **Consequences**: What are the positive and negative outcomes of this decision?
  - **Related Decisions**: Links to related ADRs if applicable
* Keep the ADR concise and factual — it is a permanent record
* If this supersedes a previous ADR, update the old ADR's status to "Superseded by ADR-NNN"
* Add the new ADR to the navigation in `mkdocs.yml` if MkDocs is configured
