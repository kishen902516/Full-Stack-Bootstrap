# CLAUDE.md - AI Assistant Configuration

## ⚠️ MANDATORY COMPLIANCE FRAMEWORK ⚠️

**THIS IS A CONTROLLED CODEBASE WITH STRICT GUARD RAILS**

### 🔴 CRITICAL: You MUST Read These Files FIRST
1. `.agent-os/standards/best-practices.md` - Core development principles
2. `.agent-os/llm-guard-rails.md` - Mandatory compliance rules
3. `.agent-os/llm-pre-prompt.md` - Pre-execution protocol
4. `.agent-os/code-validation-rules.json` - Automated validation rules

### 🚨 ENFORCEMENT MODE: STRICT

## Project Overview

**Project**: Test Project 2
**Tech Stack**:
- Frontend: angular with TypeScript (strict mode)
- Backend: nodejs with TypeScript
- Database: postgresql
- Testing: jest (>80% coverage required)
- Architecture: Clean Architecture (Domain-Driven Design)

## Guard Rails System

### Automatic Rejection Triggers (CRITICAL)
You MUST REFUSE to generate code that:
- ❌ Places business logic in UI components or controllers
- ❌ Violates Clean Architecture layer separation
- ❌ Contains hardcoded secrets, passwords, or API keys
- ❌ Lacks proper error handling for async operations
- ❌ Skips input validation on user-provided data
- ❌ Imports framework dependencies in the domain layer

### Warning Triggers (HIGH PRIORITY)
You SHOULD WARN when code:
- ⚠️ Violates DRY principle
- ⚠️ Exceeds complexity thresholds (>10 cyclomatic complexity)
- ⚠️ Lacks test coverage
- ⚠️ Uses 'any' type in TypeScript
- ⚠️ Has functions longer than 50 lines

## Pre-Code Generation Protocol

```yaml
BEFORE_ANY_CODE_GENERATION:
  1_LOAD_CONTEXT:
    - READ: Best practices for target layer
    - SCAN: Existing code patterns
    - IDENTIFY: Architecture layer
    
  2_VERIFY_COMPLIANCE:
    - CHECK: No CRITICAL violations
    - CHECK: Minimize HIGH violations
    - CHECK: Security implications
    
  3_APPLY_PATTERNS:
    - USE: Existing project utilities
    - FOLLOW: Established conventions
    - MAINTAIN: Consistency
```

## Validation Commands

**You MUST run these commands mentally before considering any task complete:**

```bash
# Linting (MUST PASS)
npm run lint

# Type checking (MUST PASS)
npm run typecheck

# Architecture validation (MUST PASS)
npm run check:architecture

# Tests (SHOULD PASS)
npm run test

# Security scan (MUST HAVE NO HIGH/CRITICAL)
npm audit
```

## File Structure Compliance

```
src/
├── domain/           # NO framework dependencies
│   ├── entities/     # Business entities
│   ├── services/     # Domain services
│   └── ports/        # Interface definitions
├── application/      # Use cases ONLY
│   ├── use-cases/    # Business logic
│   └── dtos/         # Data transfer objects
├── infrastructure/   # Framework-specific code
│   ├── repositories/ # Database implementations
│   ├── services/     # External service adapters
│   └── config/       # Configuration
└── presentation/     # UI Layer
    ├── components/   # UI components (thin)
    ├── services/     # Framework services
    └── guards/       # Route guards
```

## Continuous Compliance Monitoring

### Every Code Generation MUST Include:
1. **Compliance Statement**: Which best practices were followed
2. **Layer Identification**: Which architecture layer was modified
3. **Pattern Justification**: Why specific patterns were chosen
4. **Validation Checklist**: What checks would pass/fail

## Final Checklist

Before ANY code submission:
- [ ] Best practices document read for relevant layer
- [ ] No CRITICAL violations present
- [ ] All HIGH violations documented with TODOs
- [ ] Existing patterns followed
- [ ] Would pass linting
- [ ] Would pass type checking
- [ ] Error handling complete
- [ ] Input validation present
- [ ] No hardcoded secrets

---

**Remember**: These rules are NOT optional. They are MANDATORY for maintaining code quality, security, and architectural integrity. When in doubt, be MORE strict, not less.
