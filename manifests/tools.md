# Tools Manifest

This manifest contains the file structure and content for the tools components.

## tools/hooks/commit-msg

```plaintext
#!/usr/bin/env bash
set -euo pipefail
MSG="$(head -n1 \"$1\")"
RE='^(build|ci|chore|docs|feat|fix|perf|refactor|revert|test)(\([a-z-]+\))?!?: .{1,72}$'
echo "$MSG" | grep -Eq "$RE" || { echo "❌ Conventional Commit required (≤72 chars)."; echo "e.g. feat(api): add GET /orders"; exit 1; }

```

---

## tools/hooks/pre-commit

```plaintext
#!/usr/bin/env bash
set -euo pipefail
ADDED=$(git diff --cached --numstat | awk '{a+=$1}END{print a+0}')
FILES=$(git diff --cached --name-only --diff-filter=ACM | wc -l | xargs)
[[ "${BREAK_GLASS:-0}" == "1" ]] || { (( ADDED<=200 && FILES<=10 )) || { echo "❌ Small commits only (≤200 lines, ≤10 files)."; exit 1; }; }
CHANGED=$(git diff --cached --name-only --diff-filter=ACM)
echo "$CHANGED" | grep -E '\\.(cs|ts|tsx)$' >/dev/null && echo "$CHANGED" | grep -E '(tests?|__tests__|\\.spec\\.ts|Tests\\.cs)' >/dev/null || { echo "❌ Add tests with your code (TDD)."; exit 1; }
# Large change requires a plan
if (( ADDED > ${PLAN_THRESHOLD:-100} )); then
  PLAN_ID=$(git log -1 --pretty=%B | sed -n 's/.*Plan-ID:\s*\([0-9T-]\+\).*/\1/p')
  [[ -n "$PLAN_ID" ]] && node tools/mcp/plan-check.js "$PLAN_ID" || { echo "❌ Large change requires a plan. Use /plan create and add 'Plan-ID: <id>' to commit/PR."; exit 1; }
fi
# Secrets quick regex
if git diff --cached -U0 | grep -E '(AKIA|AIza|secret|api[_-]?key|password\s*:|password\s*=)'; then
  echo "❌ Potential secret in diff. Remove or externalize via env/secret store."; exit 1
fi
# Gitleaks staged
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --redact --config tools/security/gitleaks.toml || { echo "❌ gitleaks found potential secrets."; exit 1; }
else
  echo "ℹ️ gitleaks not found locally; CI will run full secrets scan."
fi
echo "✅ Pre-commit checks passed."

```

---

## tools/hooks/pre-push

```plaintext
#!/usr/bin/env bash
set -euo pipefail
( cd app-frontend && npm test --silent )
dotnet test ./app-api/tests/UnitTests /p:CollectCoverage=true /p:Threshold=80
dotnet test ./app-api/tests/ArchitectureTests
( cd app-frontend && npm run api:lint && npm run api:diff )

```

---

## tools/ci/workflows/ci.yml

```yaml
name: ci
on: [push, pull_request]
jobs:
  unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          [ -f package-lock.json ] && npm ci || npm install
          npm test -- --ci --coverage
        working-directory: app-frontend
      - run: dotnet restore ./app-api/AppApi.sln && dotnet test ./app-api/tests/UnitTests /p:CollectCoverage=true /p:Threshold=80
  arch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          [ -f package-lock.json ] && npm ci || npm install
          npm run arch:check
        working-directory: app-frontend
      - run: dotnet test ./app-api/tests/ArchitectureTests
  contract_integration:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_PASSWORD: postgres, POSTGRES_DB: appdb }
        ports: [ "5432:5432" ]
    steps:
      - uses: actions/checkout@v4
      - run: |
          [ -f package-lock.json ] && npm ci || npm install
          npm run api:lint
          npm run api:diff
        working-directory: app-frontend
      - run: dotnet test ./app-api/tests/IntegrationTests
  quality_gates:
    runs-on: ubuntu-latest
    needs: [unit, arch, contract_integration]
    steps:
      - uses: actions/checkout@v4
      - run: node tools/metrics/check-pyramid.js

```

---

## tools/ci/workflows/security.yml

```yaml
name: security
on: [pull_request]
jobs:
  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: gitleaks/gitleaks-action@v2
        with: { config-path: tools/security/gitleaks.toml, redact: true }
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: returntocorp/semgrep-action@v1
        with: { config: tools/security/semgrep.yml }

```

---

## tools/metrics/check-pyramid.js

```javascript
#!/usr/bin/env node
const { execSync } = require('node:child_process');
function count(pattern){ try{ return parseInt(execSync(`git ls-files | grep -E '${pattern}' | wc -l`).toString().trim()||'0',10);}catch{ return 0;}}
const unit=count('(tests\\/UnitTests|__tests__|\\.spec\\.ts$)');
const integration=count('tests\\/IntegrationTests');
const e2e=count('\\/e2e\\/');
const total=unit+integration+e2e||1; const pct=n=>Math.round((n/total)*100);
if(pct(unit)<70||pct(unit)>85){ console.error(`❌ Unit tests should be 70–85% (now ${pct(unit)}%).`); process.exit(1);} 
if(pct(integration)<10||pct(integration)>25){ console.error(`❌ Integration/Contract 10–25% (now ${pct(integration)}%).`); process.exit(1);} 
if(pct(e2e)<5||pct(e2e)>10){ console.error(`❌ E2E 5–10% (now ${pct(e2e)}%).`); process.exit(1);} 
console.log('✅ Test pyramid looks healthy.');

```

---

## tools/security/gitleaks.toml

```toml
title = "BMAD CCA Secret Rules"
[allowlist]
files = ["env/.env.example", "tools/security/secret-allowlist.txt"]
regexTarget = "match"
regexes = ['<YOUR_[A-Z0-9_]+>', 'DUMMY_(KEY|TOKEN)']
[[rules]]
id = "generic-api-key"
regex = '''(?i)(api[_-]?key|token|secret|client[_-]?secret)\s*[:=]\s*['"][A-Za-z0-9_\-]{16,}['"]'''
[[rules]]
id = "password-in-code"
regex = '''(?i)password\s*[:=]\s*['"][^'"]+['"]'''
[[rules]]
id = "connection-string-with-creds"
regex='''(?i)(User\s*ID|Uid|User Id|Username)=[^;]+;?\s*(Password|Pwd)=[^;]+;'''
[[rules]]
id = "aws-access-key"
regex = '''AKIA[0-9A-Z]{16}'''
[[rules]]
id = "credential-in-url"
regex = '''https?:\/\/[^\/\s:@]+:[^\/\s:@]+@'''
[[rules]]
id = "jwt-hardcoded"
regex = '''eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'''

```

---

## tools/security/semgrep.yml

```yaml
rules:
  - id: dotnet-hardcoded-secrets
    languages: [csharp]
    severity: ERROR
    message: Hardcoded secret/conn string detected. Use env + Secret Manager.
    patterns:
      - pattern-either:
          - pattern: string $S = "...Password=...";
          - pattern: new SqlConnection("...Password=...");
          - pattern: string $S = "...ApiKey=...";
  - id: angular-no-secrets
    languages: [typescript]
    severity: ERROR
    message: Do not embed secrets in frontend code.
    patterns:
      - pattern-either:
          - pattern: const $X = "sk_live" ...
          - pattern: const $X = /AIza[0-9A-Za-z\-_]{35}/
          - pattern: $X = "Bearer " + "..."
  - id: no-basic-auth-urls
    languages: [csharp, typescript]
    severity: ERROR
    message: Credentials in URL are forbidden.
    pattern: "http://$USER:$PASS@$HOST"

```

---

## tools/security/secret-allowlist.txt

```plaintext
<YOUR_API_KEY>
DUMMY_TOKEN

```

---

## tools/git/flow.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
cmd=${1:-help}; shift || true
case "$cmd" in
  init) git checkout -B develop && git branch -M main main ;;
  feature) git checkout -b "feature/$1" develop ;;
  release) git checkout -b "release/$1" develop ;;
  finish-release)
    ver="$1"; git checkout main && git merge --no-ff "release/$ver" -m "chore(release): $ver" && git tag "v$ver"
    git checkout develop && git merge --no-ff "release/$ver" && git branch -d "release/$ver" ;;
  hotfix) git checkout -b "hotfix/$1" main ;;
  finish-hotfix)
    ver="$1"; git checkout main && git merge --no-ff "hotfix/$ver" -m "fix!: hotfix $ver" && git tag "v$ver"
    git checkout develop && git merge --no-ff "hotfix/$ver" && git branch -d "hotfix/$ver" ;;
  *) echo "Usage: flow.sh {init|feature <name>|release <x.y.z>|finish-release <x.y.z>|hotfix <x.y.z>|finish-hotfix <x.y.z>}"; exit 1;;
esac

```

