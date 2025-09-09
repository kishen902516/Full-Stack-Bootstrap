## 4) API & Contract Discipline

- **Contract-first**: OpenAPI/AsyncAPI is the source of truth.
- **Backward compatibility:** Only additive changes on stable endpoints. Version when breaking.
- **Consumer-driven contracts** SHOULD validate producers and clients.
- **Generated clients/servers** MUST be pinned and re-generated as a CI step.

✅ Do: document error models and pagination.  
❌ Don’t: break fields or reuse semantics for different meanings.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
