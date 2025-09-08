# CMX Backend Architecture Guide

## Overview
This document defines the **mandatory** architectural patterns and guidelines for all CMX .NET backend projects.

## Tech Stack

### **Backend Tech Stack**
- **.NET 8**: Backend framework for building scalable, high-performance APIs.  
- **SQL Server**: Relational database for secure and efficient data storage.  
- **MediateR**: Library for implementing the mediator pattern to ensure clean separation of concerns.  
- **FluentValidation**: Library for request validation using `AbstractValidator` classes.  
- **Xunit**: Unit testing framework for .NET applications.  
- **NSubstitute**: Mocking library for creating test doubles in unit tests.  
- **Flagsmith**: Feature flag management for controlled rollouts and A/B testing.  
- **EAGLE Logger**: Logging and monitoring tool for tracking system performance and debugging.  
- **N-Tier Architecture**: Modular design with distinct layers (Presentation, Business Logic, Data Access).

## Directory Structure Template

```
CMX/
 ├─ src/
 │ ├─ API/
 │ │ ├─ Controllers/
 │ │ └─ Middlewares/
 │ ├─ Application/
 │ │ ├─ Handlers/
 │ │ └─ Validators/
 │ ├─ Domain/
 │ │ ├─ Entities/
 │ │ └─ Interfaces/
 │ ├─ Infrastructure/
 │ │ ├─ Services/
 │ │ └─ Persistence/
 │ └─ BuildingBlocks/
 │   ├─ Logging/
 │   ├─ FeatureFlags/
 │   └─ Common/
 └─ tests/
     ├─ UnitTests/
     └─ IntegrationTests/
```

## SOLID Principles Compliance
- **MANDATORY**: All code must follow SOLID principles
- Use dependency injection, interface segregation, and single responsibility
- Ensure classes are open for extension, closed for modification

## Architectural Guidelines

### 1. Controllers
- Entry points for API requests.  
- **ABSOLUTE RULE: ZERO business logic, validation, or conditions** allowed in controllers.  
- **MANDATORY**: Controllers must ONLY delegate to **Handlers** via **MediatR**.  
- **FORBIDDEN**: Controllers cannot directly interact with Managers, Services, or Repositories.
- **FORBIDDEN**: Controllers cannot instantiate response objects directly.
- **FORBIDDEN**: Controllers cannot perform any data processing or business operations.
- **AI ASSISTANTS:** Generate ONLY routing and MediatR delegation - ANY other code is FORBIDDEN.

### 2. Handlers
- Process requests received from controllers via **MediatR**.  
- Coordinate with **Managers** to execute business logic.  
- **STRICT RULE: Handlers can only interact with Managers**.
- Must implement `IRequestHandler<TRequest, TResponse>` interface.
- **AI ASSISTANTS:** Generate handlers that orchestrate workflow through managers only.

### 3. Managers
- Encapsulate business workflows and logic.  
- Ensure reusability and separation of concerns.  
- **STRICT RULE: Managers can only interact with Services**.
- Handle complex business rules and orchestration.
- **AI ASSISTANTS:** Place all business logic in managers, never in handlers or controllers.

### 4. Services
- Handle data access, external API calls, and utilities.  
- **EXCLUSIVE RULE: Only Services can directly access the database**.  
- Services cannot interact with Managers, Handlers, or Controllers.
- Implement repository patterns and data mapping.
- **AI ASSISTANTS:** All database operations must be implemented in services only.

### 5. Layered Structure
Strict layered approach:  
`Controller → Handler → Manager → Service`

### 6. Validation
- **MANDATORY:** Must use **FluentValidation** with `AbstractValidator` classes.  
- **FORBIDDEN:** No `if-else` validation in controllers, handlers, or managers.  
- Rules must include required fields, format checks, and ranges.
- All validation must be declarative and testable.
- **AI ASSISTANTS:** Always create separate validator classes inheriting from `AbstractValidator<T>`.

### 7. Error Handling
- All errors handled by **Global Exception Middleware**.  
- Use **ProblemDetails (RFC 7807)** for standardized API responses.  
- Exceptions must never propagate beyond middleware.

### 8. Logging & Observability
- Use **EAGLE Logger** for all logs.  
- All logs must include **TraceId / CorrelationId**.  
- Support structured logging (JSON).  
- Log levels: `Info`, `Warning`, `Error`.

### 9. Health Checks
- **MANDATORY**: Use Microsoft.AspNetCore.Diagnostics.HealthChecks
- **Endpoint**: `/hc` - Single endpoint displaying all health information
- **Version Display**: Start with version 1.0.0, follow semantic versioning  
- **Database Health**: SQL Server connection status and response time
- **Dependencies Health**: External APIs, message queues, cache services, EAGLE Logger, Flagsmith feature flags status

### 10. Testing Requirements
- **NON-NEGOTIABLE: 90%+ unit test coverage required**.  
- **NON-NEGOTIABLE: <10% code duplication** across the project.  
- Testing responsibilities:
  - Controller → routing/authorization  
  - Handler → request flow (mock Managers)  
  - Manager → business logic (mock Services)
  - Service → DB/API interactions (mock dependencies)  
- **MANDATORY FRAMEWORKS:** Xunit + NSubstitute.
- **AI ASSISTANTS:** Generate tests for every class created, following the testing responsibilities above.

### 11. SonarLint Compliance
- **MANDATORY**: Use SonarLint to minimize code warnings
- **Target**: Aim for zero warnings in generated code
- **Key Rules**: Proper naming conventions, avoid unused code, handle exceptions properly

## Implementation Order
When creating new features, follow this sequence:
1. Create domain entities and interfaces
2. Create FluentValidation validators
3. Create services (data layer)
4. Create managers (business logic)
5. Create handlers (orchestration)
6. Create controllers (API endpoints)
7. Create comprehensive unit tests for all layers