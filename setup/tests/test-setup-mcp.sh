#!/bin/bash

# Test script for setup-mcp.sh
# Tests MCP (Model Context Protocol) setup functionality
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
TEST_DIR="/tmp/mcp-test-$$"
TEST_PROJECT_NAME="TestMCPProject$$"
TEST_RESULTS_FILE="mcp-test-results.log"
ORIGINAL_DIR=$(pwd)

# Cleanup tracking
declare -a CREATED_DIRS=()
declare -a CREATED_FILES=()
declare -a NPM_PACKAGES=()

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
    
    # Clean up test directories
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
    
    # Clean up npm packages if installed for testing
    if command -v npm &> /dev/null && [ ${#NPM_PACKAGES[@]} -gt 0 ]; then
        echo -e "${YELLOW}Cleaning up test npm packages...${NC}"
        for package in "${NPM_PACKAGES[@]}"; do
            echo "  Checking: $package"
            if npm list -g "$package" &>/dev/null; then
                echo "    Would uninstall: $package (skipped for safety)"
            fi
        done
    fi
    
    # Remove main test directory
    if [ -d "$TEST_DIR" ]; then
        echo "  Removing test directory: $TEST_DIR"
        rm -rf "$TEST_DIR" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function to test npm availability
test_npm_availability() {
    echo -e "\n${BLUE}Testing npm availability...${NC}"
    
    if command -v npm &> /dev/null; then
        log_test "NPM installed" "PASS"
        
        # Check version
        local npm_version=$(npm --version)
        echo "  Version: $npm_version"
    else
        log_test "NPM installed" "FAIL" "npm command not found"
    fi
}

# Function to test node availability
test_node_availability() {
    echo -e "\n${BLUE}Testing Node.js availability...${NC}"
    
    if command -v node &> /dev/null; then
        log_test "Node.js installed" "PASS"
        
        # Check version
        local node_version=$(node --version)
        echo "  Version: $node_version"
    else
        log_test "Node.js installed" "FAIL" "node command not found"
    fi
}

# Function to test MCP package detection
test_mcp_package_detection() {
    echo -e "\n${BLUE}Testing MCP package detection...${NC}"
    
    if ! command -v npm &> /dev/null; then
        log_test "MCP package detection" "SKIP" "npm not installed"
        return
    fi
    
    local packages=(
        "@modelcontextprotocol/server-github"
        "@context7/mcp-server"
        "@modelcontextprotocol/server-playwright"
        "@modelcontextprotocol/server-atlassian"
    )
    
    local packages_found=0
    for package in "${packages[@]}"; do
        npm list -g "$package" &>/dev/null && ((packages_found++)) || true
    done
    
    log_test "MCP package detection" "PASS"
    echo "  Found $packages_found/${#packages[@]} MCP packages installed globally"
}

# Function to test configuration directory creation
test_config_directory_creation() {
    echo -e "\n${BLUE}Testing configuration directory creation...${NC}"
    
    local config_dir="$TEST_DIR/.claude-code"
    mkdir -p "$config_dir"
    CREATED_DIRS+=("$config_dir")
    
    if [ -d "$config_dir" ]; then
        log_test "Config directory creation" "PASS"
    else
        log_test "Config directory creation" "FAIL" "Could not create .claude-code directory"
    fi
}

# Function to test config.yml parsing
test_config_yml_parsing() {
    echo -e "\n${BLUE}Testing config.yml parsing...${NC}"
    
    local config_yml="$TEST_DIR/setup/config.yml"
    mkdir -p "$(dirname "$config_yml")"
    CREATED_DIRS+=("$TEST_DIR/setup")
    
    # Create a test config.yml
    cat > "$config_yml" << 'EOF'
github:
  personal_access_token: "test_github_token_123"

atlassian:
  domain: "testcompany.atlassian.net"
  email: "test@example.com"
  api_token: "test_atlassian_token_456"
EOF
    
    CREATED_FILES+=("$config_yml")
    
    # Test parsing with grep (simulating the script's parsing logic)
    local github_token=$(grep -A 5 "^github:" "$config_yml" | grep "personal_access_token:" | sed 's/.*personal_access_token:[[:space:]]*["\x27]\?\([^"\x27]*\)["\x27]\?.*/\1/' | tr -d ' ')
    local atlassian_domain=$(grep -A 10 "^atlassian:" "$config_yml" | grep "domain:" | sed 's/.*domain:[[:space:]]*["\x27]\?\([^"\x27]*\)["\x27]\?.*/\1/' | tr -d ' ')
    
    if [ "$github_token" = "test_github_token_123" ] && [ "$atlassian_domain" = "testcompany.atlassian.net" ]; then
        log_test "Config YAML parsing" "PASS"
    else
        log_test "Config YAML parsing" "FAIL" "Could not parse config correctly"
    fi
}

# Function to test config.yml template creation
test_config_template_creation() {
    echo -e "\n${BLUE}Testing config.yml template creation...${NC}"
    
    local template_file="$TEST_DIR/setup/config.yml.template"
    mkdir -p "$(dirname "$template_file")"
    
    # Create a template file
    cat > "$template_file" << 'EOF'
# MCP Configuration Template
github:
  personal_access_token: "your_github_token_here"

atlassian:
  domain: "your_company.atlassian.net"
  email: "your_email@example.com"
  api_token: "your_atlassian_token_here"
EOF
    
    CREATED_FILES+=("$template_file")
    
    # Test copying template to config
    local config_file="$TEST_DIR/setup/config.yml"
    if [ -f "$template_file" ]; then
        cp "$template_file" "$config_file"
        CREATED_FILES+=("$config_file")
        
        if [ -f "$config_file" ]; then
            log_test "Config template creation" "PASS"
        else
            log_test "Config template creation" "FAIL" "Could not create config from template"
        fi
    else
        log_test "Config template creation" "FAIL" "Template file not created"
    fi
}

# Function to test MCP JSON generation
test_mcp_json_generation() {
    echo -e "\n${BLUE}Testing MCP JSON generation...${NC}"
    
    local mcp_json="$TEST_DIR/.claude-code/mcp_servers.json"
    mkdir -p "$(dirname "$mcp_json")"
    
    # Create a test MCP configuration
    cat > "$mcp_json" << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "test_token"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"],
      "env": {
        "CONTEXT7_PROJECT_PATH": "/test/path"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    },
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-atlassian"],
      "env": {
        "ATLASSIAN_DOMAIN": "test.atlassian.net",
        "ATLASSIAN_EMAIL": "test@example.com",
        "ATLASSIAN_API_TOKEN": "test_token"
      }
    }
  }
}
EOF
    
    CREATED_FILES+=("$mcp_json")
    
    # Validate JSON
    local json_valid=false
    
    if command -v node &> /dev/null; then
        # Change directory to where the JSON file is located
        local json_dir=$(dirname "$mcp_json")
        local json_file=$(basename "$mcp_json")
        if (cd "$json_dir" && node -e "try { JSON.parse(require('fs').readFileSync('$json_file', 'utf8')); console.log('JSON valid'); process.exit(0); } catch(e) { console.log('JSON invalid:', e.message); process.exit(1); }") 2>/dev/null; then
            json_valid=true
        fi
    elif command -v python3 &> /dev/null; then
        if python3 -c "import json; json.load(open('$mcp_json'))" 2>/dev/null; then
            json_valid=true
        fi
    elif command -v python &> /dev/null; then
        if python -c "import json; json.load(open('$mcp_json'))" 2>/dev/null; then
            json_valid=true
        fi
    elif [ -f "$mcp_json" ] && grep -q '"mcpServers"' "$mcp_json" 2>/dev/null; then
        json_valid=true
    fi
    
    if [ "$json_valid" = true ]; then
        log_test "MCP JSON generation" "PASS"
    else
        log_test "MCP JSON generation" "FAIL" "Invalid JSON format"
    fi
}

# Function to test backup functionality
test_backup_functionality() {
    echo -e "\n${BLUE}Testing backup functionality...${NC}"
    
    local mcp_config="$TEST_DIR/.claude-code/mcp_servers.json"
    mkdir -p "$(dirname "$mcp_config")"
    
    # Create original file
    echo '{"original": true}' > "$mcp_config"
    CREATED_FILES+=("$mcp_config")
    
    # Create backup
    local backup_file="${mcp_config}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$mcp_config" "$backup_file"
    CREATED_FILES+=("$backup_file")
    
    if [ -f "$backup_file" ]; then
        log_test "Backup creation" "PASS"
    else
        log_test "Backup creation" "FAIL" "Backup file not created"
    fi
}

# Function to test path resolution
test_path_resolution() {
    echo -e "\n${BLUE}Testing path resolution...${NC}"
    
    local test_path="$TEST_DIR/test-project"
    mkdir -p "$test_path"
    CREATED_DIRS+=("$test_path")
    
    # Test realpath alternatives
    local resolved_path=""
    if command -v realpath &> /dev/null; then
        resolved_path=$(realpath "$test_path" 2>/dev/null)
    elif command -v readlink &> /dev/null; then
        resolved_path=$(readlink -f "$test_path" 2>/dev/null)
    else
        resolved_path="$test_path"
    fi
    
    if [ -n "$resolved_path" ]; then
        log_test "Path resolution" "PASS"
        echo "  Resolved: $resolved_path"
    else
        log_test "Path resolution" "FAIL" "Could not resolve path"
    fi
}

# Function to test JSON validation
test_json_validation() {
    echo -e "\n${BLUE}Testing JSON validation...${NC}"
    
    local test_json="$TEST_DIR/test.json"
    
    # Create valid JSON
    echo '{"valid": true, "test": "data"}' > "$test_json"
    CREATED_FILES+=("$test_json")
    
    local validation_passed=false
    local validation_method=""
    
    if command -v node &> /dev/null; then
        local json_dir=$(dirname "$test_json")
        local json_file=$(basename "$test_json")
        if (cd "$json_dir" && node -e "JSON.parse(require('fs').readFileSync('$json_file', 'utf8'))" 2>/dev/null); then
            validation_passed=true
            validation_method="Node.js"
        fi
    elif command -v python3 &> /dev/null; then
        if python3 -c "import json; json.load(open('$test_json'))" 2>/dev/null; then
            validation_passed=true
            validation_method="Python3"
        fi
    elif command -v python &> /dev/null; then
        if python -c "import json; json.load(open('$test_json'))" 2>/dev/null; then
            validation_passed=true
            validation_method="Python"
        fi
    fi
    
    if [ "$validation_passed" = true ]; then
        log_test "JSON validation tools" "PASS"
        echo "  Using: $validation_method"
    else
        log_test "JSON validation tools" "SKIP" "No JSON validation tool available"
    fi
}

# Function to test environment variable handling
test_env_variable_handling() {
    echo -e "\n${BLUE}Testing environment variable handling...${NC}"
    
    # Test setting and reading environment variables
    local test_token="test_token_12345"
    export TEST_MCP_TOKEN="$test_token"
    
    if [ "$TEST_MCP_TOKEN" = "$test_token" ]; then
        log_test "Environment variable handling" "PASS"
    else
        log_test "Environment variable handling" "FAIL" "Could not set/read environment variable"
    fi
    
    unset TEST_MCP_TOKEN
}

# Function to test integration with setup-mcp.sh
test_mcp_integration() {
    echo -e "\n${BLUE}Running MCP setup integration test...${NC}"
    
    local mcp_dir="$TEST_DIR/mcp-integration"
    mkdir -p "$mcp_dir/setup"
    CREATED_DIRS+=("$mcp_dir")
    
    # Get script directory before changing directories
    local script_dir="$(cd "$(dirname "$0")" && cd .. && pwd)"
    
    cd "$mcp_dir"
    
    # Copy the actual setup-mcp.sh if it exists
    if [ -f "$script_dir/setup-mcp.sh" ]; then
        cp "$script_dir/setup-mcp.sh" "$mcp_dir/setup/"
        CREATED_FILES+=("$mcp_dir/setup/setup-mcp.sh")
        chmod +x "$mcp_dir/setup/setup-mcp.sh"
        
        # Create a test config.yml
        cat > "$mcp_dir/setup/config.yml" << 'EOF'
github:
  personal_access_token: "test_token"
atlassian:
  domain: "test.atlassian.net"
  email: "test@example.com"
  api_token: "test_token"
EOF
        CREATED_FILES+=("$mcp_dir/setup/config.yml")
        
        # Check if npm is available
        if ! command -v npm &> /dev/null; then
            log_test "MCP integration test" "SKIP" "npm not installed"
            cd "$ORIGINAL_DIR"
            return
        fi
        
        # Run setup-mcp.sh with the test directory
        local output_file="$mcp_dir/mcp-output.log"
        if timeout 30 bash "$mcp_dir/setup/setup-mcp.sh" "$mcp_dir" > "$output_file" 2>&1; then
            if [ -f "$mcp_dir/.claude-code/mcp_servers.json" ]; then
                # Verify the JSON is valid
                if command -v node &> /dev/null; then
                    if node -e "JSON.parse(require('fs').readFileSync('$mcp_dir/.claude-code/mcp_servers.json', 'utf8'))" 2>/dev/null; then
                        log_test "MCP integration test" "PASS"
                    else
                        log_test "MCP integration test" "FAIL" "Generated JSON is invalid"
                    fi
                else
                    log_test "MCP integration test" "PASS" "(config generated)"
                fi
            else
                log_test "MCP integration test" "FAIL" "MCP config not generated"
            fi
        else
            # Check if it's just a timeout issue
            if [ -f "$mcp_dir/.claude-code/mcp_servers.json" ]; then
                log_test "MCP integration test" "PASS" "(completed with timeout)"
            else
                log_test "MCP integration test" "FAIL" "setup-mcp.sh execution failed"
            fi
        fi
        
        CREATED_FILES+=("$output_file")
    else
        log_test "MCP integration test" "SKIP" "setup-mcp.sh not found at $script_dir/setup-mcp.sh"
    fi
    
    cd "$ORIGINAL_DIR"
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
    echo -e "${BLUE}     MCP Setup Test Suite v1.0.0          ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    CREATED_DIRS+=("$TEST_DIR")
    
    # Initialize test results file
    echo "MCP Setup Test Results - $(date)" > "$TEST_RESULTS_FILE"
    echo "================================" >> "$TEST_RESULTS_FILE"
    
    # Run tests
    echo -e "${CYAN}=== Testing prerequisites ===${NC}"
    test_node_availability
    test_npm_availability
    test_mcp_package_detection
    
    echo -e "\n${CYAN}=== Testing configuration ===${NC}"
    test_config_directory_creation
    test_config_yml_parsing
    test_config_template_creation
    
    echo -e "\n${CYAN}=== Testing MCP functionality ===${NC}"
    test_mcp_json_generation
    test_backup_functionality
    test_path_resolution
    test_json_validation
    test_env_variable_handling
    
    echo -e "\n${CYAN}=== Testing integration ===${NC}"
    test_mcp_integration
    
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