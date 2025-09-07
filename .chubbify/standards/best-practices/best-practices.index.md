# Best Practices — Master Index

_Sharded for LLM-friendly parsing. Generated: 2025-09-07 07:11 (local time)._

## Sections

- [Overview](./00-overview.md)
- [Conventions](./01-conventions.md)
- [1) Architecture & Modularity](./02-architecture-modularity.md)
- [2) Code Style & Formatting](./03-code-style-formatting.md)
- [3) Testing Strategy](./04-testing-strategy.md)
- [4) API & Contract Discipline](./05-api-contract-discipline.md)
- [5) Data & Migrations](./06-data-migrations.md)
- [6) Error Handling & Resilience](./07-error-handling-resilience.md)
- [7) Observability](./08-observability.md)
- [8) Security Baseline](./09-security-baseline.md)
- [9) Dependency Hygiene](./10-dependency-hygiene.md)
- [10) CI/CD Quality Gate](./11-ci-cd-quality-gate.md)
- [11) Git & PR Process](./12-git-pr-process.md)
- [12) Feature Flags & Rollouts](./13-feature-flags-rollouts.md)
- [13) Documentation & ADRs](./14-documentation-adrs.md)
- [14) Ownership & Repo Strategy](./15-ownership-repo-strategy.md)
- [15) Releases & Versioning](./16-releases-versioning.md)
- [16) Local Dev Experience](./17-local-dev-experience.md)
- [17) Anti‑Patterns (Never do this)](./18-anti-patterns-never-do-this.md)
- [18) Definition of Done (per PR/spec)](./19-definition-of-done-per-pr-spec.md)
- [19) Agent Execution Rules (read carefully)](./20-agent-execution-rules-read-carefully.md)
- [20) Front-End Profile (Web / Mobile)](./21-front-end-profile-web-mobile.md)
- [21) Database & Persistence Profile](./22-database-persistence-profile.md)
- [22) Import-Rule Snippets (FE/DB add-ons)](./23-import-rule-snippets-fe-db-add-ons.md)

## Manifest

```json
{
  "generated_at": "2025-09-07 07:11",
  "source_file": "standards-best-practices.md",
  "sections": [
    {
      "title": "Overview",
      "slug": "overview",
      "file": "00-overview.md",
      "order_hint": 0
    },
    {
      "title": "Conventions",
      "slug": "conventions",
      "file": "01-conventions.md",
      "order_hint": 0.5
    },
    {
      "title": "1) Architecture & Modularity",
      "slug": "architecture-modularity",
      "file": "02-architecture-modularity.md",
      "order_hint": 1
    },
    {
      "title": "2) Code Style & Formatting",
      "slug": "code-style-formatting",
      "file": "03-code-style-formatting.md",
      "order_hint": 2
    },
    {
      "title": "3) Testing Strategy",
      "slug": "testing-strategy",
      "file": "04-testing-strategy.md",
      "order_hint": 3
    },
    {
      "title": "4) API & Contract Discipline",
      "slug": "api-contract-discipline",
      "file": "05-api-contract-discipline.md",
      "order_hint": 4
    },
    {
      "title": "5) Data & Migrations",
      "slug": "data-migrations",
      "file": "06-data-migrations.md",
      "order_hint": 5
    },
    {
      "title": "6) Error Handling & Resilience",
      "slug": "error-handling-resilience",
      "file": "07-error-handling-resilience.md",
      "order_hint": 6
    },
    {
      "title": "7) Observability",
      "slug": "observability",
      "file": "08-observability.md",
      "order_hint": 7
    },
    {
      "title": "8) Security Baseline",
      "slug": "security-baseline",
      "file": "09-security-baseline.md",
      "order_hint": 8
    },
    {
      "title": "9) Dependency Hygiene",
      "slug": "dependency-hygiene",
      "file": "10-dependency-hygiene.md",
      "order_hint": 9
    },
    {
      "title": "10) CI/CD Quality Gate",
      "slug": "ci-cd-quality-gate",
      "file": "11-ci-cd-quality-gate.md",
      "order_hint": 10
    },
    {
      "title": "11) Git & PR Process",
      "slug": "git-pr-process",
      "file": "12-git-pr-process.md",
      "order_hint": 11
    },
    {
      "title": "12) Feature Flags & Rollouts",
      "slug": "feature-flags-rollouts",
      "file": "13-feature-flags-rollouts.md",
      "order_hint": 12
    },
    {
      "title": "13) Documentation & ADRs",
      "slug": "documentation-adrs",
      "file": "14-documentation-adrs.md",
      "order_hint": 13
    },
    {
      "title": "14) Ownership & Repo Strategy",
      "slug": "ownership-repo-strategy",
      "file": "15-ownership-repo-strategy.md",
      "order_hint": 14
    },
    {
      "title": "15) Releases & Versioning",
      "slug": "releases-versioning",
      "file": "16-releases-versioning.md",
      "order_hint": 15
    },
    {
      "title": "16) Local Dev Experience",
      "slug": "local-dev-experience",
      "file": "17-local-dev-experience.md",
      "order_hint": 16
    },
    {
      "title": "17) Anti\u2011Patterns (Never do this)",
      "slug": "anti-patterns-never-do-this",
      "file": "18-anti-patterns-never-do-this.md",
      "order_hint": 17
    },
    {
      "title": "18) Definition of Done (per PR/spec)",
      "slug": "definition-of-done-per-pr-spec",
      "file": "19-definition-of-done-per-pr-spec.md",
      "order_hint": 18
    },
    {
      "title": "19) Agent Execution Rules (read carefully)",
      "slug": "agent-execution-rules-read-carefully",
      "file": "20-agent-execution-rules-read-carefully.md",
      "order_hint": 19
    },
    {
      "title": "20) Front-End Profile (Web / Mobile)",
      "slug": "front-end-profile-web-mobile",
      "file": "21-front-end-profile-web-mobile.md",
      "order_hint": 20
    },
    {
      "title": "21) Database & Persistence Profile",
      "slug": "database-persistence-profile",
      "file": "22-database-persistence-profile.md",
      "order_hint": 21
    },
    {
      "title": "22) Import-Rule Snippets (FE/DB add-ons)",
      "slug": "import-rule-snippets-fe-db-add-ons",
      "file": "23-import-rule-snippets-fe-db-add-ons.md",
      "order_hint": 22
    }
  ]
}
```