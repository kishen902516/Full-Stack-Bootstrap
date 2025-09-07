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

**Project**: Full-Stack Bootstrap  
**Tech Stack**:
- Frontend: Angular 18+ with TypeScript (strict mode)
- Backend: Node.js/Express with TypeScript
- Database: PostgreSQL/MongoDB
- Testing: Jest/Jasmine (>80% coverage required)
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

## Code Generation Rules by Layer

### Frontend (Angular)
```typescript
// MANDATORY patterns for ALL Angular components:
@Component({
  standalone: true,  // REQUIRED
  changeDetection: ChangeDetectionStrategy.OnPush,  // REQUIRED
  imports: [CommonModule],  // REQUIRED
})

// REQUIRED: Subscription cleanup
private destroy$ = new Subject<void>();
ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

### Backend (Express/Node.js)
```typescript
// MANDATORY patterns for ALL routes:
router.post('/endpoint', 
  validateInput(schema),  // REQUIRED
  authenticate(),  // When needed
  async (req, res, next) => {
    try {  // REQUIRED
      const result = await service.execute(req.body);
      res.json(result);
    } catch (error) {
      next(error);  // REQUIRED: Proper error propagation
    }
  }
);
```

### Database Operations
```typescript
// MANDATORY for multi-table operations:
const transaction = await db.transaction();
try {
  // operations
  await transaction.commit();
} catch (error) {
  await transaction.rollback();
  throw error;
}
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

## Response Templates

### When Asked to Violate CRITICAL Rules:
```
❌ CANNOT PROCEED: [Specific violation]

This violates: [Rule reference from guard rails]

ALTERNATIVE APPROACH:
1. [Compliant solution step 1]
2. [Compliant solution step 2]
3. [Compliant solution step 3]

This maintains Clean Architecture and security standards.
```

### When Detecting HIGH Priority Issues:
```
⚠️ WARNING: [Specific issue]

Generated code includes a warning because: [Reason]

RECOMMENDATION:
- [Improvement suggestion]
- Reference: .agent-os/standards/best-practices/[relevant-file].md

TODO: [Specific action to address warning]
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
    ├── components/   # Angular components (thin)
    ├── services/     # Angular services
    └── guards/       # Route guards
```

## Continuous Compliance Monitoring

### Every Code Generation MUST Include:
1. **Compliance Statement**: Which best practices were followed
2. **Layer Identification**: Which architecture layer was modified
3. **Pattern Justification**: Why specific patterns were chosen
4. **Validation Checklist**: What checks would pass/fail

### Session Tracking:
```json
{
  "session_compliance": {
    "best_practices_loaded": true,
    "guard_rails_applied": true,
    "critical_violations": 0,
    "warnings_issued": 0,
    "patterns_followed": ["clean-architecture", "error-handling", "validation"],
    "validation_status": "PASS"
  }
}
```

## Quick Decision Matrix

| Request Type | Check | Action |
|-------------|-------|--------|
| Add business logic to component | ❌ CRITICAL | REJECT - Move to use case |
| Skip error handling | ❌ CRITICAL | REJECT - Add try-catch |
| Hardcode API key | ❌ CRITICAL | REJECT - Use environment |
| Long function | ⚠️ HIGH | WARN - Suggest refactor |
| Missing test | ⚠️ HIGH | WARN - Add TODO |
| Use any type | ⚠️ HIGH | WARN - Suggest proper type |

## Emergency Override

**ONLY for exceptional circumstances with explicit user approval:**

```typescript
// ⚠️ GUARD RAIL OVERRIDE: [Reason]
// APPROVED BY: [User confirmation]
// RISK: [Specific risk]
// MITIGATION: [How to address later]
// TODO: Refactor to comply with best practices
```

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