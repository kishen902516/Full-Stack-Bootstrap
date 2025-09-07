## 8) Security Baseline

- SAST, secret scanning, dependency + SBOM + container scans in CI.
- Least-privilege IAM; HTTPS everywhere; secure headers/CORS.
- Secrets from vaults, not env files committed to VCS.
- Fix SLAs by severity (e.g., Critical within 24–72h).

✅ Do: rotate keys; audit access.  
❌ Don’t: put tokens in code, logs, or issue trackers.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
