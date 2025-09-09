---
description: Create an Agent OS tasks list from an approved feature spec
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# Spec Creation Rules

## Overview

With the user's approval, proceed to creating a tasks list based on the current feature spec. Tasks will be created in both local tasks.md file and synchronized to Jira using Atlassian MCP with proper dependency management to ensure dependent tasks cannot be picked up by other developers until prerequisites are complete.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<jira_integration>
  <mcp_tool>Atlassian MCP Server</mcp_tool>
  <purpose>Create and manage Jira tasks with dependency tracking</purpose>
  
  <dependency_management>
    <blocking_mechanism>
      - Use Jira "blocks/is blocked by" links
      - Set task status to "Blocked" for dependent tasks
      - Add clear dependency labels
      - Include "DO NOT START - Depends on [TASK-ID]" in description
    </blocking_mechanism>
    
    <dependency_rules>
      - Parent tasks block all their subtasks
      - Test tasks (x.1) block implementation tasks (x.2-x.n)
      - Infrastructure tasks block feature tasks
      - API tasks block UI tasks that consume them
      - Database schema tasks block data access tasks
    </dependency_rules>
  </dependency_management>
  
  <task_fields>
    - Type: Task/Sub-task
    - Priority: Based on dependency chain
    - Labels: [TDD, Dependencies, Feature-Name]
    - Components: [Frontend/Backend/Infrastructure]
    - Story Points: Estimated complexity
    - Description: Include dependency information
    - Acceptance Criteria: Test requirements
  </task_fields>
</jira_integration>

<process_flow>

<step number="1" subagent="file-creator" name="create_tasks">

### Step 1: Create tasks.md

Use the file-creator subagent to create file: tasks.md inside of the current feature's spec folder.

<file_template>
  <header>
    # Spec Tasks
  </header>
</file_template>

<task_structure>
  <major_tasks>
    - count: 1-5
    - format: numbered checklist
    - grouping: by feature or component
  </major_tasks>
  <subtasks>
    - count: up to 8 per major task
    - format: decimal notation (1.1, 1.2)
    - first_subtask: typically write tests
    - last_subtask: verify all tests pass
  </subtasks>
</task_structure>

<task_template>
  ## Tasks

  - [ ] 1. [MAJOR_TASK_DESCRIPTION]
    - [ ] 1.1 Write tests for [COMPONENT]
    - [ ] 1.2 [IMPLEMENTATION_STEP]
    - [ ] 1.3 [IMPLEMENTATION_STEP]
    - [ ] 1.4 Verify all tests pass

  - [ ] 2. [MAJOR_TASK_DESCRIPTION]
    - [ ] 2.1 Write tests for [COMPONENT]
    - [ ] 2.2 [IMPLEMENTATION_STEP]
</task_template>

<ordering_principles>
  - Consider technical dependencies
  - Follow TDD approach
  - Group related functionality
  - Build incrementally
</ordering_principles>

</step>

<step number="2" name="create_jira_tasks">

### Step 2: Create Jira Tasks with Dependencies

Use Atlassian MCP to create corresponding Jira tasks with proper dependency management.

<jira_task_creation>
  <epic_creation>
    ACTION: Create Epic for the feature
    FIELDS:
      - Summary: [Feature Name]
      - Description: Link to spec and tasks.md
      - Labels: [Feature, TDD, Epic]
  </epic_creation>
  
  <parent_task_creation>
    FOR each major task in tasks.md:
      ACTION: Create Jira Story/Task
      FIELDS:
        - Summary: [Major Task Description]
        - Parent: Link to Epic
        - Status: "To Do" (or "Blocked" if has dependencies)
        - Description: |
          Task from tasks.md
          Dependencies: [LIST DEPENDENCIES]
          DO NOT START if dependencies exist
        - Labels: [TDD, Parent-Task]
  </parent_task_creation>
  
  <subtask_creation>
    FOR each subtask (x.1, x.2, etc):
      ACTION: Create Jira Sub-task
      FIELDS:
        - Parent: Corresponding major task
        - Summary: [Subtask Description]
        - Status: "Blocked" (except for x.1 test tasks)
        - Description: |
          DEPENDENCY: Must complete [previous subtask] first
          DO NOT START - Depends on [TASK-ID]
          
          TDD Requirement:
          - Tests (x.1) must be written FIRST
          - Implementation follows after tests
        - Labels: [TDD, Subtask, Blocked]
  </subtask_creation>
  
  <dependency_linking>
    ACTION: Create blocking links between tasks
    RULES:
      - Task x.1 (tests) blocks x.2-x.n (implementation)
      - Each subtask blocks the next (x.2 blocks x.3)
      - Infrastructure tasks block feature tasks
      - Backend API tasks block frontend tasks
    
    JIRA_LINK_TYPES:
      - "blocks" / "is blocked by"
      - "must be done before" / "must be done after"
  </dependency_linking>
  
  <workflow_restrictions>
    SET_RULES:
      - Subtasks cannot transition to "In Progress" until blocking tasks are "Done"
      - Add validation: "Blocker resolution required"
      - Add comment: "This task has dependencies - check blocking tasks"
  </workflow_restrictions>
</jira_task_creation>

<dependency_visualization>
  <create_dependency_report>
    Generate visual dependency graph showing:
    - Task hierarchy
    - Blocking relationships
    - Critical path
    - Available tasks (no blockers)
  </create_dependency_report>
  
  <add_to_description>
    Include in each task description:
    ```
    === DEPENDENCIES ===
    Blocked by: [TASK-IDs]
    Blocks: [TASK-IDs]
    
    ⚠️ DO NOT START until all blocking tasks are complete
    ⚠️ This ensures TDD approach and proper integration
    ```
  </add_to_description>
</dependency_visualization>

<instructions>
  ACTION: Use Atlassian MCP to create all Jira tasks
  ENFORCE: Dependency chains prevent out-of-order execution
  CRITICAL: Test tasks (x.1) must never be blocked
  BLOCK: Implementation tasks until tests exist
  COMMUNICATE: Clear dependency warnings in descriptions
</instructions>

</step>

<step number="3" name="execution_readiness">

### Step 3: Execution Readiness Check

Evaluate readiness to begin implementation by presenting the first task summary, Jira task IDs, and requesting user confirmation to proceed.

<readiness_summary>
  <present_to_user>
    - Spec name and description
    - First task summary from tasks.md
    - Jira Epic and Task IDs created
    - Dependency chain visualization
    - Estimated complexity/scope
    - Key deliverables for task 1
    - Available tasks (no blockers)
  </present_to_user>
</readiness_summary>

<execution_prompt>
  PROMPT: "The spec planning is complete and Jira tasks have been created. 

  **Epic:** [EPIC-ID] - [Feature Name]
  
  **First Task:** [FIRST_TASK_TITLE]
  **Jira ID:** [TASK-ID]
  **Status:** Ready to Start (no blockers)
  
  [BRIEF_DESCRIPTION_OF_TASK_1_AND_SUBTASKS]
  
  **Dependency Status:**
  - ✅ No blocking dependencies
  - ⚠️ This task blocks: [List of dependent task IDs]
  - 📝 Subtask 1.1 (Write tests) must be completed first per TDD
  
  Would you like me to proceed with implementing Task 1? I will follow TDD approach, starting with tests, and will update both local tasks.md and Jira as I progress.

  Type 'yes' to proceed with Task 1, or let me know if you'd like to review or modify the plan first."
</execution_prompt>

<execution_flow>
  IF user_confirms_yes:
    REFERENCE: @.agent-os/instructions/core/execute-tasks.md
    FOCUS: Only Task 1 and its subtasks
    JIRA_UPDATES:
      - Transition task to "In Progress"
      - Add comment: "Development started - following TDD approach"
      - Update subtasks as completed
      - Unblock dependent tasks when prerequisites done
    CONSTRAINT: Do not proceed to additional tasks without explicit user request
  ELSE:
    WAIT: For user clarification or modifications
</execution_flow>

</step>

</process_flow>

<parallel_work_prevention>
  <developer_coordination>
    CRITICAL: Prevent multiple developers from working on dependent tasks
    
    <blocking_strategies>
      - Jira Status: Keep dependent tasks in "Blocked" status
      - Clear Warnings: Add "DO NOT START" to task titles
      - Assignee Rules: Don't assign blocked tasks
      - Daily Standup: Review dependency status
      - Auto-Comments: Add blocker notifications
    </blocking_strategies>
    
    <auto_unblocking>
      When a task is completed:
        - Automatically transition dependent tasks from "Blocked" to "To Do"
        - Send notifications to team about newly available tasks
        - Update dependency visualization
        - Add comment: "Blocker resolved - task now available"
    </auto_unblocking>
    
    <tdd_enforcement_for_team>
      - Test tasks (x.1) are ALWAYS available first
      - Implementation tasks remain blocked until tests exist
      - This ensures entire team follows TDD approach
      - Prevents shortcuts or skipping test-first development
    </tdd_enforcement_for_team>
  </developer_coordination>
</parallel_work_prevention>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
