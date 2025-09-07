#!/bin/bash

# Generate CLAUDE.md and copy appropriate standards based on tech stack
# Author: AI Assistant
# Version: 2.1.0 - GitHub Repository Based

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR=".claude"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/kishen902516/Full-Stack-Bootstrap/initial-setup"
STANDARDS_BASE="$GITHUB_RAW_BASE/.chubbify/standards"
CORE_FILES_BASE="$GITHUB_RAW_BASE/.chubbify"
CLAUDE_MD_FILE="CLAUDE.md"
TEMP_DIR=".claude-temp"

# Tech stack options
declare -A FRONTEND_STACKS=(
    ["1"]="angular"
    ["2"]="react"
    ["3"]="vue"
    ["4"]="svelte"
    ["5"]="vanilla"
)

declare -A BACKEND_STACKS=(
    ["1"]="nodejs"
    ["2"]="dotnet"
    ["3"]="python"
    ["4"]="java"
    ["5"]="go"
)

declare -A DATABASE_STACKS=(
    ["1"]="postgresql"
    ["2"]="mongodb"
    ["3"]="mysql"
    ["4"]="redis"
    ["5"]="sqlite"
)

declare -A TESTING_FRAMEWORKS=(
    ["1"]="jest"
    ["2"]="jasmine"
    ["3"]="mocha"
    ["4"]="vitest"
    ["5"]="cypress"
)

# Function to check if curl or wget is available
check_download_tool() {
    if command -v curl &> /dev/null; then
        echo "curl"
    elif command -v wget &> /dev/null; then
        echo "wget"
    else
        echo -e "${RED}Error: Neither curl nor wget is installed.${NC}"
        echo "Please install curl or wget to continue."
        exit 1
    fi
}

# Function to download file from GitHub
download_file() {
    local url=$1
    local output=$2
    local tool=$(check_download_tool)
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output")"
    
    if [ "$tool" = "curl" ]; then
        curl -sL "$url" -o "$output" 2>/dev/null || return 1
    else
        wget -q "$url" -O "$output" 2>/dev/null || return 1
    fi
    
    # Check if file was downloaded and has content
    if [ -f "$output" ] && [ -s "$output" ]; then
        return 0
    else
        rm -f "$output" 2>/dev/null
        return 1
    fi
}

# Function to download setup script from GitHub to project directory
download_setup_script() {
    local target_dir=$1
    
    echo -e "\n${YELLOW}Downloading setup script from GitHub...${NC}"
    
    # Create setup directory if it doesn't exist
    mkdir -p "$target_dir/setup"
    
    # Download the main setup script
    local setup_script_url="$GITHUB_RAW_BASE/setup/setup.sh"
    if download_file "$setup_script_url" "$target_dir/setup/setup.sh"; then
        chmod +x "$target_dir/setup/setup.sh"
        echo -e "${GREEN}✓ Downloaded setup.sh to $target_dir/setup/${NC}"
    else
        echo -e "${RED}⚠ Could not download setup.sh from GitHub${NC}"
        return 1
    fi
    
    # Download additional setup scripts if they exist
    local additional_scripts=("setup-mcp.sh" "create-github-repos.sh" "config.yml.template")
    
    for script in "${additional_scripts[@]}"; do
        local script_url="$GITHUB_RAW_BASE/setup/$script"
        if download_file "$script_url" "$target_dir/setup/$script"; then
            chmod +x "$target_dir/setup/$script"
            echo -e "${GREEN}✓ Downloaded $script to $target_dir/setup/${NC}"
        else
            echo -e "${YELLOW}⚠ Could not download $script (may not exist)${NC}"
        fi
    done
    
    echo -e "${GREEN}✓ Setup scripts downloaded${NC}"
    return 0
}

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}     CLAUDE.md Configuration Generator     ${NC}"
    echo -e "${BLUE}          (GitHub Repository Based)        ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
}

# Function to create claude directory structure
create_claude_structure() {
    echo -e "${YELLOW}Creating .claude directory structure...${NC}"
    
    mkdir -p "$CLAUDE_DIR/standards/best-practices"
    mkdir -p "$CLAUDE_DIR/standards/code-style"
    mkdir -p "$CLAUDE_DIR/claude-code"
    mkdir -p "$TEMP_DIR"
    
    echo -e "${GREEN}✓ Directory structure created${NC}"
}

# Function to download core files from GitHub
download_core_files() {
    echo -e "${YELLOW}Downloading core configuration files from GitHub...${NC}"
    
    # Try to download llm-guard-rails.md
    if download_file "$CORE_FILES_BASE/llm-guard-rails.md" "$TEMP_DIR/llm-guard-rails.md"; then
        cp "$TEMP_DIR/llm-guard-rails.md" "$CLAUDE_DIR/"
        echo "  ✓ Downloaded llm-guard-rails.md"
    else
        echo "  ⚠ Creating default llm-guard-rails.md"
        create_default_guard_rails
    fi
    
    # Try to download llm-pre-prompt.md
    if download_file "$CORE_FILES_BASE/llm-pre-prompt.md" "$TEMP_DIR/llm-pre-prompt.md"; then
        cp "$TEMP_DIR/llm-pre-prompt.md" "$CLAUDE_DIR/"
        echo "  ✓ Downloaded llm-pre-prompt.md"
    else
        echo "  ⚠ Creating default llm-pre-prompt.md"
        create_default_pre_prompt
    fi
    
    # Try to download code-validation-rules.json
    if download_file "$CORE_FILES_BASE/code-validation-rules.json" "$TEMP_DIR/code-validation-rules.json"; then
        cp "$TEMP_DIR/code-validation-rules.json" "$CLAUDE_DIR/"
        echo "  ✓ Downloaded code-validation-rules.json"
    else
        echo "  ⚠ Creating default code-validation-rules.json"
        create_default_validation_rules
    fi
    
    echo -e "${GREEN}✓ Core files processed${NC}"
}

# Function to create default guard rails
create_default_guard_rails() {
    cat > "$CLAUDE_DIR/llm-guard-rails.md" << 'EOF'
# LLM Guard Rails

## Critical Rules (MUST NOT VIOLATE)

### Security
- NEVER hardcode credentials, API keys, or secrets
- NEVER expose sensitive data in logs
- ALWAYS validate and sanitize user input
- ALWAYS use parameterized queries for database operations

### Architecture
- NEVER place business logic in UI components
- NEVER violate Clean Architecture principles
- NEVER create circular dependencies
- ALWAYS maintain separation of concerns

### Code Quality
- NEVER skip error handling for async operations
- NEVER use 'any' type without explicit justification
- NEVER commit code without proper testing
- ALWAYS follow established patterns in the codebase

## High Priority Warnings

### Performance
- WARN on unoptimized database queries
- WARN on missing indexes
- WARN on synchronous operations that should be async
- WARN on memory leaks or inefficient memory usage

### Maintainability
- WARN on functions exceeding 50 lines
- WARN on cyclomatic complexity > 10
- WARN on deeply nested code (> 3 levels)
- WARN on duplicated code blocks

## Enforcement

All code MUST pass these guard rails before being considered complete.
EOF
}

# Function to create default pre-prompt
create_default_pre_prompt() {
    cat > "$CLAUDE_DIR/llm-pre-prompt.md" << 'EOF'
# LLM Pre-Prompt Protocol

## Before Any Code Generation

### 1. Context Loading
- READ relevant best practices for the current layer
- SCAN existing code patterns in the project
- IDENTIFY the architectural layer being modified

### 2. Compliance Verification
- CHECK for critical rule violations
- VERIFY security implications
- ENSURE consistency with existing patterns

### 3. Pattern Application
- USE existing project utilities and helpers
- FOLLOW established naming conventions
- MAINTAIN code style consistency

## Code Generation Checklist

- [ ] Best practices document reviewed
- [ ] No critical violations present
- [ ] Security considerations addressed
- [ ] Error handling implemented
- [ ] Input validation included
- [ ] Tests considered/written
- [ ] Documentation updated if needed

## Quality Gates

Before submitting any code:
1. Would this pass linting?
2. Would this pass type checking?
3. Does this follow Clean Architecture?
4. Is this maintainable and readable?
5. Are there any security concerns?
EOF
}

# Function to create default validation rules
create_default_validation_rules() {
    cat > "$CLAUDE_DIR/code-validation-rules.json" << 'EOF'
{
  "version": "1.0.0",
  "rules": {
    "critical": {
      "security": [
        "no-hardcoded-secrets",
        "no-eval-usage",
        "no-sql-injection",
        "validate-user-input"
      ],
      "architecture": [
        "clean-architecture-compliance",
        "no-business-logic-in-ui",
        "dependency-inversion",
        "single-responsibility"
      ]
    },
    "high": {
      "quality": [
        "error-handling-required",
        "no-any-type",
        "max-function-length-50",
        "max-complexity-10"
      ],
      "testing": [
        "minimum-coverage-80",
        "unit-tests-required",
        "integration-tests-for-apis"
      ]
    },
    "thresholds": {
      "maxFunctionLength": 50,
      "maxFileLength": 300,
      "maxComplexity": 10,
      "minTestCoverage": 80
    }
  }
}
EOF
}

# Function to select frontend stack
select_frontend() {
    echo -e "\n${BLUE}Select Frontend Framework:${NC}" >&2
    echo "1) Angular" >&2
    echo "2) React" >&2
    echo "3) Vue.js" >&2
    echo "4) Svelte" >&2
    echo "5) Vanilla JS/HTML" >&2
    echo "0) Skip frontend" >&2
    
    read -p "Enter your choice (0-5): " choice
    
    if [ "$choice" != "0" ] && [ -n "${FRONTEND_STACKS[$choice]}" ]; then
        echo "${FRONTEND_STACKS[$choice]}"
    else
        echo ""
    fi
}

# Function to select backend stack
select_backend() {
    echo -e "\n${BLUE}Select Backend Framework:${NC}" >&2
    echo "1) Node.js/Express" >&2
    echo "2) .NET Core" >&2
    echo "3) Python/Django/FastAPI" >&2
    echo "4) Java/Spring" >&2
    echo "5) Go" >&2
    echo "0) Skip backend" >&2
    
    read -p "Enter your choice (0-5): " choice
    
    if [ "$choice" != "0" ] && [ -n "${BACKEND_STACKS[$choice]}" ]; then
        echo "${BACKEND_STACKS[$choice]}"
    else
        echo ""
    fi
}

# Function to select database
select_database() {
    echo -e "\n${BLUE}Select Database:${NC}" >&2
    echo "1) PostgreSQL" >&2
    echo "2) MongoDB" >&2
    echo "3) MySQL" >&2
    echo "4) Redis" >&2
    echo "5) SQLite" >&2
    echo "0) Skip database" >&2
    
    read -p "Enter your choice (0-5): " choice
    
    if [ "$choice" != "0" ] && [ -n "${DATABASE_STACKS[$choice]}" ]; then
        echo "${DATABASE_STACKS[$choice]}"
    else
        echo ""
    fi
}

# Function to select testing framework
select_testing() {
    echo -e "\n${BLUE}Select Testing Framework:${NC}" >&2
    echo "1) Jest" >&2
    echo "2) Jasmine" >&2
    echo "3) Mocha/Chai" >&2
    echo "4) Vitest" >&2
    echo "5) Cypress" >&2
    echo "0) Skip testing framework" >&2
    
    read -p "Enter your choice (0-5): " choice
    
    if [ "$choice" != "0" ] && [ -n "${TESTING_FRAMEWORKS[$choice]}" ]; then
        echo "${TESTING_FRAMEWORKS[$choice]}"
    else
        echo ""
    fi
}

# Function to download standards from GitHub based on selection
download_standards() {
    local frontend=$1
    local backend=$2
    local database=$3
    local testing=$4
    
    echo -e "\n${YELLOW}Downloading relevant standards from GitHub...${NC}"
    
    # Download frontend standards
    if [ -n "$frontend" ]; then
        echo "  Downloading $frontend standards..."
        
        # Download code style if exists
        if download_file "$STANDARDS_BASE/code-style/${frontend}-style.md" "$TEMP_DIR/${frontend}-style.md"; then
            cp "$TEMP_DIR/${frontend}-style.md" "$CLAUDE_DIR/standards/code-style/"
            echo "    ✓ Downloaded ${frontend}-style.md"
        fi
        
        # Try to download frontend best practices
        for file in "frontend-best-practices.md" "frontend.md" "${frontend}-best-practices.md"; do
            if download_file "$STANDARDS_BASE/best-practices/frontend/$file" "$TEMP_DIR/$file"; then
                cp "$TEMP_DIR/$file" "$CLAUDE_DIR/standards/best-practices/"
                echo "    ✓ Downloaded $file"
                break
            fi
        done
    fi
    
    # Download backend standards
    if [ -n "$backend" ]; then
        echo "  Downloading $backend standards..."
        
        # Download code style if exists
        if download_file "$STANDARDS_BASE/code-style/${backend}-style.md" "$TEMP_DIR/${backend}-style.md"; then
            cp "$TEMP_DIR/${backend}-style.md" "$CLAUDE_DIR/standards/code-style/"
            echo "    ✓ Downloaded ${backend}-style.md"
        fi
        
        # Try to download backend best practices
        for file in "backend-best-practices.md" "backend.md" "${backend}-best-practices.md"; do
            if download_file "$STANDARDS_BASE/best-practices/backend/$file" "$TEMP_DIR/$file"; then
                cp "$TEMP_DIR/$file" "$CLAUDE_DIR/standards/best-practices/"
                echo "    ✓ Downloaded $file"
                break
            fi
        done
    fi
    
    # Download database standards
    if [ -n "$database" ]; then
        echo "  Downloading $database standards..."
        
        for file in "database-best-practices.md" "database.md" "${database}-best-practices.md"; do
            if download_file "$STANDARDS_BASE/best-practices/database/$file" "$TEMP_DIR/$file"; then
                cp "$TEMP_DIR/$file" "$CLAUDE_DIR/standards/best-practices/"
                echo "    ✓ Downloaded $file"
                break
            fi
        done
    fi
    
    # Download global standards
    echo "  Downloading global standards..."
    for file in "global-best-practices.md" "global.md" "security.md" "performance.md"; do
        if download_file "$STANDARDS_BASE/best-practices/global/$file" "$TEMP_DIR/$file"; then
            cp "$TEMP_DIR/$file" "$CLAUDE_DIR/standards/best-practices/"
            echo "    ✓ Downloaded $file"
        fi
    done
    
    # Download general best practices
    if download_file "$STANDARDS_BASE/best-practices.md" "$TEMP_DIR/best-practices.md"; then
        cp "$TEMP_DIR/best-practices.md" "$CLAUDE_DIR/standards/"
        echo "    ✓ Downloaded best-practices.md"
    fi
    
    # Download best practices index
    if download_file "$STANDARDS_BASE/best-practices/best-practices.index.md" "$TEMP_DIR/best-practices.index.md"; then
        cp "$TEMP_DIR/best-practices.index.md" "$CLAUDE_DIR/standards/best-practices/"
        echo "    ✓ Downloaded best-practices.index.md"
    fi
    
    echo -e "${GREEN}✓ Standards downloaded${NC}"
}

# Function to generate CLAUDE.md
generate_claude_md() {
    local frontend=$1
    local backend=$2
    local database=$3
    local testing=$4
    local project_name=$5
    
    echo -e "\n${YELLOW}Generating CLAUDE.md...${NC}"
    
    cat > "$CLAUDE_MD_FILE" << EOF
# CLAUDE.md - AI Assistant Configuration

## ⚠️ MANDATORY COMPLIANCE FRAMEWORK ⚠️

**THIS IS A CONTROLLED CODEBASE WITH STRICT GUARD RAILS**

### 🔴 CRITICAL: You MUST Read These Files FIRST
1. \`.claude/standards/best-practices.md\` - Core development principles
2. \`.claude/llm-guard-rails.md\` - Mandatory compliance rules
3. \`.claude/llm-pre-prompt.md\` - Pre-execution protocol
4. \`.claude/code-validation-rules.json\` - Automated validation rules

### 🚨 ENFORCEMENT MODE: STRICT

## Project Overview

**Project**: $project_name
**Tech Stack**:
EOF

    if [ -n "$frontend" ]; then
        echo "- Frontend: $frontend with TypeScript (strict mode)" >> "$CLAUDE_MD_FILE"
    fi
    
    if [ -n "$backend" ]; then
        echo "- Backend: $backend with TypeScript" >> "$CLAUDE_MD_FILE"
    fi
    
    if [ -n "$database" ]; then
        echo "- Database: $database" >> "$CLAUDE_MD_FILE"
    fi
    
    if [ -n "$testing" ]; then
        echo "- Testing: $testing (>80% coverage required)" >> "$CLAUDE_MD_FILE"
    fi
    
    cat >> "$CLAUDE_MD_FILE" << 'EOF'
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
EOF
    
    echo -e "${GREEN}✓ CLAUDE.md generated${NC}"
}

# Function to cleanup temp directory
cleanup_temp() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Function to create summary
create_summary() {
    local frontend=$1
    local backend=$2
    local database=$3
    local testing=$4
    
    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}         Configuration Complete!            ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo -e "${BLUE}Selected Tech Stack:${NC}"
    [ -n "$frontend" ] && echo "  • Frontend: $frontend"
    [ -n "$backend" ] && echo "  • Backend: $backend"
    [ -n "$database" ] && echo "  • Database: $database"
    [ -n "$testing" ] && echo "  • Testing: $testing"
    echo
    echo -e "${BLUE}Generated Files:${NC}"
    echo "  • CLAUDE.md - Main configuration file"
    echo "  • .claude/ - Standards and guard rails directory"
    echo
    echo -e "${BLUE}Downloaded From:${NC}"
    echo "  • GitHub: kishen902516/Full-Stack-Bootstrap"
    echo "  • Branch: initial-setup"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Review CLAUDE.md for accuracy"
    echo "  2. Customize guard rails in .claude/llm-guard-rails.md"
    echo "  3. Add project-specific standards to .claude/standards/"
    echo "  4. Run MCP setup: ./setup/setup-mcp.sh"
    echo "  5. Commit these files to your repository"
}


# Main execution
main() {
    display_header
    
    # Check for download tool
    check_download_tool > /dev/null
    
    # Prompt for project directory
    echo -e "${BLUE}Project Directory Setup:${NC}"
    echo "Current directory: $(pwd)"
    echo -e "${YELLOW}Note: Please provide an absolute path (e.g., /home/user/projects/myapp or C:\\Projects\\MyApp)${NC}"
    echo
    
    while true; do
        read -p "Enter absolute project directory path (or press Enter to use current directory): " project_dir
        
        # Use current directory if no input provided
        if [ -z "$project_dir" ]; then
            project_dir=$(pwd)
            echo -e "${GREEN}Using current directory: $project_dir${NC}"
            break
        else
            # Expand tilde to home directory if present
            project_dir="${project_dir/#\~/$HOME}"
            
            # Check if path is absolute
            if [[ "$project_dir" = /* ]] || [[ "$project_dir" =~ ^[A-Za-z]: ]]; then
                echo -e "${GREEN}Valid absolute path provided: $project_dir${NC}"
                
                # Create directory if it doesn't exist
                if [ ! -d "$project_dir" ]; then
                    echo -e "${YELLOW}Directory doesn't exist. Creating: $project_dir${NC}"
                    mkdir -p "$project_dir" || {
                        echo -e "${RED}Error: Could not create directory $project_dir${NC}"
                        echo -e "${RED}Please check permissions and try again.${NC}"
                        continue
                    }
                    echo -e "${GREEN}✓ Directory created successfully${NC}"
                else
                    echo -e "${GREEN}✓ Directory already exists${NC}"
                fi
                
                # Change to the project directory
                cd "$project_dir" || {
                    echo -e "${RED}Error: Could not change to directory $project_dir${NC}"
                    echo -e "${RED}Please check permissions and try again.${NC}"
                    continue
                }
                
                echo -e "${GREEN}✓ Changed to project directory: $project_dir${NC}"
                break
            else
                echo -e "${RED}Error: Please provide an absolute path.${NC}"
                echo -e "${YELLOW}Examples:${NC}"
                echo "  Linux/Mac: /home/username/projects/myapp"
                echo "  Windows: C:\\Projects\\MyApp or /c/Projects/MyApp"
                echo
            fi
        fi
    done
    
    # Automatically download setup scripts if setup directory doesn't exist
    if [ ! -d "$project_dir/setup" ]; then
        echo -e "${BLUE}Setup directory not found. Downloading setup scripts from GitHub...${NC}"
        download_setup_script "$project_dir"
    else
        echo -e "${GREEN}✓ Setup directory already exists in project${NC}"
    fi
    
    echo
    
    # Get project name
    read -p "Enter project name: " project_name
    project_name=${project_name:-"My Project"}
    
    # Select tech stacks
    frontend=$(select_frontend)
    backend=$(select_backend)
    database=$(select_database)
    testing=$(select_testing)
    
    # Confirm selections
    echo -e "\n${YELLOW}Configuration Summary:${NC}"
    echo "Project: $project_name"
    [ -n "$frontend" ] && echo "Frontend: $frontend"
    [ -n "$backend" ] && echo "Backend: $backend"
    [ -n "$database" ] && echo "Database: $database"
    [ -n "$testing" ] && echo "Testing: $testing"
    echo
    read -p "Proceed with this configuration? (y/n): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${RED}Configuration cancelled.${NC}"
        cleanup_temp
        exit 0
    fi
    
    # Create structure and download files
    create_claude_structure
    download_core_files
    download_standards "$frontend" "$backend" "$database" "$testing"
    generate_claude_md "$frontend" "$backend" "$database" "$testing" "$project_name"
    
    # Cleanup temporary directory
    cleanup_temp
    
    # Display summary
    create_summary "$frontend" "$backend" "$database" "$testing"
    
    # Ask if user wants to create GitHub polyrepo architecture
    echo
    read -p "Would you like to create GitHub polyrepo architecture? (y/n): " create_polyrepo
    
    if [ "$create_polyrepo" = "y" ] || [ "$create_polyrepo" = "Y" ]; then
        if [ -f "./setup/create-github-repos.sh" ]; then
            echo -e "\n${YELLOW}Launching GitHub polyrepo setup...${NC}"
            chmod +x "./setup/create-github-repos.sh"
            "./setup/create-github-repos.sh"
        else
            echo -e "${RED}GitHub polyrepo script not found at ./setup/create-github-repos.sh${NC}"
            echo "Please ensure the script exists and try again."
        fi
    else
        echo -e "${BLUE}Polyrepo setup skipped.${NC}"
    fi
    
    # Ask if user wants to setup MCP
    echo
    read -p "Would you like to setup MCP (Model Context Protocol) servers now? (y/n): " setup_mcp
    
    if [ "$setup_mcp" = "y" ] || [ "$setup_mcp" = "Y" ]; then
        echo -e "\n${YELLOW}Setting up MCP servers...${NC}"
        if [ -f "./setup/setup-mcp.sh" ]; then
            chmod +x "./setup/setup-mcp.sh"
            "./setup/setup-mcp.sh" "$project_dir"
        else
            echo -e "${RED}MCP setup script not found at ./setup/setup-mcp.sh${NC}"
            echo "You can run it manually later when the script is available."
        fi
    else
        echo -e "${BLUE}MCP setup skipped. You can run it later with: ./setup/setup-mcp.sh \"$project_dir\"${NC}"
    fi
    
    echo
    echo -e "${GREEN}Setup complete! 🚀${NC}"
}

# Trap to ensure cleanup on exit
trap cleanup_temp EXIT

# Project root check is handled in main() function after directory selection

# Run main function
main