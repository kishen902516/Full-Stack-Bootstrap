# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Bootstrap a new project
```bash
./bootstrap.sh -p <project-name>
```

### Install dependencies (inside bootstrapped project)
```bash
# Frontend dependencies
cd app-frontend && npm install

# .NET dependencies
dotnet restore ./app-api/AppApi.sln
```

### Run tests
```bash
# Frontend unit tests (with coverage)
cd app-frontend && npm test

# Frontend unit tests (watch mode for TDD)
cd app-frontend && npm run test:watch

# .NET unit tests with coverage (80% threshold)
dotnet test ./app-api/tests/UnitTests /p:CollectCoverage=true /p:Threshold=80

# .NET unit tests (watch mode for TDD)
dotnet watch test ./app-api/tests/UnitTests

# Architecture tests
cd app-frontend && npm run arch:check
dotnet test ./app-api/tests/ArchitectureTests

# Integration tests
dotnet test ./app-api/tests/IntegrationTests

# E2E tests
cd app-frontend && npm run e2e
cd app-frontend && npm run e2e:report
```

### Quality checks
```bash
# Contract verification
cd app-frontend && npm run api:lint && npm run api:diff

# Test pyramid check
node tools/metrics/check-pyramid.js

# Security scans
gitleaks detect --no-git --redact --config tools/security/gitleaks.toml
semgrep --config tools/security/semgrep.yml
```

### Git workflow
```bash
# Create feature branch
bash tools/git/flow.sh feature <feature-name>

# Create release branch
bash tools/git/flow.sh release <version>

# Create change plan for large changes (>100 lines)
node tools/mcp/plan-create.js "<plan-title>"
```

## Architecture

This is a full-stack bootstrap project generator for BMAD CCA (Clean Code Architecture) applications following enterprise patterns:

### Backend (.NET)
- **Clean Architecture layers**:
  - `AppApi.Web`: API layer (controllers, endpoints)
  - `AppApi.Application`: Business logic and use cases
  - `AppApi.Domain`: Domain entities and interfaces
  - `AppApi.Infrastructure`: Data access and external services
- **Architecture enforcement**: NetArchTest validates layer dependencies
- **API-first design**: OpenAPI spec at `api/openapi.yaml` is source of truth

### Frontend (TypeScript/Angular-ready)
- **Module boundaries**: Enforced by dependency-cruiser
- **Feature isolation**: Features cannot import from each other directly
- **Public API pattern**: Components must expose through `public-api.ts`
- **Contract testing**: OpenAPI validation with Spectral

### Development Guardrails
- **TDD enforcement**: Pre-commit hooks require tests with code changes
- **Small commits**: ≤200 lines, ≤10 files per commit
- **Conventional commits**: Required format with semantic versioning
- **Test pyramid**: Unit 70-85%, Integration 10-25%, E2E 5-10%
- **Security scanning**: Automated secrets detection blocks commits/PRs
- **Change plans**: Required for changes >100 lines (tracked via Plan-ID)

### MCP Integration
The project includes MCP (Model Control Protocol) servers and tools for Claude Code integration:
- GitHub/Atlassian servers for issue/PR management
- Playwright server for E2E test orchestration
- Context7 for project knowledge indexing
- Custom slash commands via `mcp/config.json`