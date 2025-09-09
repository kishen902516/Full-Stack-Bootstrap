# Full-Stack-Bootstrap

A full-stack project generator for BMAD CCA (Clean Code Architecture) applications following enterprise patterns.

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- .NET SDK (v6.0 or higher)
- Git
- Bash shell (Git Bash on Windows)

### Quick Start

1. **Bootstrap a new project**
   ```bash
   ./bootstrap.sh -p <your-project-name>
   ```
   Replace `<your-project-name>` with your desired project name.

2. **Navigate to your new project**
   ```bash
   cd <your-project-name>
   ```

3. **Install dependencies**
   
   Frontend dependencies:
   ```bash
   cd app-frontend && npm install
   ```
   
   Backend dependencies:
   ```bash
   dotnet restore ./app-api/AppApi.sln
   ```

### Project Structure

After bootstrapping, your project will have:

- **app-frontend/**: TypeScript/Angular-ready frontend application
- **app-api/**: .NET Clean Architecture backend
  - `AppApi.Web`: API controllers and endpoints
  - `AppApi.Application`: Business logic and use cases
  - `AppApi.Domain`: Domain entities and interfaces
  - `AppApi.Infrastructure`: Data access and external services
- **tools/**: Development tools and scripts
- **api/**: OpenAPI specifications

### Development Workflow

#### Running Tests
```bash
# Frontend unit tests
cd app-frontend && npm test

# Backend unit tests
dotnet test ./app-api/tests/UnitTests

# E2E tests
cd app-frontend && npm run e2e
```

#### Quality Checks
```bash
# Contract verification
cd app-frontend && npm run api:lint

# Architecture tests
dotnet test ./app-api/tests/ArchitectureTests
```

#### Git Workflow
```bash
# Create feature branch
bash tools/git/flow.sh feature <feature-name>

# Create release branch
bash tools/git/flow.sh release <version>
```

### Key Features

- **Clean Architecture**: Enforced layer separation with architecture tests
- **API-First Design**: OpenAPI specification as single source of truth
- **TDD Support**: Watch mode for both frontend and backend tests
- **Security Built-in**: Automated secrets detection and security scanning
- **Development Guardrails**: Pre-commit hooks, conventional commits, test coverage requirements
- **MCP Integration**: Claude Code integration for AI-assisted development

### Next Steps

1. Review the generated project structure
2. Customize the OpenAPI specification in `api/openapi.yaml`
3. Start developing with TDD using watch mode
4. Use conventional commits for version management

For more detailed information, see `CLAUDE.md` after bootstrapping your project.