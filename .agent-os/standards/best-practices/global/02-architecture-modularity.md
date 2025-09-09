## 1) Architecture & Modularity

### Clean Architecture (Prescriptive Profile)

> Adopt a domain-centered architecture (a.k.a. *Clean Architecture* / *Hexagonal* / *Onion*). The **dependency rule** applies: source code dependencies MUST point inward toward the domain.

```
[ Frameworks & Drivers ]  UI • DB • Queue • HTTP • CLI
          ↑        |
      [ Interface Adapters ]  Controllers • Presenters • Gateways • Mappers
                 ↑
         [ Application / Use Cases ]  Orchestrate business flows (no I/O)
                 ↑
               [ Domain ]  Entities • Value Objects • Domain Services • Events
```

#### Core Rules
- **Domain MUST be framework-agnostic.**
  - No framework annotations or base classes in domain (e.g., no JPA/EntityFramework attributes).
  - Domain exposes **interfaces (ports)** for persistence, messaging, and external services.
- **Use cases MUST orchestrate and remain side-effect free** (besides calling ports).
  - Input/Output models are simple DTOs (no web/ORM types).
  - Transaction boundaries SHOULD wrap a use case.
- **Adapters implement ports** and perform translation/mapping to external tech.
  - Controllers/Handlers map transport → DTOs; Presenters map DTOs → views.
  - Repositories live in infrastructure and implement domain-defined interfaces.
- **The dependency graph MUST follow:** `frameworks → adapters → application → domain`.
  - Domain depends on nothing; application depends only on domain; adapters/infra depend inward.
- **No business logic in controllers or repositories.** Keep logic in domain/services/use cases.
- **Boundary models SHOULD be stable** and versioned; never leak ORM/HTTP types across layers.

#### Packaging & Naming (example)
- `domain/` — entities, value-objects, domain events, domain services, **ports** (e.g., `UserRepository`).
- `application/` — use cases (e.g., `CreateUser`), commands/queries, input/output DTOs, **in/out ports**.
- `adapters/` — web controllers, presenters, mappers, gateway adapters.
- `infrastructure/` — db repository impls, messaging impls, HTTP clients, config.

> Alternative names: `core`(domain) · `usecase`(application) · `web`/`cli`/`worker`(adapters) · `infra`.

#### Enforcement (examples)
- **ArchUnit (Java)**: forbid `..domain..` from depending on `..adapter..|..infrastructure..|..framework..`; allow only inward deps.
- **NetArchTest (.NET)**: assert namespaces `*.Domain` have no references to `*.Infrastructure` or `*.Web`.
- **dependency-cruiser / Nx (TS)**: tag packages and block outward violations via dep rules.
- **CI MUST fail** on architectural violations.

#### Data & Persistence
- **Repository interfaces live in domain/application**; implementations live in infrastructure.
- Mapping via mappers; avoid leaking persistence models into domain.
- Use **outbox pattern** for integration events; domain events stay in-process.

#### Testing Guidance
- **Domain:** pure unit tests only (no mocks for framework types).
- **Application:** unit tests with mocked ports; verify flow and rules.
- **Adapters/Infra:** contract + integration tests (e.g., Testcontainers); CDC for external APIs.
- **System/E2E:** thin happy-path coverage; keep fast.

#### PR Checklist (Clean Architecture)
- [ ] Domain has **no framework or adapter types**.
- [ ] Use case encapsulates the flow; controller/handler is thin.
- [ ] Ports/interfaces defined inward; adapters implement outward.
- [ ] DTOs at boundaries; no ORM/transport types crossing layers.
- [ ] Arch rules pass; tests exist per layer; transactions at use case boundary.


- **Boundaries MUST be explicit.**
  - Define layers/domains (hexagonal / ports-and-adapters).
  - Public interfaces only; **no** cross-module internals.
  - Enforce with arch tests (e.g., ArchUnit / NetArchTest / dependency-cruiser).
- **Coupling SHOULD be low; cohesion SHOULD be high.**
  - Prefer composition over inheritance.
  - Keep feature code and tests close together.
- **Data flow MUST be clear.**
  - Commands vs Queries, side-effects isolated.
  - Idempotent writes where possible.

✅ Do: isolate adapters (web, db, queues).  
❌ Don’t: reach across modules or call private internals.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
