## 5) Data & Migrations

- **Versioned migrations MUST be used** (Flyway/Liquibase/EF).
- Zero-downtime pattern: **expand → migrate → contract**.
- **Rollback plan MUST exist** for each migration.
- Data retention, PII handling, and soft-deletes SHOULD follow `tech-stack.md` policies.

✅ Do: shape changes compatible with old and new code during rollout.  
❌ Don’t: hot-edit schemas or perform manual prod changes without scripts.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
