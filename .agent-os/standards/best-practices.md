# Development Best Practices

## Context

Comprehensive development guidelines for Full-Stack Bootstrap projects, organized by architectural layer.

## Tech Stack

- **Frontend**: Angular with TypeScript
- **Backend**: .NET 8
- **Database**: PostgreSQL/MongoDB
- **DevOps**: Docker, CI/CD pipelines

## Core Principles

### Keep It Simple
- Implement code in the fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions

## Best Practices by Layer

### 🌍 Global Best Practices
*Practices that apply across all architectural layers*

- **[Overview](./best-practices/global/00-overview.md)** - Project standards overview
- **[Conventions](./best-practices/global/01-conventions.md)** - Naming and code conventions
- **[Architecture & Modularity](./best-practices/global/02-architecture-modularity.md)** - Clean architecture principles
- **[Code Style & Formatting](./best-practices/global/03-code-style-formatting.md)** - Code formatting standards
- **[Testing Strategy](./best-practices/global/04-testing-strategy.md)** - Testing approach and pyramid
- **[Error Handling & Resilience](./best-practices/global/07-error-handling-resilience.md)** - Error handling patterns
- **[Observability](./best-practices/global/08-observability.md)** - Logging and monitoring
- **[Security Baseline](./best-practices/global/09-security-baseline.md)** - Security best practices
- **[Dependency Hygiene](./best-practices/global/10-dependency-hygiene.md)** - Managing dependencies
- **[CI/CD Quality Gate](./best-practices/global/11-ci-cd-quality-gate.md)** - Continuous integration standards
- **[Git & PR Process](./best-practices/global/12-git-pr-process.md)** - Version control workflow
- **[Feature Flags & Rollouts](./best-practices/global/13-feature-flags-rollouts.md)** - Feature management
- **[Documentation & ADRs](./best-practices/global/14-documentation-adrs.md)** - Documentation standards
- **[Ownership & Repo Strategy](./best-practices/global/15-ownership-repo-strategy.md)** - Code ownership
- **[Releases & Versioning](./best-practices/global/16-releases-versioning.md)** - Release management
- **[Local Dev Experience](./best-practices/global/17-local-dev-experience.md)** - Developer environment
- **[Anti-patterns](./best-practices/global/18-anti-patterns-never-do-this.md)** - What to avoid
- **[Definition of Done](./best-practices/global/19-definition-of-done-per-pr-spec.md)** - PR completion criteria
- **[Agent Execution Rules](./best-practices/global/20-agent-execution-rules-read-carefully.md)** - AI agent guidelines
- **[Import Rule Snippets](./best-practices/global/23-import-rule-snippets-fe-db-add-ons.md)** - Module import patterns

### 🎨 Frontend Best Practices
*Angular and TypeScript specific practices*

- **[Frontend Profile](./best-practices/frontend/21-front-end-profile-web-mobile.md)** - Comprehensive frontend guidelines
  - Architecture & modularity patterns for Angular
  - State management with RxJS/NgRx
  - Component design patterns (smart vs presentational)
  - Angular-specific performance optimizations
  - Accessibility (a11y) requirements
  - TypeScript strict mode configuration
  - Angular testing with Jasmine/Karma
  - Bundle optimization strategies

### 🚀 Backend Best Practices  
*Node.js/Express and API specific practices*

- **[API Contract Discipline](./best-practices/backend/05-api-contract-discipline.md)** - API design and contracts
  - RESTful API design principles
  - OpenAPI/Swagger documentation
  - Request/response validation with TypeScript
  - Express middleware patterns
  - Authentication & authorization
  - Rate limiting and security headers
  - API versioning strategies
  - Error response standardization

### 💾 Database Best Practices
*PostgreSQL/MongoDB specific practices*

- **[Data Migrations](./best-practices/database/06-data-migrations.md)** - Database migration strategies
- **[Database & Persistence Profile](./best-practices/database/22-database-persistence-profile.md)** - Comprehensive database guidelines
  - Schema design principles
  - Query optimization for PostgreSQL
  - MongoDB document design patterns
  - Connection pooling configuration
  - Transaction management
  - Backup and recovery strategies
  - Data security and encryption
  - Performance monitoring


