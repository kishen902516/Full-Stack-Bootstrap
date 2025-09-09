#!/usr/bin/env bash
# BMAD CCA Bootstrapper
# Usage:
#   ./bootstrap.sh -p my-app [--no-tests] [--install-playwright] [--remote <git-url>] [--no-gitflow] [-y]
set -euo pipefail
VERSION="2.0.0"

# defaults
MANIFEST_DIR="manifests"
PROJECT="bmad-cca-app"
RUN_TESTS=1
INSTALL_PLAYWRIGHT=0
INIT_GITFLOW=1
GIT_REMOTE=""
YES=0

usage() {
  cat <<EOF
BMAD CCA Bootstrap v$VERSION
Options:
  -p, --project  <dir>      Target project directory (default: bmad-cca-app)
  -d, --manifest-dir <dir>  Directory containing manifest files (default: manifests)
      --no-tests            Skip initial test/quality runs
      --install-playwright  Install Playwright browsers (local E2E)
      --remote <git-url>    Add git remote 'origin' after init
      --no-gitflow          Do not initialize GitFlow (main/develop)
  -y, --yes                 Do not prompt, assume yes
  -h, --help                Show this help

The bootstrap script loads all *.json files from the manifests/ directory
and merges them to create the project structure.
EOF
}

die() { echo "❌ $*" >&2; exit 1; }
say() { echo "▶ $*"; }
ok()  { echo "✅ $*"; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }

# -------- arg parsing --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--manifest-dir) MANIFEST_DIR="${2:-}"; shift 2;;
    -p|--project)  PROJECT="${2:-}"; shift 2;;
    --no-tests) RUN_TESTS=0; shift;;
    --install-playwright) INSTALL_PLAYWRIGHT=1; shift;;
    --remote) GIT_REMOTE="${2:-}"; shift 2;;
    --no-gitflow) INIT_GITFLOW=0; shift;;
    -y|--yes) YES=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "Unknown option: $1 (use -h)";;
  esac
done

# -------- validate manifest directory --------
[[ -d "$MANIFEST_DIR" ]] || die "Manifest directory not found: $MANIFEST_DIR"
say "Using manifest directory: $MANIFEST_DIR"

# -------- prereqs --------
require_cmd node
require_cmd npm
require_cmd git
require_cmd dotnet

NODE_MAJ=$(node -p "process.versions.node.split('.')[0]")
(( NODE_MAJ >= 18 )) || die "Node >= 18 required (found $(node -v))"

say "Project dir: $PROJECT"

if [[ -e "$PROJECT" ]] && [[ -n "$(ls -A "$PROJECT" 2>/dev/null || true)" ]]; then
  if [[ $YES -ne 1 ]]; then
    read -r -p "Target directory exists and is not empty. Continue and overwrite files where needed? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || die "Aborted."
  fi
fi

mkdir -p "$PROJECT"

# -------- merge manifests --------
say "Merging manifest files from $MANIFEST_DIR…"

# Create a temporary merged manifest
echo "[]" > "$PROJECT/manifest.json"

# Use Node.js to merge all manifest files
node - "$MANIFEST_DIR" "$PROJECT/manifest.json" <<'NODE'
const fs = require('fs');
const path = require('path');

const manifestDir = process.argv[2];
const outputFile = process.argv[3];

let allItems = [];
let fileCount = 0;

// Read all .json files from manifest directory
const files = fs.readdirSync(manifestDir)
  .filter(f => f.endsWith('.json'))
  .sort();

for (const file of files) {
  const filePath = path.join(manifestDir, file);
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const items = JSON.parse(content);
    if (Array.isArray(items)) {
      allItems = allItems.concat(items);
      fileCount++;
      console.log(`  • Loaded ${file} (${items.length} items)`);
    }
  } catch (e) {
    console.error(`Warning: Could not load ${file}: ${e.message}`);
  }
}

// Write merged manifest
fs.writeFileSync(outputFile, JSON.stringify(allItems, null, 2), 'utf8');
console.log(`Merged ${fileCount} manifest files → ${allItems.length} total items`);
NODE

pushd "$PROJECT" >/dev/null

# -------- apply manifest --------
say "Applying manifest (writing files)…"
node - "$PWD/manifest.json" <<'NODE'
const fs=require('fs'), path=require('path');
const mfPath=process.argv[2];
const items=JSON.parse(fs.readFileSync(mfPath,'utf8'));
let count=0;
for(const {path:p,content} of items){
  const dir=path.dirname(p);
  fs.mkdirSync(dir,{recursive:true});
  fs.writeFileSync(p, content, 'utf8');
  if(/(^tools\/hooks\/|^tools\/git\/flow\.sh$|^scripts\/install-hooks\.sh$|^tools\/mcp\/.*\.js$|^tools\/metrics\/check-pyramid\.js$)/.test(p)){
    try{ fs.chmodSync(p,0o755); }catch(e){}
  }
  count++;
}
console.log(`Wrote ${count} files ✔`);
NODE
ok "Files written"

# -------- git init / gitflow --------
if [[ ! -d .git ]]; then
  say "Initializing git repo…"
  git init >/dev/null
fi

git add . >/dev/null
git commit -m "chore(scaffold): add BMAD CCA baseline" >/dev/null || true

if [[ -n "$GIT_REMOTE" ]]; then
  git remote remove origin >/dev/null 2>&1 || true
  git remote add origin "$GIT_REMOTE"
fi

if [[ $INIT_GITFLOW -eq 1 ]]; then
  say "Setting up GitFlow branches (main & develop)…"
  bash tools/git/flow.sh init || say "GitFlow may be already initialized; continuing."
fi

# -------- install deps & hooks --------
say "Installing Node deps (frontend)…"
( cd app-frontend && { [ -f package-lock.json ] && npm ci || npm install; } ) >/dev/null

if [[ $INSTALL_PLAYWRIGHT -eq 1 ]]; then
  say "Installing Playwright browsers…"
  ( cd app-frontend && npx --yes playwright install --with-deps ) >/dev/null || say "Playwright install skipped (non-critical)."
fi

say "Restoring .NET solution…"
dotnet restore ./app-api/AppApi.sln >/dev/null

say "Installing git hooks…"
bash scripts/install-hooks.sh

# -------- first sanity runs (optional) --------
if [[ $RUN_TESTS -eq 1 ]]; then
  say "Running frontend unit tests…"
  ( cd app-frontend && npm test --silent ) || die "Frontend unit tests failed."

  say "Running API unit tests (with coverage gate)…"
  dotnet test ./app-api/tests/UnitTests /p:CollectCoverage=true /p:Threshold=80 || die "API unit tests failed."

  say "Running architecture tests…"
  dotnet test ./app-api/tests/ArchitectureTests || die "Architecture tests failed."

  say "Linting & verifying OpenAPI (contract)…"
  ( cd app-frontend && npm run api:lint && npm run api:diff )
  say "Checking test pyramid ratios…"
  node tools/metrics/check-pyramid.js || say "Pyramid check not satisfied yet (add E2E/contract tests later)."
else
  say "Skipping initial tests (per --no-tests)."
fi

ok "Bootstrap complete."

cat <<'NEXT'

Next steps:
  1) (Optional) Add env secrets for MCP servers:
     cp env/.env.example env/.env   # then export vars in your shell/devcontainer
  2) Open in Dev Container (VS Code: "Dev Containers: Rebuild and Reopen in Container")
  3) TDD loops:
     - dotnet watch test ./app-api/tests/UnitTests
     - (in another terminal) cd app-frontend && npm run test:watch
  4) Claude Code slash-commands (inside IDE):
     /arch check   • /api contract verify   • /security scan
     /git feature my-change   • /plan create "My change"

Tips:
  - Large edits (>100 lines) require a Plan ID (guardrail).
  - Commits must be small, tested, and follow Conventional Commits.

Happy shipping! 🚀
NEXT

popd >/dev/null