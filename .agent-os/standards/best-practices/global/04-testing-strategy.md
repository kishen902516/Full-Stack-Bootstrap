## 3) Testing Strategy

- **Testing pyramid MUST be followed.**
  - Unit (fast, deterministic) → contract/component → integration (Testcontainers, in-memory fakes) → a few targeted E2E.
- **Coverage:** Aim ≥70% where meaningful; **cover critical paths** and regressions first.
- **Mutation tests** MAY be used for core logic.
- **Flaky tests MUST be quarantined** and fixed before merging related work.

✅ Do: seed data builders, deterministic clocks, fixed random seeds.  
❌ Don’t: test through real shared externals by default.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
