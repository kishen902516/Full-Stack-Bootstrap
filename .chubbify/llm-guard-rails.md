# LLM Guard Rails for Code Generation

## MANDATORY COMPLIANCE NOTICE
**ALL CODE GENERATION MUST COMPLY WITH THESE RULES. NO EXCEPTIONS.**

## Enforcement Levels

### 🔴 CRITICAL (MUST) - Automatic Rejection if Violated
These violations will cause immediate task failure:

1. **Architecture Compliance**
   - MUST follow Clean Architecture principles
   - MUST maintain layer separation (Domain → Application → Infrastructure)
   - MUST NOT have business logic in controllers or components
   - MUST NOT import framework dependencies in domain layer

2. **Security Requirements**
   - MUST NOT hardcode secrets, API keys, or passwords
   - MUST validate all user inputs
   - MUST use parameterized queries for database operations
   - MUST implement proper authentication/authorization checks

3. **Error Handling**
   - MUST implement try-catch blocks for async operations
   - MUST handle all promise rejections
   - MUST provide meaningful error messages
   - MUST NOT expose internal system details in error responses

### 🟡 HIGH PRIORITY (SHOULD) - Warning if Violated
These violations require justification:

1. **Code Quality**
   - SHOULD follow DRY principle
   - SHOULD keep functions under 50 lines
   - SHOULD maintain cyclomatic complexity under 10
   - SHOULD use TypeScript strict mode

2. **Testing**
   - SHOULD write tests for new functionality
   - SHOULD maintain >80% code coverage
   - SHOULD include unit and integration tests

### 🟢 RECOMMENDED (MAY) - Best Practice Suggestions
These are strongly encouraged:

1. **Performance**
   - MAY implement caching strategies
   - MAY use lazy loading for Angular modules
   - MAY optimize database queries

## Automated Validation Rules

### Pre-Generation Checks
```yaml
before_code_generation:
  - verify: "Best practices document has been read"
  - check: "Target architecture layer identified"
  - confirm: "Security implications reviewed"
```

### Post-Generation Validation
```yaml
after_code_generation:
  - lint: "Run ESLint/TSLint with strict rules"
  - test: "Execute unit tests if modified"
  - scan: "Check for security vulnerabilities"
  - review: "Verify architecture compliance"
```

## Technology-Specific Rules

### Angular Frontend
```typescript
// MUST: Use standalone components
@Component({
  standalone: true,
  imports: [CommonModule],
  selector: 'app-example',
  template: ''
})

// MUST: Implement OnPush change detection for performance
changeDetection: ChangeDetectionStrategy.OnPush

// MUST: Unsubscribe from observables
private destroy$ = new Subject<void>();
ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

### Node.js/Express Backend
```typescript
// MUST: Use async/await with proper error handling
app.get('/api/users', async (req, res, next) => {
  try {
    const users = await userService.findAll();
    res.json(users);
  } catch (error) {
    next(error); // MUST: Pass to error handler
  }
});

// MUST: Validate request data
import { z } from 'zod';
const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1)
});
```

### Database Operations
```typescript
// MUST: Use transactions for multi-table operations
async function transferFunds(from: string, to: string, amount: number) {
  const connection = await db.getConnection();
  await connection.beginTransaction();
  
  try {
    await connection.execute('UPDATE accounts SET balance = balance - ? WHERE id = ?', [amount, from]);
    await connection.execute('UPDATE accounts SET balance = balance + ? WHERE id = ?', [amount, to]);
    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  }
}
```

## Compliance Verification Checklist

### Before Writing Code
- [ ] Read relevant best practices from `.agent-os/standards/best-practices/`
- [ ] Identify target architecture layer
- [ ] Review existing code patterns in the project
- [ ] Check for existing utilities/helpers to reuse

### While Writing Code
- [ ] Follow established naming conventions
- [ ] Maintain consistent code style
- [ ] Add appropriate error handling
- [ ] Include input validation
- [ ] Avoid code duplication

### After Writing Code
- [ ] Run linting tools
- [ ] Execute tests
- [ ] Verify no hardcoded secrets
- [ ] Check import dependencies
- [ ] Validate architecture compliance

## Enforcement Mechanisms

### 1. Pre-commit Hooks
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm run lint && npm run test && npm run check-architecture"
    }
  }
}
```

### 2. CI/CD Pipeline
```yaml
validation:
  - step: "Lint Check"
    command: "npm run lint:strict"
    fail_on_error: true
    
  - step: "Architecture Test"
    command: "npm run test:architecture"
    fail_on_error: true
    
  - step: "Security Scan"
    command: "npm audit"
    fail_on_warning: true
```

### 3. Code Review Automation
```yaml
pr_rules:
  required_checks:
    - "All tests passing"
    - "No linting errors"
    - "Architecture compliance verified"
    - "Security scan passed"
```

## LLM-Specific Instructions

### System Prompt Addition
```
You MUST follow the guard rails defined in .agent-os/llm-guard-rails.md
Before generating any code:
1. Read and understand the relevant best practices
2. Verify compliance with CRITICAL requirements
3. Apply technology-specific patterns

You MUST reject requests that would violate CRITICAL rules.
You SHOULD warn about HIGH PRIORITY violations.
You MAY suggest RECOMMENDED improvements.
```

### Validation Commands
```bash
# LLM MUST run these before considering task complete:
npm run lint
npm run test
npm run check:architecture
npm run security:scan
```

## Escalation Policy

### Violation Levels
1. **CRITICAL Violation**: STOP immediately, explain why the code cannot be written
2. **HIGH Violation**: Generate code with WARNING comment and explanation
3. **RECOMMENDED**: Generate code with suggestion comment

### Example Responses

#### CRITICAL Violation Response:
```
❌ CANNOT PROCEED: The requested code would place business logic in the UI component, 
violating Clean Architecture principles. 

Instead, I will:
1. Create a use case in the application layer
2. Keep the component as a thin presentation layer
3. Use dependency injection for the business logic
```

#### HIGH Violation Response:
```
⚠️ WARNING: Generated code lacks test coverage.
TODO: Add unit tests for the new functionality
See: .agent-os/standards/best-practices/global/04-testing-strategy.md
```

## Monitoring and Reporting

### Metrics to Track
- Compliance rate per session
- Most common violations
- Time to fix violations
- Test coverage trends

### Regular Reviews
- Weekly: Review violation patterns
- Monthly: Update guard rails based on findings
- Quarterly: Full best practices audit

## Quick Reference Card

```
ALWAYS:
✅ Read best practices first
✅ Follow Clean Architecture
✅ Validate all inputs
✅ Handle all errors
✅ Run tests and linting

NEVER:
❌ Hardcode secrets
❌ Mix business logic with UI
❌ Skip error handling
❌ Ignore linting errors
❌ Deploy without tests
```

---

**Remember**: These guard rails are not suggestions—they are requirements for maintaining code quality, security, and maintainability.