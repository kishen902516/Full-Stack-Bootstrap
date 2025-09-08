# CMX (Claim Motor X) Project Orchestrator

This document serves as the central orchestrator for the CMX blueprint project, guiding Claude Code to generate projects following the specified agents and architectural guidelines.

## Command Format

```
[create/recheck] [project-name] as [backend/frontend] with [requirement modules]
```

**Available Requirement Modules:** `fnol`, `dispatcher`, `surveyor`

**Examples:**
```bash
create claim-processor as backend with [fnol, dispatcher, surveyor]
create policy-web as frontend with [fnol]
recheck claim-processor as backend with [fnol, dispatcher, surveyor]
```

## Architecture Guidelines

### Backend Projects
Follow: [tech/backend-architecture.md](./tech/backend-architecture.md)

### Frontend Projects  
Follow: [tech/frontend-architecture.md](./tech/frontend-architecture.md)

## Module Implementation

### FNOL Module
Follow: [modules/fnol-agent.md](./modules/fnol-agent.md)

### Dispatcher Module
Follow: [modules/dispatcher-agent.md](./modules/dispatcher-agent.md)

### Surveyor Module
Follow: [modules/surveyor-agent.md](./modules/surveyor-agent.md)

## Post-Hook Quality Report

### Backend Projects
Execute: [hooks/post-hook-backend.md](./hooks/post-hook-backend.md)

### Frontend Projects
Execute: [hooks/post-hook-frontend.md](./hooks/post-hook-frontend.md)

---

**Instructions for Claude Code:**
1. **Architecture**: Use the appropriate tech/ file based on project type (backend/frontend)
2. **Modules**: Implement each specified module using its corresponding modules/ agent file
3. **Quality**: Meet all requirements defined in the architecture files
4. **Post-Hook**: ALWAYS execute the appropriate post-hook after command completion