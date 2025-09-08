# Post-Hook Backend Quality Report

## Overview
This post-hook must execute after every backend command (create/recheck) and display comprehensive quality metrics to ensure compliance with [tech/backend-architecture.md](../tech/backend-architecture.md) requirements.

## Mandatory Display Requirements

### 1. Project Version Information
```
📋 PROJECT INFORMATION
Version: 1.0.0
Build Date: 2024-12-08 15:30:45
Environment: Development
Build Number: #1234
```

### 2. Code Coverage Report
```
📊 CODE COVERAGE
Overall Coverage: 92.5% ✅ (Target: ≥90%)
Line Coverage: 94.2% ✅
Branch Coverage: 89.8% ❌ (Target: ≥90%)
Function Coverage: 96.1% ✅

By Layer:
- Controllers: 95.2% ✅
- Handlers: 91.8% ✅
- Managers: 93.4% ✅
- Services: 88.7% ❌
```

### 3. Code Duplication Analysis
```
🔄 CODE DUPLICATION
Total Duplication: 7.2% ✅ (Target: <10%)
Duplicated Lines: 324 / 4,500
Duplicated Blocks: 12
Largest Clone: 18 lines in UserService.cs & AdminService.cs

Duplication by Module:
- FNOL: 5.1% ✅
- Dispatcher: 8.9% ✅
- Surveyor: 9.2% ✅
```

### 4. Architecture Compliance
```
🏗️ ARCHITECTURE COMPLIANCE
Layer Separation: ✅ PASS
Controller → Handler → Manager → Service: ✅ PASS
MediatR Usage: ✅ PASS (100% controllers use MediatR)
FluentValidation: ✅ PASS (No if-else validation found)
Dependency Injection: ✅ PASS
```

### 5. Quality Metrics Summary
```
📈 QUALITY SUMMARY
Overall Status: ⚠️ WARNING
- Code Coverage: ✅ PASS (92.5% ≥ 90%)
- Code Duplication: ✅ PASS (7.2% < 10%)
- SonarLint Warnings: ❌ FAIL (3 warnings found)
- Architecture: ✅ PASS
- Tests: ✅ PASS (All 247 tests passed)

Action Required: Fix 3 SonarLint warnings and improve branch coverage
```

## Implementation Guidelines

### When to Execute
- **ALWAYS** after `create` command completion
- **ALWAYS** after `recheck` command completion
- Before displaying "Command completed successfully" message

### Data Sources
- **Coverage**: dotnet test --collect:"XPlat Code Coverage"
- **Duplication**: SonarQube duplication metrics or similar tools
- **Version**: AssemblyInfo.cs or project file version
- **Architecture**: Static code analysis validation

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
- Code Coverage < 90%
- Code Duplication ≥ 10%
- Architecture violations detected
- Test failures

### Warning Thresholds
- Code Coverage 90-92%
- Code Duplication 8-9.5%
- SonarLint warnings > 0

## Output Format

```
================================================
🚀 CMX POST-HOOK QUALITY REPORT
================================================

📋 PROJECT: claim-processor-backend
Version: 1.0.0 | Build: #1234 | Date: 2024-12-08 15:30:45

📊 COVERAGE: 92.5% ✅  🔄 DUPLICATION: 7.2% ✅  

🏗️ ARCHITECTURE: ✅ PASS
🧪 TESTS: 247/247 ✅ PASS

📈 OVERALL STATUS: ✅ SUCCESS

================================================
Command completed successfully! 🎉
================================================
```

## Error Handling
- If metrics cannot be calculated, display "UNKNOWN" with warning
- If tools are missing, display appropriate error message
- Always show project version even if other metrics fail

---

**Note**: This post-hook ensures every backend project meets the quality standards defined in backend-architecture.md before completion.