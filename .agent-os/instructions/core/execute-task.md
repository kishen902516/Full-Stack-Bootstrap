---
description: Rules to execute a task and its sub-tasks using Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

Execute a specific task along with its sub-tasks systematically following a strict Test-Driven Development (TDD) workflow. All features MUST be developed using TDD approach and ALL tests (unit, architecture, integration) MUST pass before marking the task complete.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<tdd_enforcement>
  <mandatory_approach>
    CRITICAL: ALL development MUST follow Test-Driven Development (TDD)
    NEVER write production code without tests written first
    ALWAYS follow RED-GREEN-REFACTOR cycle for every feature
  </mandatory_approach>
  
  <tdd_workflow>
    1. RED: Write failing test(s) for the feature
    2. GREEN: Write minimal code to make test(s) pass
    3. REFACTOR: Improve code while keeping tests green
    4. REPEAT: Continue cycle for each new functionality
  </tdd_workflow>
  
  <test_requirements>
    - Unit tests (Jest): MUST be written for all business logic and components
    - Integration tests (Jest): MUST verify component interactions and API calls
    - E2E tests (Playwright): MUST validate critical user journeys
    - Architecture tests: MUST validate layer dependencies and module boundaries
    - ALL tests MUST pass before task completion
  </test_requirements>
  
  <frontend_testing_stack>
    - Jest: Unit and integration testing framework
    - Playwright: End-to-end testing for user workflows
    - Testing Library: Component testing utilities
    - Coverage: Minimum 80% code coverage required
  </frontend_testing_stack>
</tdd_enforcement>

<process_flow>

<step number="1" name="task_understanding">

### Step 1: Task Understanding

Read and analyze the given parent task and all its sub-tasks from tasks.md to gain complete understanding of what needs to be built.

<task_analysis>
  <read_from_tasks_md>
    - Parent task description
    - All sub-task descriptions
    - Task dependencies
    - Expected outcomes
  </read_from_tasks_md>
</task_analysis>

<instructions>
  ACTION: Read the specific parent task and all its sub-tasks
  ANALYZE: Full scope of implementation required
  UNDERSTAND: Dependencies and expected deliverables
  NOTE: Test requirements for each sub-task
</instructions>

</step>

<step number="2" name="technical_spec_review">

### Step 2: Technical Specification Review

Search and extract relevant sections from technical-spec.md to understand the technical implementation approach for this task.

<selective_reading>
  <search_technical_spec>
    FIND sections in technical-spec.md related to:
    - Current task functionality
    - Implementation approach for this feature
    - Integration requirements
    - Performance criteria
  </search_technical_spec>
</selective_reading>

<instructions>
  ACTION: Search technical-spec.md for task-relevant sections
  EXTRACT: Only implementation details for current task
  SKIP: Unrelated technical specifications
  FOCUS: Technical approach for this specific feature
</instructions>

</step>

<step number="3" subagent="context-fetcher" name="best_practices_review">

### Step 3: Best Practices Review

Use the context-fetcher subagent to retrieve relevant sections from @.agent-os/standards/best-practices.md that apply to the current task's technology stack and feature type.

<selective_reading>
  <search_best_practices>
    FIND sections relevant to:
    - Task's technology stack
    - Feature type being implemented
    - Testing approaches needed
    - Code organization patterns
  </search_best_practices>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find best practices sections relevant to:
            - Task's technology stack: [CURRENT_TECH]
            - Feature type: [CURRENT_FEATURE_TYPE]
            - Testing approaches needed
            - Code organization patterns"
  PROCESS: Returned best practices
  APPLY: Relevant patterns to implementation
</instructions>

</step>

<step number="4" subagent="context-fetcher" name="code_style_review">

### Step 4: Code Style Review

Use the context-fetcher subagent to retrieve relevant code style rules from @.agent-os/standards/code-style.md for the languages and file types being used in this task.

<selective_reading>
  <search_code_style>
    FIND style rules for:
    - Languages used in this task
    - File types being modified
    - Component patterns being implemented
    - Testing style guidelines
  </search_code_style>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find code style rules for:
            - Languages: [LANGUAGES_IN_TASK]
            - File types: [FILE_TYPES_BEING_MODIFIED]
            - Component patterns: [PATTERNS_BEING_IMPLEMENTED]
            - Testing style guidelines"
  PROCESS: Returned style rules
  APPLY: Relevant formatting and patterns
</instructions>

</step>

<step number="5" name="task_execution">

### Step 5: Task and Sub-task Execution (TDD Approach)

Execute the parent task and all sub-tasks in order using STRICT Test-Driven Development (TDD) approach. MUST follow RED-GREEN-REFACTOR cycle for every feature.

<tdd_cycle>
  <red_phase>Write failing tests FIRST before any implementation</red_phase>
  <green_phase>Write minimal code to make tests pass</green_phase>
  <refactor_phase>Improve code while keeping tests green</refactor_phase>
</tdd_cycle>

<typical_task_structure>
  <first_subtask>Write tests for [feature] - MUST be done BEFORE implementation</first_subtask>
  <middle_subtasks>Implementation steps following TDD cycle</middle_subtasks>
  <final_subtask>Verify all tests pass</final_subtask>
</typical_task_structure>

<execution_order>
  <subtask_1_tests>
    IF sub-task 1 is "Write tests for [feature]":
      Frontend:
        - Write Jest unit tests for components and services
        - Write Jest integration tests for component interactions
        - Write Playwright E2E tests for user workflows
        - Use npm run test:watch for TDD workflow
        - Ensure all tests fail initially (RED phase)
      Backend:
        - Write unit tests for business logic
        - Write integration tests for API endpoints
        - Use dotnet watch test for TDD workflow
      - Run tests to ensure they fail appropriately
      - Mark sub-task 1 complete
  </subtask_1_tests>

  <middle_subtasks_implementation>
    FOR each implementation sub-task (2 through n-1):
      - Implement the specific functionality
      - Make relevant tests pass
      - Update any adjacent/related tests if needed
      - Refactor while keeping tests green
      - Mark sub-task complete
  </middle_subtasks_implementation>

  <final_subtask_verification>
    IF final sub-task is "Verify all tests pass":
      - Run entire test suite
      - Fix any remaining failures
      - Ensure no regressions
      - Mark final sub-task complete
  </final_subtask_verification>
</execution_order>

<test_management>
  <new_tests>
    - Written in first sub-task
    - Cover all aspects of parent feature
    - Include edge cases and error handling
  </new_tests>
  <test_updates>
    - Made during implementation sub-tasks
    - Update expectations for changed behavior
    - Maintain backward compatibility
  </test_updates>
</test_management>

<instructions>
  ACTION: Execute sub-tasks in their defined order
  ENFORCE: TDD - Write tests BEFORE implementation (RED phase)
  RECOGNIZE: First sub-task typically writes all tests
  IMPLEMENT: Middle sub-tasks build functionality (GREEN phase)
  REFACTOR: Improve code quality while keeping tests green
  VERIFY: Final sub-task ensures all tests pass
  UPDATE: Mark each sub-task complete as finished
  CRITICAL: NEVER write implementation code before tests
</instructions>

</step>

<step number="6" subagent="test-runner" name="task_test_verification">

### Step 6: Task-Specific Test Verification

Use the test-runner subagent to run and verify only the tests specific to this parent task (not the full test suite) to ensure the feature is working correctly.

<focused_test_execution>
  <run_only>
    - All new tests written for this parent task
    - All tests updated during this task
    - Tests directly related to this feature
  </run_only>
  <skip>
    - Full test suite (done later in execute-tasks.md)
    - Unrelated test files
  </skip>
</focused_test_execution>

<final_verification>
  IF any test failures:
    - Debug and fix the specific issue
    - Re-run only the failed tests
  ELSE:
    - Confirm all task tests passing
    - Ready to proceed
</final_verification>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run tests for [this parent task's test files]"
  WAIT: For test-runner analysis
  PROCESS: Returned failure information
  VERIFY: 100% pass rate for task-specific tests
  CONFIRM: This feature's tests are complete
</instructions>

</step>

<step number="7" name="comprehensive_test_verification">

### Step 7: Comprehensive Test Verification (MANDATORY)

Once the feature is completed, MUST run ALL test suites to ensure no regressions and maintain code quality. ALL tests MUST pass before proceeding.

<test_suite_execution>
  <unit_tests>
    <frontend>
      FRAMEWORK: Jest
      ACTION: cd app-frontend && npm test
      WATCH_MODE: cd app-frontend && npm run test:watch (for TDD)
      REQUIREMENT: 100% pass rate
      COVERAGE: Minimum 80% code coverage
      VALIDATES: Component logic, services, utilities
    </frontend>
    <backend>
      ACTION: dotnet test ./app-api/tests/UnitTests --configuration Release
      WATCH_MODE: dotnet watch test ./app-api/tests/UnitTests (for TDD)
      REQUIREMENT: 100% pass rate
      COVERAGE: Minimum 80% threshold
    </backend>
  </unit_tests>

  <integration_tests>
    <frontend>
      FRAMEWORK: Jest with integration setup
      ACTION: cd app-frontend && npm run test:integration
      REQUIREMENT: 100% pass rate
      VALIDATES: Component interactions, state management, API calls
      TESTS: Service integrations, store interactions, routing
    </frontend>
    <backend>
      ACTION: dotnet test ./app-api/tests/IntegrationTests
      REQUIREMENT: 100% pass rate
      VALIDATES: Component interactions and data flow
    </backend>
  </integration_tests>

  <e2e_tests>
    <frontend>
      FRAMEWORK: Playwright
      ACTION: cd app-frontend && npm run e2e
      REPORT: cd app-frontend && npm run e2e:report
      REQUIREMENT: All user journeys must pass
      VALIDATES: Complete user workflows and UI interactions
      COVERAGE: Critical user paths and scenarios
    </frontend>
  </e2e_tests>

  <architecture_tests>
    <frontend>
      ACTION: cd app-frontend && npm run arch:check
      REQUIREMENT: All architecture rules must pass
      VALIDATES: Module boundaries and dependencies
    </frontend>
    <backend>
      ACTION: dotnet test ./app-api/tests/ArchitectureTests
      REQUIREMENT: All layer dependencies validated
      VALIDATES: Clean Architecture compliance
    </backend>
  </architecture_tests>
</test_suite_execution>

<test_pyramid_compliance>
  ACTION: node tools/metrics/check-pyramid.js
  REQUIREMENTS:
    - Unit tests: 70-85% of total tests
    - Integration tests: 10-25% of total tests
    - E2E tests: 5-10% of total tests
</test_pyramid_compliance>

<failure_handling>
  IF any test fails:
    - STOP immediately
    - DEBUG the failure using:
      * Jest: npm run test:watch (for unit/integration)
      * Playwright: npm run e2e --debug
      * .NET: dotnet watch test
    - FIX the issue following TDD approach
    - RE-RUN all tests from the beginning:
      * Frontend: npm test && npm run test:integration && npm run e2e
      * Backend: dotnet test
    - REPEAT until all tests pass
  
  MAXIMUM_ATTEMPTS: 5
  IF still failing after 5 attempts:
    - DOCUMENT the blocking issue
    - ADD ⚠️ emoji to task in tasks.md
    - PROVIDE detailed failure analysis
</failure_handling>

<instructions>
  ACTION: Run ALL test suites in sequence
  CRITICAL: All tests MUST pass (unit, architecture, integration)
  ENFORCE: Test pyramid compliance
  VERIFY: No regressions introduced
  BLOCK: Do NOT proceed if any test fails
  FIX: Address all failures using TDD approach
</instructions>

</step>

<step number="8" name="task_status_updates">

### Step 8: Mark this task and sub-tasks complete (ONLY after all tests pass)

CRITICAL: Tasks can ONLY be marked complete after ALL tests (unit, architecture, integration) have passed successfully. In the tasks.md file, mark this task and its sub-tasks complete by updating each task checkbox to [x].

<update_format>
  <completed>- [x] Task description</completed>
  <incomplete>- [ ] Task description</incomplete>
  <blocked>
    - [ ] Task description
    ⚠️ Blocking issue: [DESCRIPTION]
  </blocked>
</update_format>

<blocking_criteria>
  <attempts>maximum 3 different approaches</attempts>
  <action>document blocking issue</action>
  <emoji>⚠️</emoji>
</blocking_criteria>

<instructions>
  ACTION: Update tasks.md ONLY after ALL tests pass
  PREREQUISITE: All unit, architecture, and integration tests MUST pass
  MARK: [x] for completed items only when tests are green
  DOCUMENT: Blocking issues with ⚠️ emoji
  LIMIT: 3 attempts before marking as blocked
  CRITICAL: NEVER mark task complete if any test is failing
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
