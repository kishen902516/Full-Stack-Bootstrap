# Angular Code Style (Agent‑OS: `standards/code-style/angular-style.md`)

> **Source of truth:** Official Angular docs (angular.dev).  
> **Scope:** Angular (v17+) applications using standalone components.  
> **Override rule:** This section **overrides** General Formatting where it conflicts.

<conditional-block task-condition="angular" context-check="angular-style">
IF current task involves writing or updating **Angular** code:
  IF angular-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Angular style guide already in context"
  ELSE:
    READ: The following **Angular.dev–based** style rules

## 1) Project structure

- **All UI code lives under `src/`**; non-UI (configs/scripts) live outside `src/`.  
  Rationale: keeps Angular roots consistent & separates concerns. citeturn1view0

- **Bootstrap in `src/main.ts`**.  
  Rationale: one predictable entry point. citeturn1view0

- **Group related files together** (component TS + template + styles + tests in same folder).  
  **Organize by feature area**, not by type (avoid `components/`, `services/` bins).  
  Prefer **one concept per file**. citeturn1view0

## 2) Naming & files

- **Hyphenate file names**: `user-profile.ts`.  
  **Unit tests end with `.spec.ts`**. **File names match identifier**.  
  **Component triplet shares same base name**: `user-profile.ts|html|css`. citeturn1view0

## 3) Components (standalone by default)

- **Use standalone components**; import components/directives/pipes via the `imports` array in `@Component`.  
  Note: In Angular versions **before 19**, `standalone` default is `false`. citeturn5view0

## 4) Selectors & prefixes

- Prefer **custom element selectors** (must include a **hyphen** per HTML spec).  
  Use a short **project prefix** (e.g., `acme-`); **never** use `ng-`. citeturn2view0

- When using **attribute selectors**, keep them **lowercase dash‑case** and consider them for native elements like `<button>`. citeturn2view0

## 5) Templates & control flow

- Use the built‑in control‑flow blocks: **`@if` / `@else if` / `@else`**, **`@for`** with **`track`**, and **`@switch`**.  
  `track` keeps data ↔ DOM mapping stable and improves performance. citeturn6view0

- **Avoid overly complex logic in templates**; move logic into TypeScript (e.g., computed signals). citeturn1view0

- **Prefer `[class]` / `[style]` bindings** over `NgClass` / `NgStyle` for readability and performance. citeturn1view0

- **Name handlers by action**, not event: `(click)="saveUserData()"` (avoid `handleClick`). citeturn1view0

- Members **only used by the template** should be `protected`; inputs/outputs/models **should be `readonly`**. citeturn1view0

## 6) Dependency injection

- Prefer **`inject()`** over constructor parameter injection for readability and type inference. citeturn1view0

## 7) Styling & encapsulation

- Default to **`ViewEncapsulation.Emulated`**; understand trade‑offs of `ShadowDom`; avoid `ViewEncapsulation.None`.  
  The Angular team **discourages new use of `::ng-deep`** (kept for backwards compatibility). citeturn3view0

## 8) Performance notes

- Angular’s change detection is optimized, but you should **limit unnecessary checks** and **skip subtrees when possible**; use DevTools to profile.  
  Control‑flow `@for` with **`track`** is key for list performance. citeturn4view0turn6view0

## 9) Definition of Done (Angular style)

- Feature organized under a **feature folder** with component TS/HTML/CSS/test colocated.  
- **File names hyphenated**; **tests `.spec.ts`**; **selectors prefixed** (not `ng-`).  
- **Templates use `@if/@for/@switch` appropriately** with `track`.  
- **No complex logic in templates**; prefer computed helpers.  
- **`inject()`** used when injecting services.  
- **Encapsulation** left as default unless justified; **no new `::ng-deep`** rules.  
- Lint/format run clean; app passes perf budgets where defined.

</conditional-block>
