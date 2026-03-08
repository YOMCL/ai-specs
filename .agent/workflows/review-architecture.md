# Review Architecture

Analyze code for compliance with clean/hexagonal architecture principles.

## Steps

* Adopt the role defined in `ai-specs/.agents/software-architect.md`
* Read all files in the target directory or module
* Verify layer separation: domain must not import from infrastructure or presentation
* Check that repositories are defined as interfaces (ports) in the domain layer
* Verify infrastructure adapters implement domain interfaces, not the other way around
* Ensure controllers are thin — no business logic, only HTTP handling and delegation to services
* Check that domain entities encapsulate business rules and maintain invariants
* Verify dependency injection follows the Dependency Inversion Principle
* Identify any circular dependencies between modules
* Check for direct framework imports in the domain layer (violations)
* Produce a report with: violations found, severity (critical/warning/suggestion), and specific fixes
* Propose an Architecture Decision Record (ADR) if a significant architectural decision is needed
