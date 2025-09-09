# Frontend Manifest

This manifest contains the file structure and content for the frontend components.

## app-frontend/package.json

```json
{
  "name": "app-frontend",
  "private": true,
  "scripts": {
    "test": "jest --ci --coverage",
    "test:watch": "jest --watch",
    "arch:check": "depcruise --config src/architecture/depcruise.config.js src | dependency-cruiser -",
    "api:lint": "spectral lint --ruleset ../.spectral.yaml ../api/openapi.yaml",
    "api:diff": "openapi-diff ../api/openapi.yaml ../api/openapi.yaml",
    "e2e": "playwright test",
    "e2e:report": "playwright show-report",
    "e2e:trace": "playwright show-trace"
  },
  "devDependencies": {
    "@playwright/test": "^1.47.0",
    "@stoplight/spectral-cli": "^6.11.1",
    "@types/jest": "^29.5.0",
    "dependency-cruiser": "^16.5.0",
    "jest": "^29.7.0",
    "jest-environment-jsdom": "^29.7.0",
    "openapi-diff": "^0.24.1",
    "ts-jest": "^29.2.5",
    "ts-node": "^10.9.0",
    "typescript": "^5.5.0"
  }
}

```

---

## .spectral.yaml

```yaml
extends: ["spectral:oas"]
rules:
  # Disable some optional rules
  info-contact: false
  info-description: false  
  info-license: false
  operation-tags: false
  # Keep core validation enabled (these are already enabled by spectral:oas)
  # operation-description: true
  # operation-operationId-unique: true  
  # path-declarations-must-exist: true
  # path-keys-no-trailing-slash: true
  # path-not-include-query: true
  # path-parameters-defined: true

```

---

## app-frontend/jest.config.ts

```typescript
import type { Config } from 'jest';
const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  collectCoverage: true,
  coverageThreshold: { global: { statements: 70, branches: 60, functions: 70, lines: 70 } }
};
export default config;

```

---

## app-frontend/tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Node",
    "strict": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {}
  },
  "include": ["src/**/*.ts", "jest.config.ts"]
}

```

---

## app-frontend/.eslintrc.json

```json
{
  "root": true,
  "parserOptions": { "project": ["./tsconfig.json"] },
  "env": { "es2022": true, "browser": true, "node": true },
  "extends": [],
  "rules": {
    "no-restricted-imports": ["error", { "patterns": ["src/app/features/*/*", "src/app/shared/*/*"] }]
  }
}

```

---

## app-frontend/src/architecture/depcruise.config.js

```javascript
module.exports = {
  forbidden: [
    { name: 'no-cycles', severity: 'error', from: {}, to: { circular: true } },
    { name: 'shared-no-import-features', severity: 'error', from: { path: '^src/app/shared' }, to: { path: '^src/app/features' } },
    { name: 'public-api-only', severity: 'error', from: { path: 'src/app/(features|shared)/.+' }, to: { path: 'src/app/(features|shared)/.+', pathNot: 'public-api.ts' } }
  ],
  options: { tsConfig: { fileName: 'tsconfig.json' } }
};

```

---

## app-frontend/src/app/app.component.ts

```typescript
export class AppComponent { title = 'app-frontend'; }

```

---

## app-frontend/src/app/app.component.spec.ts

```typescript
import { AppComponent } from './app.component';

describe('AppComponent', () => {
  let component: AppComponent;

  beforeEach(() => {
    component = new AppComponent();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should have app-frontend as title', () => {
    expect(component.title).toEqual('app-frontend');
  });
});

```

---

## app-frontend/playwright.config.ts

```typescript
import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: './e2e',
  reporter: [['list'], ['html', { outputFolder: 'playwright-report' }]],
  use: { trace: 'on-first-retry', video: 'retain-on-failure', screenshot: 'only-on-failure' }
});

```

