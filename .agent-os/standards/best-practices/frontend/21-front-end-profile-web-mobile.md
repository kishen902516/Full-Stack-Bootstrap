## 20) Front-End Profile (Web / Mobile)

**Architecture & Modularity**
- **MUST** keep **domain** and **application/use-case** logic framework-agnostic (no React/Angular/Vue types in domain).
- **MUST** keep **components thin**: container (state/wiring) vs presentational (pure UI). No business rules in components.
- **MUST** isolate **adapters**: API clients, routers, storage, analytics, i18n.
- **SHOULD** enforce import rules (dependency-cruiser/Nx tags) so `ui → application → domain` only, never outward.

**Contracts & Types**
- **MUST** use **contract-first** clients (OpenAPI/GraphQL codegen).
- **MUST** validate runtime inputs at edges (e.g., Zod/yup) even with TypeScript.

**State & Side-effects**
- **MUST** keep side-effects in services/hooks, not in domain.
- **SHOULD** prefer server cache libraries (React Query/Apollo) over bespoke global state.
- **SHOULD** make writes idempotent; handle retries/cancellation.

**Accessibility & UX Quality**
- **MUST** meet a11y baseline (labels, roles, focus order, color contrast, keyboard nav).
- **SHOULD** include i18n/l10n boundaries; no hard-coded strings.

**Performance & Delivery**
- **MUST** set budgets (bundle, LCP/INP/CLS).
- **SHOULD** code-split on routes, prefetch critical data, optimize images/fonts, cache headers.
- **MUST** track Web Vitals and error rates.

**Testing**
- **MUST** pyramid: unit (pure funcs) → component (RTL/Vitest/Jest) → a few E2E (Playwright).
- **SHOULD** mock network with MSW/GraphQL mocks; consumer-driven contract tests for API shapes.

**Observability**
- **MUST** capture UI errors (error boundaries + reporter) with correlation IDs.
- **SHOULD** ship RUM + OpenTelemetry web traces for key flows.

**CI/CD**
- **MUST** lint/format/type-check, run tests, measure bundle size/perf budgets, and block on regressions.
- **SHOULD** feature-flag risky UI; dark-launch behind flags.

**Anti-patterns**
- Business logic in components; tight coupling to router/DOM; ad-hoc fetches everywhere; global mutable state as default.

---

---
[⬅ Back to Master Index](./best-practices.index.md)
