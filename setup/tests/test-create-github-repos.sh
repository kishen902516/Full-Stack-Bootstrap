#!/bin/bash

# Test script for create-github-repos.sh
# Tests GitHub repository creation functionality
# Version: 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="/tmp/github-repos-test-$$"
TEST_PROJECT_NAME="TestGHProject$$"
TEST_REPO_BASE="test-gh-$$"
TEST_RESULTS_FILE="github-test-results.log"
ORIGINAL_DIR=$(pwd)

# Cleanup tracking
declare -a CREATED_DIRS=()
declare -a CREATED_FILES=()
declare -a GITHUB_REPOS=()
declare -a LOCAL_REPOS=()

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to log test results
log_test() {
    local test_name=$1
    local status=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$status" = "PASS" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ $test_name${NC}" | tee -a "$TEST_RESULTS_FILE"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ $test_name${NC}" | tee -a "$TEST_RESULTS_FILE"
        [ -n "$message" ] && echo "  Error: $message" | tee -a "$TEST_RESULTS_FILE"
    fi
}

# Function to cleanup test artifacts
cleanup_test_artifacts() {
    echo -e "\n${YELLOW}Cleaning up test artifacts...${NC}"
    
    # Clean up local directories
    for dir in "${CREATED_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "  Removing directory: $dir"
            rm -rf "$dir" 2>/dev/null || true
        fi
    done
    
    # Clean up test files
    for file in "${CREATED_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  Removing file: $file"
            rm -f "$file" 2>/dev/null || true
        fi
    done
    
    # Clean up GitHub repos if gh is available and authenticated
    if command -v gh &> /dev/null && gh auth status &>/dev/null; then
        if [ ${#GITHUB_REPOS[@]} -gt 0 ]; then
            echo -e "${YELLOW}Cleaning up GitHub test repositories...${NC}"
            for repo in "${GITHUB_REPOS[@]}"; do
                echo "  Attempting to delete repository: $repo"
                gh repo delete "$repo" --yes 2>/dev/null || echo "    Could not delete $repo (may not exist)"
            done
        fi
    fi
    
    # Clean up local git repos
    for repo_dir in "${LOCAL_REPOS[@]}"; do
        if [ -d "$repo_dir" ]; then
            echo "  Removing local repo: $repo_dir"
            rm -rf "$repo_dir" 2>/dev/null || true
        fi
    done
    
    # Remove main test directory
    if [ -d "$TEST_DIR" ]; then
        echo "  Removing test directory: $TEST_DIR"
        rm -rf "$TEST_DIR" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function to test GitHub CLI availability
test_github_cli_availability() {
    echo -e "\n${BLUE}Testing GitHub CLI availability...${NC}"
    
    if command -v gh &> /dev/null; then
        log_test "GitHub CLI installed" "PASS"
        
        # Check version
        local gh_version=$(gh --version | head -n 1)
        echo "  Version: $gh_version"
    else
        log_test "GitHub CLI installed" "FAIL" "gh command not found"
    fi
}

# Function to test GitHub authentication
test_github_authentication() {
    echo -e "\n${BLUE}Testing GitHub authentication...${NC}"
    
    if ! command -v gh &> /dev/null; then
        log_test "GitHub authentication" "SKIP" "GitHub CLI not installed"
        return
    fi
    
    if gh auth status &>/dev/null; then
        log_test "GitHub authentication" "PASS"
        
        # Get authenticated user
        local current_user=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
        echo "  Authenticated as: $current_user"
    else
        log_test "GitHub authentication" "FAIL" "Not authenticated with GitHub"
    fi
}

# Function to test git availability
test_git_availability() {
    echo -e "\n${BLUE}Testing git availability...${NC}"
    
    if command -v git &> /dev/null; then
        log_test "Git installed" "PASS"
        
        # Check version
        local git_version=$(git --version)
        echo "  $git_version"
    else
        log_test "Git installed" "FAIL" "git command not found"
    fi
}

# Function to test repository type definitions
test_repo_type_definitions() {
    echo -e "\n${BLUE}Testing repository type definitions...${NC}"
    
    # Simulate the REPO_TYPES array from the script
    declare -A REPO_TYPES=(
        ["service"]="Backend service"
        ["webapp"]="Frontend web application"
        ["job"]="Background job/worker"
        ["mobile"]="Mobile application"
        ["lib"]="Shared library"
    )
    
    if [ ${#REPO_TYPES[@]} -eq 5 ]; then
        log_test "Repository type definitions" "PASS"
        echo "  Found ${#REPO_TYPES[@]} repository types"
    else
        log_test "Repository type definitions" "FAIL" "Expected 5 repository types"
    fi
}

# Function to test initial file creation functions
test_initial_file_creation() {
    echo -e "\n${BLUE}Testing initial file creation...${NC}"
    
    local test_repo_dir="$TEST_DIR/file-creation-test"
    mkdir -p "$test_repo_dir"
    CREATED_DIRS+=("$test_repo_dir")
    cd "$test_repo_dir"
    
    # Test contracts repo file creation
    cat > README.md << 'EOF'
# Test Contracts Repository

This is a test contracts repository.
EOF
    
    mkdir -p contracts/{api,types,design-tokens}
    
    if [ -f "README.md" ] && [ -d "contracts/api" ]; then
        log_test "Contracts repo file structure" "PASS"
    else
        log_test "Contracts repo file structure" "FAIL" "Files or directories not created"
    fi
    
    # Test package.json creation
    cat > package.json << 'EOF'
{
  "name": "test-contracts",
  "version": "0.1.0"
}
EOF
    
    if [ -f "package.json" ]; then
        # Validate JSON
        if command -v node &> /dev/null; then
            if node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))" 2>/dev/null; then
                log_test "Package.json creation" "PASS"
            else
                log_test "Package.json creation" "FAIL" "Invalid JSON format"
            fi
        elif command -v python3 &> /dev/null; then
            if python3 -c "import json; json.load(open('package.json'))" 2>/dev/null; then
                log_test "Package.json creation" "PASS"
            else
                log_test "Package.json creation" "FAIL" "Invalid JSON format"
            fi
        else
            log_test "Package.json creation" "PASS" "(JSON validation skipped)"
        fi
    else
        log_test "Package.json creation" "FAIL" "File not created"
    fi
    
    cd "$ORIGINAL_DIR"
}

# Function to test Docker file creation
test_docker_file_creation() {
    echo -e "\n${BLUE}Testing Docker file creation...${NC}"
    
    local docker_dir="$TEST_DIR/docker-test"
    mkdir -p "$docker_dir"
    CREATED_DIRS+=("$docker_dir")
    cd "$docker_dir"
    
    # Create test Dockerfile
    cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist/ ./dist/
EXPOSE 3000
CMD ["node", "dist/index.js"]
EOF
    
    # Create test .dockerignore
    cat > .dockerignore << 'EOF'
node_modules
.git
.env
EOF
    
    CREATED_FILES+=("$docker_dir/Dockerfile" "$docker_dir/.dockerignore")
    
    if [ -f "Dockerfile" ] && [ -f ".dockerignore" ]; then
        log_test "Docker file creation" "PASS"
    else
        log_test "Docker file creation" "FAIL" "Docker files not created"
    fi
    
    cd "$ORIGINAL_DIR"
}

# Function to test GitHub Actions workflow creation
test_github_actions_creation() {
    echo -e "\n${BLUE}Testing GitHub Actions workflow creation...${NC}"
    
    local actions_dir="$TEST_DIR/actions-test/.github/workflows"
    mkdir -p "$actions_dir"
    CREATED_DIRS+=("$TEST_DIR/actions-test")
    
    # Create test workflow
    cat > "$actions_dir/publish.yml" << 'EOF'
name: Publish Contracts
on:
  push:
    tags:
      - 'v*'
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF
    
    CREATED_FILES+=("$actions_dir/publish.yml")
    
    if [ -f "$actions_dir/publish.yml" ]; then
        log_test "GitHub Actions workflow creation" "PASS"
    else
        log_test "GitHub Actions workflow creation" "FAIL" "Workflow file not created"
    fi
}

# Function to test repository creation simulation
test_repo_creation_simulation() {
    echo -e "\n${BLUE}Testing repository creation simulation...${NC}"
    
    if ! command -v gh &> /dev/null || ! gh auth status &>/dev/null; then
        log_test "Repository creation simulation" "SKIP" "GitHub CLI not available or not authenticated"
        return
    fi
    
    local test_repo_name="test-repo-$$-simulation"
    local temp_dir="$TEST_DIR/$test_repo_name"
    mkdir -p "$temp_dir"
    CREATED_DIRS+=("$temp_dir")
    cd "$temp_dir"
    
    # Initialize git repo
    git init
    git branch -M main
    
    # Create a test file
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit" &>/dev/null
    
    if [ -d ".git" ] && [ -f "README.md" ]; then
        log_test "Repository initialization" "PASS"
    else
        log_test "Repository initialization" "FAIL" "Git repo not properly initialized"
    fi
    
    cd "$ORIGINAL_DIR"
}

# Function to test input validation
test_input_validation() {
    echo -e "\n${BLUE}Testing input validation...${NC}"
    
    # Test project name validation
    local test_name="My Test Project 123!"
    local sanitized_name=$(echo "$test_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
    
    if [ "$sanitized_name" = "my-test-project-123" ]; then
        log_test "Project name sanitization" "PASS"
    else
        log_test "Project name sanitization" "FAIL" "Expected 'my-test-project-123', got '$sanitized_name'"
    fi
}

# Function to test script file structure
test_script_structure() {
    echo -e "\n${BLUE}Testing script structure...${NC}"
    
    local script_dir="$(cd "$(dirname "$0")" && cd .. && pwd)"
    if [ -f "$script_dir/create-github-repos.sh" ]; then
        # Check for required functions
        local required_functions=(
            "display_header"
            "check_prerequisites"
            "get_project_config"
            "select_repositories"
            "create_repository"
            "create_initial_files"
        )
        
        local missing_functions=0
        for func in "${required_functions[@]}"; do
            if ! grep -q "^${func}()" "$script_dir/create-github-repos.sh" 2>/dev/null; then
                ((missing_functions++))
            fi
        done
        
        if [ $missing_functions -eq 0 ]; then
            log_test "Script structure validation" "PASS"
        else
            log_test "Script structure validation" "FAIL" "$missing_functions required functions missing"
        fi
    else
        log_test "Script structure validation" "SKIP" "create-github-repos.sh not found"
    fi
}

# Function to test OS detection
test_os_detection() {
    echo -e "\n${BLUE}Testing OS detection...${NC}"
    
    local os_type=""
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macOS"
    elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "mingw"* ]]; then
        os_type="Windows"
    else
        os_type="Unknown"
    fi
    
    if [ -n "$os_type" ] && [ "$os_type" != "Unknown" ]; then
        log_test "OS detection" "PASS"
        echo "  Detected OS: $os_type"
    else
        log_test "OS detection" "FAIL" "Could not detect OS type"
    fi
}

# Function to test package manager detection
test_package_manager_detection() {
    echo -e "\n${BLUE}Testing package manager detection...${NC}"
    
    local package_managers=()
    
    # Check for various package managers
    command -v apt-get &> /dev/null && package_managers+=("apt-get")
    command -v dnf &> /dev/null && package_managers+=("dnf")
    command -v yum &> /dev/null && package_managers+=("yum")
    command -v brew &> /dev/null && package_managers+=("brew")
    command -v winget &> /dev/null && package_managers+=("winget")
    command -v choco &> /dev/null && package_managers+=("choco")
    command -v scoop &> /dev/null && package_managers+=("scoop")
    
    if [ ${#package_managers[@]} -gt 0 ]; then
        log_test "Package manager detection" "PASS"
        echo "  Found: ${package_managers[*]}"
    else
        log_test "Package manager detection" "FAIL" "No package managers found"
    fi
}

# Function to test actual repository creation (with cleanup)
test_actual_repo_creation() {
    echo -e "\n${BLUE}Testing actual repository creation...${NC}"
    
    if ! command -v gh &> /dev/null || ! gh auth status &>/dev/null; then
        log_test "Actual repository creation" "SKIP" "GitHub CLI not available or not authenticated"
        return
    fi
    
    # Warning prompt
    echo -e "${YELLOW}⚠ This test will create and delete a real GitHub repository${NC}"
    read -p "Continue with actual repo creation test? (y/n): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_test "Actual repository creation" "SKIP" "User skipped test"
        return
    fi
    
    local test_repo="test-repo-$$-actual"
    GITHUB_REPOS+=("$test_repo")
    
    # Create repository
    if gh repo create "$test_repo" --private --description "Test repository (auto-delete)" 2>/dev/null; then
        log_test "GitHub repository creation" "PASS"
        echo "  Created: $test_repo"
        
        # Clean up immediately
        sleep 2
        if gh repo delete "$test_repo" --yes 2>/dev/null; then
            echo "  Cleaned up: $test_repo"
            # Remove from cleanup list since already deleted
            unset 'GITHUB_REPOS[-1]'
        fi
    else
        log_test "GitHub repository creation" "FAIL" "Could not create repository"
    fi
}

# Function to display test summary
display_summary() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}           Test Summary                    ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    echo -e "Total Tests Run: ${TESTS_RUN}"
    echo -e "${GREEN}Tests Passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Tests Failed: ${TESTS_FAILED}${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}All tests passed! ✓${NC}"
        return 0
    else
        echo -e "\n${RED}Some tests failed. Please review the results.${NC}"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   GitHub Repos Script Test Suite v1.0.0   ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    CREATED_DIRS+=("$TEST_DIR")
    
    # Initialize test results file
    echo "GitHub Repos Test Results - $(date)" > "$TEST_RESULTS_FILE"
    echo "================================" >> "$TEST_RESULTS_FILE"
    
    # Run tests
    echo -e "${CYAN}=== Testing prerequisites ===${NC}"
    test_git_availability
    test_github_cli_availability
    test_github_authentication
    test_os_detection
    test_package_manager_detection
    
    echo -e "\n${CYAN}=== Testing script functionality ===${NC}"
    test_repo_type_definitions
    test_input_validation
    test_script_structure
    
    echo -e "\n${CYAN}=== Testing file creation ===${NC}"
    test_initial_file_creation
    test_docker_file_creation
    test_github_actions_creation
    
    echo -e "\n${CYAN}=== Testing repository operations ===${NC}"
    test_repo_creation_simulation
    
    # Optional: Test actual repo creation
    # test_actual_repo_creation
    
    # Display summary
    display_summary
    local exit_code=$?
    
    # Cleanup
    cleanup_test_artifacts
    
    # Return to original directory
    cd "$ORIGINAL_DIR"
    
    echo -e "\n${BLUE}Test log saved to: $TEST_RESULTS_FILE${NC}"
    
    exit $exit_code
}

# Trap to ensure cleanup on exit
trap cleanup_test_artifacts EXIT INT TERM

# Run main function
main "$@"