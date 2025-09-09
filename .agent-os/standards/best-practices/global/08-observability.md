## 7) Observability

- **Structured logs (JSON)** with correlation IDs.  
- **Metrics:** RED (Requests/Errors/Duration) for services; USE for infra.  
- **Traces:** OpenTelemetry everywhere.  
- **Health:** `/healthz` (liveness) and `/readyz` (readiness).  
- Dashboards + alerts MUST exist for every service endpoint added/changed.

✅ Do: one log/metrics sink per env; documented runbooks.  
❌ Don’t: print stack traces to users or rely on grep-only logging.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
