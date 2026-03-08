# Setup MkDocs

Set up or scaffold a MkDocs documentation site for the project.

## Steps

* Adopt the role defined in `ai-specs/.agents/mkdocs-specialist.md`
* Analyze the existing project structure to understand what documentation exists
* Install MkDocs and the Material theme: `pip install mkdocs mkdocs-material`
* Create `mkdocs.yml` at the project root with Material theme configuration, navigation structure, and plugins
* Create `docs/` directory with the following structure:
  - `docs/index.md` — Project overview and quick start
  - `docs/architecture/` — Architecture decisions and diagrams
  - `docs/api/` — API reference (generated from `ai-specs/specs/api-spec.yml` if available)
  - `docs/development/` — Development guide, setup, and standards
  - `docs/changelog/` — Version history
* Configure Mermaid diagrams plugin for architecture diagrams
* Configure the mkdocs-swagger-ui-tag plugin if an OpenAPI spec exists
* Set up GitHub Actions workflow to deploy docs to GitHub Pages on push to main
* Run `mkdocs serve` to verify the site renders correctly
* Document any project-specific customizations needed
