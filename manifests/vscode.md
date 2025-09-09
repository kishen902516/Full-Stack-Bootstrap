# Vscode Manifest

This manifest contains the file structure and content for the vscode components.

## .vscode/tasks.json

```json
{
  "version": "2.0.0",
  "tasks": [
    { "label": "TDD: watch FE",  "type": "shell", "command": "npm run test:watch", "options": { "cwd": "app-frontend" } },
    { "label": "Architecture check", "type": "shell", "command": "npm run arch:check && dotnet test ./app-api/tests/ArchitectureTests", "options": { "cwd": "app-frontend" } },
    { "label": "Contract verify", "type": "shell", "command": "npm run api:lint && npm run api:diff", "options": { "cwd": "app-frontend" } },
    { "label": "E2E: Run", "type": "shell", "command": "npm run e2e", "options": { "cwd": "app-frontend" } },
    { "label": "E2E: Report", "type": "shell", "command": "npm run e2e:report", "options": { "cwd": "app-frontend" } },
    { "label": "Context7: Refresh Index", "type": "shell", "command": "node tools/mcp/context7-index.js" },
    { "label": "TDD: watch API", "type": "shell", "command": "dotnet watch test ./app-api/tests/UnitTests" }
  ]
}

```

---

## .vscode/extensions.json

```json
{
  "recommendations": ["anthropic.claude-dev"]
}

```

