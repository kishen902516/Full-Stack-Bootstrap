## 6) Error Handling & Resilience

- Centralized exception mapping (consistent HTTP/problem details).
- Timeouts, bounded retries with jitter, circuit breakers where applicable.
- Use idempotency keys for mutating requests.
- Never swallow errors; log with correlation/trace IDs.

✅ Do: fail fast with actionable messages.  
❌ Don’t: retry blindly or log sensitive data.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
