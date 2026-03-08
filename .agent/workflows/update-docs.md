# Update Docs

Update technical documentation to reflect recent code changes.

## Steps

* Review all recent changes in the codebase (git diff or specified files)
* Follow the rules in `ai-specs/specs/documentation-standards.mdc`
* Identify which documentation files need updates:
  - Data model or schema changes → Update `ai-specs/specs/data-model.md`
  - New or modified API endpoints → Update `ai-specs/specs/api-spec.yml`
  - New libraries, dependencies, or configuration → Update relevant `*-standards.mdc` files
  - Architecture changes → Update architecture docs or create a new ADR
* Update each affected file in English, maintaining consistency with existing structure
* Verify all changes are accurately reflected and properly formatted
* Report which files were updated and what changed
