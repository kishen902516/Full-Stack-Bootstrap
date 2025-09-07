## 10) CI/CD Quality Gate

Every PR MUST pass:

1. **Static checks:** formatter, linter, type-check.  
2. **Tests:** unit → integration → (selective) E2E; no flakiness.  
3. **Security:** secret scan, SAST, dep/SBOM, container scan.  
4. **Policy:** license check, size/perf/regression thresholds, coverage floors.  
5. **Artifacts:** versioned build + provenance/attestation (e.g., SLSA).

Block merge on any failure.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
