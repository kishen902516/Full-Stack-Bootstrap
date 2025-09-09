# Root Manifest

This manifest contains the file structure and content for the root components.

## claude.md

# Claude Code — Working Agreement

- Use **MCP tools only** from `mcp/config.json`. If a command is missing, propose it; do not run shell commands directly.
- **TDD-first**: write failing tests, then the minimal code to pass, then refactor.
- **API-first**: keep `api/openapi.yaml` the source of truth. Update spec + codegen and contract tests together.
- **Clean Architecture**: respect layer boundaries; your code must pass architecture tests.
- **Security**: never emit real secrets; use placeholders (e.g., `<YOUR_API_KEY>`).

## Sequential Thinking (Plan→Do)
For non-trivial changes (>100 lines or cross-layer):
1) `/plan create \"<title>\" --scope api,fe --goal \"...\"`
2) Update steps & tests in the plan file and reference `Plan-ID: <id>` in commits/PR.
3) Execute steps sequentially; keep commits small with tests first.

## MCP Servers in this repo
- github — PRs, issues, comments (env: GITHUB_TOKEN)
- atlassian — Jira/Confluence (env: ATLASSIAN_*)
- playwright — E2E orchestration (run/report/trace)
- context7 — project knowledge (search/read/refresh)

## Slash-commands (via MCP)
- `/arch check` — run architecture tests (Angular + .NET)
- `/api contract verify` — spectral lint + openapi-diff
- `/test pyramid` — show ratios/coverage and next-test suggestions
- `/security scan` — secrets + SAST scan
- `/git feature <name>` — create a GitFlow feature branch
- `/plan create <title>` — generate a Change Plan


---

## .github/PULL_REQUEST_TEMPLATE.md

```markdown
### Why
<link to story / plan>

### What changed (small + test-backed)
- [ ] Small PR (≤400 lines)
- [ ] Tests added/updated first (TDD)
- [ ] Architecture tests pass locally (`/arch check`)
- [ ] OpenAPI updated + contract tests green
- [ ] Security scan clean (gitleaks/semgrep)

### Notes
<risk, rollout>

```

---

## .gitattributes

```gitignore
* text=auto eol=lf

```

---

## .gitignore

```gitignore
node_modules/
.env
.env.*
secrets.*
*.key
*.pem
*.pfx
*.pub
*.kube
*.tfstate
.DS_Store
.context7/
app-frontend/playwright-report/
app-frontend/test-results/
app-api/**/bin/
app-api/**/obj/

```

---

## CODEOWNERS

```plaintext
/api/*           @devex-team
/tools/security/* @devex-team

```

---

## standards/git.md

- Conventional Commits required; small commits (≤200 lines/≤10 files).
- GitFlow: long-lived `main` + `develop`; feature/release/hotfix branches.
- PR ≤ 400 lines, squash merges to `develop`.


---

## standards/test-strategy.md

- Test pyramid: Unit 70–85%, Integration/Contract 10–25%, E2E 5–10%.
- Coverage minimums: API unit 80%; Angular unit 70%.
- All PRs must include tests for code changes (TDD enforced).


---

## standards/security.md

- No hardcoded secrets; scans via gitleaks + semgrep block PRs.
- Approved placeholders only (see `env/.env.example`).
- Secrets from env/secret store only; never committed.


---

## plans/README.md

For any change >100 added lines or cross-layer edits, create/attach a plan:
- Create: `/plan create "<title>" --scope api,fe --goal "..."`
- Reference `Plan-ID: <id>` in commit message or PR description.
- Outline steps and tests before coding.


---

## scripts/install-hooks.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
git config core.hooksPath tools/hooks
chmod +x tools/hooks/* || true
chmod +x tools/git/flow.sh || true
chmod +x tools/mcp/*.js || true
chmod +x tools/metrics/check-pyramid.js || true
echo "✅ Hooks installed."

```

---

## env/.env.example

```plaintext
GITHUB_TOKEN=<YOUR_GITHUB_TOKEN>
ATLASSIAN_HOST=https://your-domain.atlassian.net
ATLASSIAN_EMAIL=user@example.com
ATLASSIAN_API_TOKEN=<YOUR_ATLASSIAN_API_TOKEN>

```

