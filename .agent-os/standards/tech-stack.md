# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- App Framework: ASP.NET Core
- Language: .NET 9
- Primary Database: PostgreSQL 17+
- ORM: EF Core
- LightWeight ORM : Dapper
- JavaScript Framework: Angular latest stable
- Build Tool: yarn
- Import Strategy: Node.js modules
- Package Manager: npm
- Node Version: 22 LTS
- UI Components: Material Design Latest
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Lucide React components
- Application Hosting: Render
- Hosting Region: Primary region based on user base
- Database Hosting: Digital Ocean Managed PostgreSQL
- Database Backups: Daily automated
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: staging branch
