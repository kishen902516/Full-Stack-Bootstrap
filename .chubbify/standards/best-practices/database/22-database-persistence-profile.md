## 21) Database & Persistence Profile

**Boundary & Independence**
- **MUST** keep **domain** free of ORM/driver types.
- **MUST** define **ports** (repository/service interfaces) in domain/app; implement in infrastructure.

**Migrations & Schema Discipline**
- **MUST** use versioned migrations (Flyway/Liquibase/EF).
- **MUST** follow **expand → migrate → contract**; keep app backward-compatible during rollout.
- **MUST** script everything; no manual prod changes.
- **SHOULD** include online migration patterns (backfills, dual-write reads, shadow tables).

**Modeling & Performance**
- **SHOULD** start normalized; selectively denormalize with clear ownership.
- **MUST** define constraints/indexes; review query plans for hot paths.
- **SHOULD** partition/archive large tables; define TTL/retention for events/logs.

**Transactions & Consistency**
- **MUST** define transaction boundaries at use-case level; avoid long transactions.
- **SHOULD** use **outbox + CDC** for integration events; avoid in-transaction network hops.

**Security & Data Governance**
- **MUST** classify data; encrypt at rest/in transit; store secrets in vault.
- **SHOULD** apply row-level security/column masking for sensitive fields.
- **MUST** define RPO/RTO, backup & restore tests.

**Testing**
- **MUST** integration-test repositories with **Testcontainers/local DB**; seed fixtures.
- **SHOULD** include CDC contract tests for downstream consumers.

**Observability**
- **MUST** monitor slow queries, connection pools, deadlocks; expose metrics (qps, latency, errors).
- **SHOULD** log structured queries for forensics (PII-safe).

**Anti-patterns**
- ORM entities in domain; breaking schema changes; hand-edited prod data; no indexes; cross-service joins at runtime.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
