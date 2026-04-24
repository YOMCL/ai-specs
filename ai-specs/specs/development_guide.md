# YOM Development Guide

This guide covers the workspace layout, local environment setup, development conventions, and deployment process for the YOM platform.

---

## Workspace Structure

The YOM workspace lives at `~/Documents/yom/workspace/`. All services are **git submodules** of the workspace repo.

```
~/Documents/yom/workspace/
├── frontend/               # Next.js applications
├── backend/
│   ├── nestjs/             # NestJS microservices
│   ├── moleculer/          # Moleculer microservices
│   └── python/             # Python services (peripheral)
├── infra/
│   ├── local-architecture/ # Docker Compose local environment
│   └── terraform/          # AWS infrastructure (Terraform modules)
├── shared/                 # Shared libraries and ai-specs
└── lambdas/                # AWS Lambda functions
```

Update all submodules to their latest remote state:

```bash
git submodule update --remote --merge
```

---

## Local Development Environment ("Futurama")

The local environment is called **Futurama** and runs via Docker Compose in `infra/local-architecture/`.

### Starting Services

Use the interactive service selector:

```bash
./start.sh
```

The script presents a selector — choose services by name. Infrastructure services (DB, message bus, etc.) are always-on once started.

### Always-On Infrastructure

| Service | Port |
|---------|------|
| MongoDB | 27017 |
| PostgreSQL | 5433 |
| Redis | 6379 |
| NATS | 4222 |
| LocalStack (AWS) | 4566 |
| PGAdmin | 5050 |

### Service Ports

| Service | Port |
|---------|------|
| yom-api | 3000 |
| admin | 3002 |
| b2b | 3006 |
| customer | 3016 |
| fintech | 3017 |
| orders | 3018 |
| yom-gateway | 3100 |

---

## Environment Variables

Each service has a `.env.example` file. Copy it to `.env` and fill in the required values:

```bash
cp .env.example .env
# then edit .env with real values
```

The `TOKEN_PACKAGE` environment variable is required to install `@yomcl/*` packages from GitHub Packages. Set it in your shell profile or `.env`:

```bash
export TOKEN_PACKAGE=ghp_your_token_here
```

---

## Private Packages (`@yomcl/*`)

YOM's shared packages live in **GitHub Packages** under the `@yomcl` scope. To install them, each service needs an `.npmrc` file:

```
@yomcl:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${TOKEN_PACKAGE}
```

This file is typically already present in each service repo. Make sure `TOKEN_PACKAGE` is set in your environment before running `npm install`.

---

## Running a Service Locally

### NestJS services

```bash
# Install dependencies (requires TOKEN_PACKAGE set)
npm install

# Start in watch mode
npm run start:dev
```

### Frontend (Next.js)

```bash
npm install
npm run dev
```

### Python — hermes (peripheral)

Refer to the `hermes` service README for setup. Not part of the core stack.

---

## Testing

```bash
# Run all tests
npm test

# Run with coverage report
npm run test:cov

# Run in watch mode
npm run test:watch
```

---

## Branch and Commit Conventions

### Branches

| Branch | Purpose |
|--------|---------|
| `production` | Default working branch — PRs merge here |
| `staging` | Pre-production validation |

**Never push directly to `production` or `staging`.** Always open a Pull Request. CI/CD pipelines are triggered on PR and merge events.

### Commit Style

Use **Conventional Commits** in English:

| Prefix | Use for |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation only |
| `test:` | Adding or fixing tests |
| `refactor:` | Code restructuring without behavior change |
| `chore:` | Maintenance, tooling, dependency updates |

Examples:
```
feat(orders): add bulk cancellation endpoint
fix(fintech): handle missing customerId in payment document creation
refactor(customer): extract banner repository from service layer
```

---

## CI/CD and Deployment

Deployments are managed via **GitHub Actions**:

- **PR to `staging` or `production`**: runs the Terraform plan, shows infrastructure diff
- **Merge to `staging` or `production`**: runs Terraform apply, deploys the service

Infrastructure lives in `infra/terraform/`. Application services are deployed as containers or Lambda functions depending on the service type.

Do not apply infrastructure changes manually outside of the CI/CD pipeline unless in a documented incident response scenario.
