---
description: Spec Creation Rules for Agent OS
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# Spec Creation Rules

## Overview

Generate detailed feature specifications aligned with product roadmap and mission. CRITICAL: This process requires a Product Requirements Document (PRD) to exist before proceeding with spec creation.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<prd_validation>
  <mandatory_check>
    CRITICAL: Check for docs/prd.md existence in current directory
    
    ACTION: Verify docs/prd.md file exists
    IF docs/prd.md NOT found:
      STOP: Display error message
      ERROR: "❌ PREREQUISITE FAILED: docs/prd.md not found
      
      This command requires a Product Requirements Document (PRD) to exist at:
      📁 docs/prd.md
      
      The PRD should contain:
      - Product vision and objectives
      - User personas and use cases  
      - Business requirements and constraints
      - Success metrics and KPIs
      - Priority and timeline information
      
      Please create docs/prd.md first, then run /create-spec again."
      HALT: Do not proceed with spec creation
    ELSE:
      CONTINUE: Proceed with spec creation process
  </mandatory_check>
  
  <prd_integration>
    Once docs/prd.md confirmed:
    - Reference PRD for product alignment
    - Extract relevant requirements for spec
    - Ensure spec supports PRD objectives
    - Validate scope against PRD priorities
  </prd_integration>
</prd_validation>

<process_flow>

<step number="1" subagent="context-fetcher" name="prd_analysis">

### Step 1: PRD Analysis

Use the context-fetcher subagent to read and analyze docs/prd.md to understand product requirements and context before spec creation.

<prd_reading>
  ACTION: Read docs/prd.md file
  ANALYZE:
    - Product vision and objectives
    - Target user personas
    - Business requirements
    - Success metrics and KPIs
    - Priority features and timeline
    - Technical constraints
  
  EXTRACT:
    - Relevant requirements for current spec
    - Alignment with product roadmap
    - Priority level of requested feature
    - Success criteria and metrics
</prd_reading>

<alignment_validation>
  ENSURE spec_request aligns with:
    - Product vision from PRD
    - Target user needs identified in PRD
    - Business objectives outlined in PRD
    - Priority ranking in PRD roadmap
  
  IF alignment_issues_found:
    FLAG potential conflicts
    RECOMMEND adjustments to spec scope
    SUGGEST alternative approaches
</alignment_validation>

<instructions>
  ACTION: Use context-fetcher to read docs/prd.md
  ANALYZE: Extract relevant product context
  VALIDATE: Ensure spec request aligns with PRD
  STORE: Key PRD insights for spec creation
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="spec_initiation">

### Step 2: Spec Initiation

Use the context-fetcher subagent to identify spec initiation method by either finding the next uncompleted roadmap item when user asks "what's next?" or accepting a specific spec idea from the user.

<option_a_flow>
  <trigger_phrases>
    - "what's next?"
  </trigger_phrases>
  <actions>
    1. CHECK @.agent-os/product/roadmap.md
    2. FIND next uncompleted item
    3. SUGGEST item to user
    4. WAIT for approval
  </actions>
</option_a_flow>

<option_b_flow>
  <trigger>user describes specific spec idea</trigger>
  <accept>any format, length, or detail level</accept>
  <proceed>to context gathering</proceed>
</option_b_flow>

</step>

<step number="3" subagent="context-fetcher" name="context_gathering">

### Step 3: Context Gathering (Conditional)

Use the context-fetcher subagent to read @.agent-os/product/mission-lite.md and @.agent-os/product/tech-stack.md only if not already in context to ensure minimal context for spec alignment.

<conditional_logic>
  IF both mission-lite.md AND tech-stack.md already read in current context:
    SKIP this entire step
    PROCEED to step 3
  ELSE:
    READ only files not already in context:
      - mission-lite.md (if not in context)
      - tech-stack.md (if not in context)
    CONTINUE with context analysis
</conditional_logic>

<context_analysis>
  <mission_lite>core product purpose and value</mission_lite>
  <tech_stack>technical requirements</tech_stack>
</context_analysis>

</step>

<step number="4" subagent="context-fetcher" name="requirements_clarification">

### Step 4: Requirements Clarification

Use the context-fetcher subagent to clarify scope boundaries and technical considerations by asking numbered questions as needed to ensure clear requirements before proceeding.

<clarification_areas>
  <scope>
    - in_scope: what is included
    - out_of_scope: what is excluded (optional)
  </scope>
  <technical>
    - functionality specifics
    - UI/UX requirements
    - integration points
  </technical>
</clarification_areas>

<decision_tree>
  IF clarification_needed:
    ASK numbered_questions
    WAIT for_user_response
  ELSE:
    PROCEED to_date_determination
</decision_tree>

</step>

<step number="5" subagent="date-checker" name="date_determination">

### Step 5: Date Determination

Use the date-checker subagent to determine the current date in YYYY-MM-DD format for folder naming. The subagent will output today's date which will be used in subsequent steps.

<subagent_output>
  The date-checker subagent will provide the current date in YYYY-MM-DD format at the end of its response. Store this date for use in folder naming in step 5.
</subagent_output>

</step>

<step number="6" subagent="file-creator" name="spec_folder_creation">

### Step 6: Spec Folder Creation

Use the file-creator subagent to create directory: .agent-os/specs/YYYY-MM-DD-spec-name/ using the date from step 4.

Use kebab-case for spec name. Maximum 5 words in name.

<folder_naming>
  <format>YYYY-MM-DD-spec-name</format>
  <date>use stored date from step 4</date>
  <name_constraints>
    - max_words: 5
    - style: kebab-case
    - descriptive: true
  </name_constraints>
</folder_naming>

<example_names>
  - 2025-03-15-password-reset-flow
  - 2025-03-16-user-profile-dashboard
  - 2025-03-17-api-rate-limiting
</example_names>

</step>

<step number="7" subagent="file-creator" name="create_spec_md">

### Step 7: Create spec.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec.md using this template:

<file_template>
  <header>
    # Spec Requirements Document

    > Spec: [SPEC_NAME]
    > Created: [CURRENT_DATE]
    > PRD Reference: docs/prd.md
  </header>
  <required_sections>
    - Overview
    - User Stories
    - Spec Scope
    - Out of Scope
    - Expected Deliverable
  </required_sections>
</file_template>

<section name="overview">
  <template>
    ## Overview

    [1-2_SENTENCE_GOAL_AND_OBJECTIVE_ALIGNED_WITH_PRD]
    
    **PRD Alignment:** This spec supports [SPECIFIC_PRD_OBJECTIVE] outlined in docs/prd.md.
  </template>
  <constraints>
    - length: 1-2 sentences for main goal
    - content: goal and objective aligned with PRD
    - must_include: reference to specific PRD alignment
  </constraints>
  <example>
    Implement a secure password reset functionality that allows users to regain account access through email verification. This feature will reduce support ticket volume and improve user experience by providing self-service account recovery.
    
    **PRD Alignment:** This spec supports the "Reduce Customer Support Load" objective outlined in docs/prd.md.
  </example>
</section>

<section name="user_stories">
  <template>
    ## User Stories

    ### [STORY_TITLE]

    As a [USER_TYPE], I want to [ACTION], so that [BENEFIT].

    [DETAILED_WORKFLOW_DESCRIPTION]
  </template>
  <constraints>
    - count: 1-3 stories
    - include: workflow and problem solved
    - format: title + story + details
  </constraints>
</section>

<section name="spec_scope">
  <template>
    ## Spec Scope

    1. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
    2. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
  </template>
  <constraints>
    - count: 1-5 features
    - format: numbered list
    - description: one sentence each
  </constraints>
</section>

<section name="out_of_scope">
  <template>
    ## Out of Scope

    - [EXCLUDED_FUNCTIONALITY_1]
    - [EXCLUDED_FUNCTIONALITY_2]
  </template>
  <purpose>explicitly exclude functionalities</purpose>
</section>

<section name="expected_deliverable">
  <template>
    ## Expected Deliverable

    1. [TESTABLE_OUTCOME_1]
    2. [TESTABLE_OUTCOME_2]
  </template>
  <constraints>
    - count: 1-3 expectations
    - focus: browser-testable outcomes
  </constraints>
</section>

</step>

<step number="8" subagent="file-creator" name="create_spec_lite_md">

### Step 8: Create spec-lite.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md for the purpose of establishing a condensed spec for efficient AI context usage.

<file_template>
  <header>
    # Spec Summary (Lite)
  </header>
</file_template>

<content_structure>
  <spec_summary>
    - source: Step 6 spec.md overview section
    - length: 1-3 sentences
    - content: core goal and objective of the feature
  </spec_summary>
</content_structure>

<content_template>
  [1-3_SENTENCES_SUMMARIZING_SPEC_GOAL_AND_OBJECTIVE]
</content_template>

<example>
  Implement secure password reset via email verification to reduce support tickets and enable self-service account recovery. Users can request a reset link, receive a time-limited token via email, and set a new password following security best practices.
</example>

</step>

<step number="9" subagent="file-creator" name="create_technical_spec">

### Step 9: Create Technical Specification

Use the file-creator subagent to create the file: sub-specs/technical-spec.md using this template:

<file_template>
  <header>
    # Technical Specification

    This is the technical specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<spec_sections>
  <technical_requirements>
    - functionality details
    - UI/UX specifications
    - integration requirements
    - performance criteria
  </technical_requirements>
  <external_dependencies_conditional>
    - only include if new dependencies needed
    - new libraries/packages
    - justification for each
    - version requirements
  </external_dependencies_conditional>
</spec_sections>

<example_template>
  ## Technical Requirements

  - [SPECIFIC_TECHNICAL_REQUIREMENT]
  - [SPECIFIC_TECHNICAL_REQUIREMENT]

  ## External Dependencies (Conditional)

  [ONLY_IF_NEW_DEPENDENCIES_NEEDED]
  - **[LIBRARY_NAME]** - [PURPOSE]
  - **Justification:** [REASON_FOR_INCLUSION]
</example_template>

<conditional_logic>
  IF spec_requires_new_external_dependencies:
    INCLUDE "External Dependencies" section
  ELSE:
    OMIT section entirely
</conditional_logic>

</step>

<step number="10" subagent="file-creator" name="create_database_schema">

### Step 10: Create Database Schema (Conditional)

Use the file-creator subagent to create the file: sub-specs/database-schema.md ONLY IF database changes needed for this task.

<decision_tree>
  IF spec_requires_database_changes:
    CREATE sub-specs/database-schema.md
  ELSE:
    SKIP this_step
</decision_tree>

<file_template>
  <header>
    # Database Schema

    This is the database schema implementation for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<schema_sections>
  <changes>
    - new tables
    - new columns
    - modifications
    - migrations
  </changes>
  <specifications>
    - exact SQL or migration syntax
    - indexes and constraints
    - foreign key relationships
  </specifications>
  <rationale>
    - reason for each change
    - performance considerations
    - data integrity rules
  </rationale>
</schema_sections>

</step>

<step number="11" subagent="file-creator" name="create_api_spec">

### Step 11: Create API Specification (Conditional)

Use the file-creator subagent to create file: sub-specs/api-spec.md ONLY IF API changes needed.

<decision_tree>
  IF spec_requires_api_changes:
    CREATE sub-specs/api-spec.md
  ELSE:
    SKIP this_step
</decision_tree>

<file_template>
  <header>
    # API Specification

    This is the API specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<api_sections>
  <routes>
    - HTTP method
    - endpoint path
    - parameters
    - response format
  </routes>
  <controllers>
    - action names
    - business logic
    - error handling
  </controllers>
  <purpose>
    - endpoint rationale
    - integration with features
  </purpose>
</api_sections>

<endpoint_template>
  ## Endpoints

  ### [HTTP_METHOD] [ENDPOINT_PATH]

  **Purpose:** [DESCRIPTION]
  **Parameters:** [LIST]
  **Response:** [FORMAT]
  **Errors:** [POSSIBLE_ERRORS]
</endpoint_template>

</step>

<step number="12" name="user_review">

### Step 12: User Review

Request user review of spec.md and all sub-specs files, waiting for approval or revision requests.

<review_request>
  I've created the spec documentation with PRD alignment:

  - Spec Requirements: @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  - Spec Summary: @.agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md
  - Technical Spec: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/technical-spec.md
  [LIST_OTHER_CREATED_SPECS]
  
  **PRD Alignment Verified:**
  ✅ Spec aligns with product vision from docs/prd.md
  ✅ Features support identified business objectives
  ✅ Success criteria mapped to PRD metrics
  ✅ Priority matches PRD roadmap

  Please review and let me know if any changes are needed.

  When you're ready, run the /create-tasks command to have me build the tasks checklist from this spec.
</review_request>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
