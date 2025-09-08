# Post-Hook Frontend Quality Report

## Overview
This post-hook must execute after every frontend command (create/recheck) and display comprehensive quality metrics to ensure compliance with [tech/frontend-architecture.md](../tech/frontend-architecture.md) requirements.

## Mandatory Display Requirements

### 1. Project Version Information
```
📋 PROJECT INFORMATION
Version: 1.0.0
Build Date: 2024-12-08 15:30:45
Environment: Development
Angular Version: 17.0.0
Build Number: #1234
```

### 2. Code Coverage Report
```
📊 CODE COVERAGE
Overall Coverage: 85.3% ✅ (Target: ≥80%)
Line Coverage: 87.1% ✅
Branch Coverage: 82.4% ✅
Function Coverage: 89.7% ✅

By Type:
- Components: 88.2% ✅
- Services: 91.5% ✅
- Pipes: 95.0% ✅
- Guards: 87.3% ✅
```

### 3. Code Duplication Analysis
```
🔄 CODE DUPLICATION
Total Duplication: 3.8% ✅ (Target: <5%)
Duplicated Lines: 156 / 4,100
Duplicated Blocks: 8
Largest Clone: 12 lines in user.component.ts & admin.component.ts

Duplication by Module:
- FNOL: 2.1% ✅
- Dispatcher: 4.2% ✅
- Surveyor: 4.8% ✅
- Shared: 1.9% ✅
```

### 4. Build & Bundle Analysis
```
📦 BUILD ANALYSIS
Build Status: ✅ SUCCESS
Bundle Size: 2.1 MB ✅ (Target: <3 MB)
Lazy Loaded Chunks: 5 ✅
Tree Shaking: ✅ ACTIVE

Chunk Analysis:
- Main Bundle: 1.2 MB
- Vendor Bundle: 0.7 MB
- FNOL Module: 0.12 MB
- Dispatcher Module: 0.08 MB
- Surveyor Module: 0.15 MB
```

### 5. Angular Architecture Compliance
```
🏗️ ARCHITECTURE COMPLIANCE
Standalone Components: ✅ PASS (95% using standalone)
OnPush Change Detection: ✅ PASS (85% of components)
Reactive Forms: ✅ PASS (No template-driven forms found)
Dependency Injection: ✅ PASS
Lazy Loading: ✅ PASS (All feature modules)
RxJS Best Practices: ✅ PASS (No subscribe in templates)
```

### 6. Performance Metrics
```
⚡ PERFORMANCE
First Contentful Paint: 1.2s ✅ (Target: <2s)
Largest Contentful Paint: 2.1s ✅ (Target: <2.5s)
Cumulative Layout Shift: 0.08 ✅ (Target: <0.1)
Time to Interactive: 2.8s ✅ (Target: <3s)

Lighthouse Score: 92/100 ✅
```

### 7. Linting & Code Quality
```
🔍 CODE QUALITY
ESLint Errors: 0 ✅
ESLint Warnings: 2 ⚠️
Prettier Issues: 0 ✅
TypeScript Errors: 0 ✅
Angular Style Guide: ✅ PASS

Accessibility (a11y):
- WCAG AA Compliance: ✅ PASS
- Keyboard Navigation: ✅ PASS
- Screen Reader Support: ✅ PASS
```

### 8. Quality Metrics Summary
```
📈 QUALITY SUMMARY
Overall Status: ⚠️ WARNING
- Code Coverage: ✅ PASS (85.3% ≥ 80%)
- Code Duplication: ✅ PASS (3.8% < 5%)
- Build Size: ✅ PASS (2.1 MB < 3 MB)
- Performance: ✅ PASS (Lighthouse: 92/100)
- ESLint: ⚠️ WARNING (2 warnings)
- Architecture: ✅ PASS

Action Required: Fix 2 ESLint warnings
```

## Implementation Guidelines

### When to Execute
- **ALWAYS** after `create` command completion
- **ALWAYS** after `recheck` command completion
- Before displaying "Command completed successfully" message

### Data Sources
- **Coverage**: `ng test --code-coverage`
- **Duplication**: ESLint duplicate detection or SonarJS
- **Build**: `ng build --stats-json`
- **Performance**: Lighthouse CLI or Angular DevKit
- **Version**: package.json version field

### Status Indicators
- ✅ **PASS**: Requirement met
- ❌ **FAIL**: Requirement not met, blocking
- ⚠️ **WARNING**: Close to threshold, attention needed

### Color Coding (if supported)
- **Green**: PASS status
- **Red**: FAIL status
- **Yellow**: WARNING status
- **Blue**: Information headers

## Failure Thresholds

### Blocking Failures (Must Fix)
- Code Coverage < 80%
- Code Duplication ≥ 5%
- Build failures
- Bundle size ≥ 5MB
- TypeScript compilation errors

### Warning Thresholds
- Code Coverage 80-85%
- Code Duplication 4-4.5%
- Bundle size 3-4.5MB
- ESLint warnings > 0
- Performance score < 90

## Output Format

```
================================================
🚀 CMX FRONTEND POST-HOOK QUALITY REPORT
================================================

📋 PROJECT: policy-web-frontend
Version: 1.0.0 | Angular: 17.0.0 | Build: #1234

📊 COVERAGE: 85.3% ✅  🔄 DUPLICATION: 3.8% ✅  📦 BUNDLE: 2.1 MB ✅

🏗️ ARCHITECTURE: ✅ PASS
⚡ PERFORMANCE: 92/100 ✅
🧪 TESTS: 156/156 ✅ PASS

📈 OVERALL STATUS: ⚠️ WARNING (2 ESLint warnings)

================================================
Command completed with warnings! ⚠️
================================================
```

## Angular-Specific Validations

### Component Analysis
- Standalone component usage percentage
- OnPush change detection adoption
- Component size and complexity metrics

### Module Structure
- Lazy loading implementation
- Feature module organization
- Shared module optimization

### RxJS Usage
- Observable subscription patterns
- Memory leak prevention
- Async pipe usage

### Accessibility
- ARIA attributes coverage
- Keyboard navigation support
- Color contrast compliance

## Error Handling
- If Angular CLI commands fail, display "BUILD FAILED" status
- If metrics cannot be calculated, display "UNKNOWN" with warning
- If tools are missing, display appropriate error message
- Always show project version even if other metrics fail

---

**Note**: This post-hook ensures every Angular frontend project meets the quality standards defined in frontend-architecture.md before completion.