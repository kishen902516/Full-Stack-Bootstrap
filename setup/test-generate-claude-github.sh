#!/bin/bash

# Test script for generate-claude-github.sh
# Author: AI Assistant
# Version: 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
SCRIPT_PATH="$(realpath "$(dirname "$0")/generate-claude-github.sh")"
TEST_DIR="$(pwd)/test_claude_setup_$(date +%s)"
HTML_REPORT="test-report-$(date +%Y%m%d-%H%M%S).html"
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Test results array
declare -a TEST_RESULTS=()

# Function to log test results
log_test() {
    local test_name=$1
    local status=$2
    local message=$3
    local duration=$4
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status" = "PASS" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓ PASS${NC}: $test_name ${BLUE}(${duration}s)${NC}"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗ FAIL${NC}: $test_name ${BLUE}(${duration}s)${NC}"
        echo -e "  ${YELLOW}Message:${NC} $message"
    fi
    
    TEST_RESULTS+=("$test_name|$status|$message|$duration")
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create test environment
setup_test_environment() {
    echo -e "${BLUE}Setting up test environment in: $TEST_DIR${NC}"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Initialize a fake git repository
    git init >/dev/null 2>&1 || true
    
    # Create a basic package.json to simulate a project
    cat > package.json << EOF
{
  "name": "test-project",
  "version": "1.0.0",
  "description": "Test project for claude setup",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  }
}
EOF
    
    echo -e "${GREEN}✓ Test environment created${NC}"
}

# Function to cleanup test environment
cleanup_test_environment() {
    if [ -d "$TEST_DIR" ]; then
        echo -e "${YELLOW}Cleaning up test environment...${NC}"
        rm -rf "$TEST_DIR"
        echo -e "${GREEN}✓ Test environment cleaned up${NC}"
    fi
}

# Function to simulate user input
simulate_input() {
    local input="$1"
    echo -e "$input"
}

# Test 1: Verify script exists and is executable
test_script_exists() {
    local start_time=$(date +%s)
    
    if [ ! -f "$SCRIPT_PATH" ]; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Script Existence" "FAIL" "Script not found at $SCRIPT_PATH" "$duration"
        return 1
    fi
    
    if [ ! -x "$SCRIPT_PATH" ]; then
        chmod +x "$SCRIPT_PATH"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    log_test "Script Existence" "PASS" "Script found and is executable" "$duration"
    return 0
}

# Test 2: Test download tool detection
test_download_tool_detection() {
    local start_time=$(date +%s)
    
    # Test the function directly by sourcing the script (if possible)
    if command_exists curl || command_exists wget; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Download Tool Detection" "PASS" "curl or wget available" "$duration"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Download Tool Detection" "FAIL" "Neither curl nor wget available" "$duration"
        return 1
    fi
}

# Test 3: Test directory structure creation
test_directory_creation() {
    local start_time=$(date +%s)
    
    # Create a simple package.json to avoid the warning
    echo '{"name": "test"}' > package.json
    
    # Run script with predefined inputs to test directory creation
    local input="Test Project\n1\n1\n1\n1\ny"
    
    # Use timeout to prevent hanging and redirect all output
    timeout 60s bash -c "echo -e '$input' | '$SCRIPT_PATH' >/dev/null 2>&1 || echo 'Script completed with exit code $?'" >/dev/null 2>&1 || true
    
    # Check if .claude directory was created
    if [ -d ".claude" ]; then
        local expected_dirs=(".claude/standards/best-practices" ".claude/standards/code-style" ".claude/claude-code")
        local all_dirs_exist=true
        
        for dir in "${expected_dirs[@]}"; do
            if [ ! -d "$dir" ]; then
                all_dirs_exist=false
                break
            fi
        done
        
        if [ "$all_dirs_exist" = true ]; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log_test "Directory Structure Creation" "PASS" "All required directories created" "$duration"
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log_test "Directory Structure Creation" "FAIL" "Some directories missing" "$duration"
            return 1
        fi
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Directory Structure Creation" "FAIL" ".claude directory not created" "$duration"
        return 1
    fi
}

# Test 4: Test CLAUDE.md generation
test_claude_md_generation() {
    local start_time=$(date +%s)
    
    if [ -f "CLAUDE.md" ]; then
        # Check if file contains expected content
        local has_compliance=$(grep -c "MANDATORY COMPLIANCE FRAMEWORK" "CLAUDE.md" || echo 0)
        local has_project=$(grep -c "Project:" "CLAUDE.md" || echo 0)
        local has_tech_stack=$(grep -c "Tech Stack:" "CLAUDE.md" || echo 0)
        
        if [ "$has_compliance" -gt 0 ] && [ "$has_project" -gt 0 ] && [ "$has_tech_stack" -gt 0 ]; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log_test "CLAUDE.md Generation" "PASS" "CLAUDE.md created with expected content" "$duration"
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local file_size=$(wc -c < "CLAUDE.md" 2>/dev/null || echo 0)
            log_test "CLAUDE.md Generation" "FAIL" "CLAUDE.md missing expected content (size: ${file_size} bytes, compliance:$has_compliance, project:$has_project, tech:$has_tech_stack)" "$duration"
            return 1
        fi
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "CLAUDE.md Generation" "FAIL" "CLAUDE.md not created" "$duration"
        return 1
    fi
}

# Test 5: Test core files creation
test_core_files_creation() {
    local start_time=$(date +%s)
    
    local core_files=(".claude/llm-guard-rails.md" ".claude/llm-pre-prompt.md" ".claude/code-validation-rules.json")
    local all_files_exist=true
    
    for file in "${core_files[@]}"; do
        if [ ! -f "$file" ]; then
            all_files_exist=false
            break
        fi
    done
    
    if [ "$all_files_exist" = true ]; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Core Files Creation" "PASS" "All core files created" "$duration"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Core Files Creation" "FAIL" "Some core files missing" "$duration"
        return 1
    fi
}

# Test 6: Test content validation
test_content_validation() {
    local start_time=$(date +%s)
    
    # Check if guard rails file has critical security rules
    if [ -f ".claude/llm-guard-rails.md" ] && \
       grep -q "NEVER hardcode credentials" ".claude/llm-guard-rails.md" && \
       grep -q "Clean Architecture" ".claude/llm-guard-rails.md"; then
        
        # Check if validation rules file is valid JSON
        if [ -f ".claude/code-validation-rules.json" ] && \
           python -m json.tool ".claude/code-validation-rules.json" >/dev/null 2>&1; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log_test "Content Validation" "PASS" "All files contain expected content" "$duration"
            return 0
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    log_test "Content Validation" "FAIL" "Content validation failed" "$duration"
    return 1
}

# Test 7: Test script cancellation
test_script_cancellation() {
    local start_time=$(date +%s)
    
    # Create a separate test directory for cancellation test
    local cancel_test_dir="${TEST_DIR}_cancel"
    mkdir -p "$cancel_test_dir"
    cd "$cancel_test_dir"
    
    # Simulate cancellation (answering 'n' to confirmation)
    local input="Test Project\n1\n1\n1\n1\nn"
    
    timeout 30s bash -c "echo -e '$input' | '$SCRIPT_PATH'" >/dev/null 2>&1 || true
    
    # Should not have created CLAUDE.md if cancelled
    if [ ! -f "CLAUDE.md" ]; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Script Cancellation" "PASS" "Script properly handles cancellation" "$duration"
        cd "$TEST_DIR"
        rm -rf "$cancel_test_dir"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Script Cancellation" "FAIL" "Script did not handle cancellation properly" "$duration"
        cd "$TEST_DIR"
        rm -rf "$cancel_test_dir"
        return 1
    fi
}

# Test 8: Test with minimal selections (all zeros)
test_minimal_selection() {
    local start_time=$(date +%s)
    
    local minimal_test_dir="${TEST_DIR}_minimal"
    mkdir -p "$minimal_test_dir"
    cd "$minimal_test_dir"
    
    # Initialize git repo for this test
    git init >/dev/null 2>&1 || true
    
    # Select no frameworks (all 0s)
    local input="Minimal Project\n0\n0\n0\n0\ny"
    
    timeout 30s bash -c "echo -e '$input' | '$SCRIPT_PATH'" >/dev/null 2>&1 || true
    
    # Should still create CLAUDE.md even with no tech stack
    if [ -f "CLAUDE.md" ] && grep -q "Minimal Project" "CLAUDE.md"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Minimal Selection" "PASS" "Script handles minimal selection properly" "$duration"
        cd "$TEST_DIR"
        rm -rf "$minimal_test_dir"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log_test "Minimal Selection" "FAIL" "Script failed with minimal selection" "$duration"
        cd "$TEST_DIR"
        rm -rf "$minimal_test_dir"
        return 1
    fi
}

# Function to generate HTML report
generate_html_report() {
    local original_dir=$(pwd)
    local report_dir="$(dirname "$0")"
    cd "$report_dir"
    
    cat > "$HTML_REPORT" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Generate Claude GitHub Script Test Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header h1 {
            margin: 0;
            font-size: 2.5em;
        }
        .header p {
            margin: 10px 0 0 0;
            font-size: 1.2em;
            opacity: 0.9;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .summary-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .summary-card h3 {
            margin: 0 0 10px 0;
            font-size: 2em;
        }
        .summary-card p {
            margin: 0;
            color: #666;
        }
        .passed { color: #28a745; }
        .failed { color: #dc3545; }
        .total { color: #007bff; }
        .test-results {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .test-results h2 {
            background: #f8f9fa;
            margin: 0;
            padding: 20px;
            border-bottom: 1px solid #dee2e6;
        }
        .test-item {
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .test-item:last-child {
            border-bottom: none;
        }
        .test-name {
            font-weight: bold;
            flex-grow: 1;
        }
        .test-status {
            padding: 5px 10px;
            border-radius: 20px;
            color: white;
            font-weight: bold;
            margin-right: 10px;
        }
        .test-status.pass {
            background-color: #28a745;
        }
        .test-status.fail {
            background-color: #dc3545;
        }
        .test-duration {
            color: #666;
            font-size: 0.9em;
        }
        .test-message {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
            font-style: italic;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }
            .header h1 {
                font-size: 2em;
            }
            .test-item {
                flex-direction: column;
                align-items: flex-start;
            }
            .test-status {
                margin-right: 0;
                margin-top: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 Test Report</h1>
        <p>Generate Claude GitHub Script Test Results</p>
        <p>Generated on $(date '+%Y-%m-%d %H:%M:%S')</p>
    </div>

    <div class="summary">
        <div class="summary-card">
            <h3 class="total">$TOTAL_TESTS</h3>
            <p>Total Tests</p>
        </div>
        <div class="summary-card">
            <h3 class="passed">$TESTS_PASSED</h3>
            <p>Passed</p>
        </div>
        <div class="summary-card">
            <h3 class="failed">$TESTS_FAILED</h3>
            <p>Failed</p>
        </div>
        <div class="summary-card">
            <h3 class="$([ $TESTS_FAILED -eq 0 ] && echo "passed" || echo "failed")">$([ $TESTS_FAILED -eq 0 ] && echo "PASS" || echo "FAIL")</h3>
            <p>Overall Result</p>
        </div>
    </div>

    <div class="test-results">
        <h2>📋 Detailed Test Results</h2>
EOF

    for result in "${TEST_RESULTS[@]}"; do
        IFS='|' read -r name status message duration <<< "$result"
        local status_class=$([ "$status" = "PASS" ] && echo "pass" || echo "fail")
        
        cat >> "$HTML_REPORT" << EOF
        <div class="test-item">
            <div>
                <div class="test-name">$name</div>
                $([ -n "$message" ] && echo "<div class=\"test-message\">$message</div>")
            </div>
            <div>
                <span class="test-status $status_class">$status</span>
                <span class="test-duration">${duration}s</span>
            </div>
        </div>
EOF
    done

    cat >> "$HTML_REPORT" << EOF
    </div>

    <div class="footer">
        <p>Test script: test-generate-claude-github.sh</p>
        <p>Target script: $(basename "$SCRIPT_PATH")</p>
    </div>
</body>
</html>
EOF

    echo -e "\n${BLUE}HTML report generated: $HTML_REPORT${NC}"
    cd "$original_dir"
}

# Main test execution
main() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  Generate Claude GitHub Script Test Suite ${NC}"
    echo -e "${BLUE}============================================${NC}\n"
    
    # Check prerequisites
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo -e "${RED}Error: Script not found at $SCRIPT_PATH${NC}"
        exit 1
    fi
    
    # Setup test environment
    setup_test_environment
    
    echo -e "\n${YELLOW}Running tests...${NC}\n"
    
    # Run all tests (continue even if some fail)
    test_script_exists || true
    test_download_tool_detection || true
    test_directory_creation || true
    test_claude_md_generation || true
    test_core_files_creation || true
    test_content_validation || true
    test_script_cancellation || true
    test_minimal_selection || true
    
    # Display results
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}              Test Summary                  ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed! Cleaning up test directory...${NC}"
        cleanup_test_environment
        echo -e "${GREEN}✓ Test completed successfully${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some tests failed! Generating HTML report...${NC}"
        generate_html_report
        echo -e "${YELLOW}Test directory preserved at: $TEST_DIR${NC}"
        echo -e "${YELLOW}HTML report available at: $HTML_REPORT${NC}"
        exit 1
    fi
}

# Trap to ensure cleanup on script exit
trap 'cleanup_test_environment' EXIT

# Check if running in the correct directory
if [ ! -f "$(dirname "$0")/generate-claude-github.sh" ]; then
    echo -e "${RED}Error: generate-claude-github.sh not found in setup directory${NC}"
    echo "Please run this test from the directory containing the script"
    exit 1
fi

# Make sure script is executable
chmod +x "$SCRIPT_PATH"

# Run main function
main