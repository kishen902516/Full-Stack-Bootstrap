# CMX Frontend Architecture Guide

## Overview
This document defines the **mandatory** architectural patterns and guidelines for all CMX Angular frontend projects.

## Tech Stack

### **Frontend Tech Stack**
- **Angular 17**: Modern frontend framework with standalone components
- **TypeScript**: Type-safe JavaScript with compile-time error checking
- **Angular CLI**: Development tools and build system
- **RxJS**: Reactive programming with observables
- **Angular Material**: UI component library following Material Design
- **NgRx**: State management for complex applications
- **Angular Forms**: Reactive forms with validation
- **Angular Router**: Client-side routing and navigation
- **Jasmine + Karma**: Unit testing framework
- **Cypress**: End-to-end testing framework

## Directory Structure Template

```
CMX-Frontend/
 ├─ src/
 │ ├─ app/
 │ │ ├─ core/
 │ │ │ ├─ services/
 │ │ │ ├─ guards/
 │ │ │ └─ interceptors/
 │ │ ├─ shared/
 │ │ │ ├─ components/
 │ │ │ ├─ pipes/
 │ │ │ └─ directives/
 │ │ ├─ features/
 │ │ ├─ layout/
 │ │ └─ models/
 │ ├─ assets/
 │ └─ environments/
 └─ tests/
```

## SOLID Principles Compliance
- **MANDATORY**: All code must follow SOLID principles
- Use dependency injection, interface segregation, and single responsibility
- Services for business logic, components for presentation only

## Architectural Guidelines

### 1. Components
- **Single Responsibility**: Each component has one clear purpose
- **Standalone Components**: Use Angular 17 standalone components
- **OnPush Change Detection**: Use OnPush strategy for better performance
- **No Business Logic**: Components only handle UI and user interactions
- **Lifecycle Hooks**: Implement proper lifecycle hook management

### 2. Services
- **Injectable Services**: All services must be injectable with proper DI
- **Single Responsibility**: Each service handles one specific domain
- **HTTP Handling**: Use HttpClient for all API communications
- **Error Handling**: Implement consistent error handling patterns
- **Observables**: Use RxJS observables for async operations

### 3. State Management
- **NgRx**: Use NgRx for complex state management
- **Actions**: Define clear actions for state changes
- **Reducers**: Pure functions for state updates
- **Effects**: Handle side effects and API calls
- **Selectors**: Use selectors for state queries

### 4. Forms
- **Reactive Forms**: Use Angular Reactive Forms exclusively
- **Form Validation**: Implement proper form validation with validators
- **Custom Validators**: Create reusable custom validators
- **Form State**: Manage form state properly with FormBuilder

### 5. Routing
- **Lazy Loading**: Implement lazy loading for feature modules
- **Route Guards**: Use guards for authentication and authorization
- **Resolver**: Use resolvers for data pre-loading
- **Type-Safe Routes**: Define routes with proper typing

### 6. HTTP and Data
- **HttpClient**: Use Angular HttpClient for all HTTP operations
- **Interceptors**: Implement HTTP interceptors for common concerns
- **Error Handling**: Global error handling for HTTP requests
- **Caching**: Implement appropriate caching strategies

### 7. Styling
- **Angular Material**: Use Angular Material for UI components
- **SCSS**: Use SCSS for custom styling
- **Theme System**: Implement consistent theming
- **Responsive Design**: Mobile-first responsive approach

### 8. Error Handling
- **Global Error Handler**: Implement Angular ErrorHandler
- **HTTP Error Interceptor**: Handle HTTP errors consistently
- **User Notifications**: Display meaningful error messages
- **Logging**: Implement proper error logging

### 9. Health Checks
- **MANDATORY**: Implement frontend health monitoring
- **Endpoint**: `/hc` - Application health status
- **Version Display**: Start with version 1.0.0, follow semantic versioning
- **API Health**: Monitor backend API connectivity and response times
- **Performance Metrics**: Track application performance metrics

### 10. Testing Requirements
- **NON-NEGOTIABLE: 90%+ test coverage required**
- **NON-NEGOTIABLE: <10% code duplication** across the project
- **Testing Responsibilities**:
  - Components → rendering and user interactions
  - Services → business logic and API calls
  - Pipes → data transformation
  - Guards → route protection logic
- **MANDATORY FRAMEWORKS**: Jasmine + Karma for unit tests, Cypress for E2E
- **AI ASSISTANTS**: Generate tests for every component and service created

### 11. TypeScript Guidelines
- **Strict Mode**: Enable strict TypeScript configuration
- **Interface Definitions**: Create clear interfaces for all data structures
- **Type Safety**: Ensure compile-time type safety
- **Generic Types**: Use generics for reusable components and services

### 12. Code Quality Standards
- **MANDATORY**: Use ESLint and Prettier for code formatting
- **Target**: Aim for zero linting errors and warnings
- **Angular Style Guide**: Follow official Angular style guide
- **Accessibility**: Follow WCAG guidelines and use CDK a11y
- **Performance**: Optimize bundle size and runtime performance

## Implementation Order
When creating new features, follow this sequence:
1. Define TypeScript interfaces and models
2. Create feature module with routing
3. Implement services with dependency injection
4. Create components with proper lifecycle management
5. Add NgRx state management if needed
6. Implement reactive forms with validation
7. Add proper error handling and loading states
8. Create comprehensive unit and integration tests