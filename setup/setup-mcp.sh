#!/bin/bash

# MCP (Model Context Protocol) Setup Script for Claude Code
# Author: AI Assistant
# Version: 1.0.0

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration will be set in main function based on project directory
CLAUDE_CODE_CONFIG_DIR=""
MCP_CONFIG_FILE=""
CONFIG_YML_FILE=""

# Global variables for config values
GITHUB_TOKEN=""
ATLASSIAN_DOMAIN=""
ATLASSIAN_EMAIL=""
ATLASSIAN_TOKEN=""

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}     MCP Configuration for Claude Code     ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
}

# Function to create config.yml if it doesn't exist
create_config_template() {
    local config_template="$1"
    local config_file="$2"
    
    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}Creating config.yml from template...${NC}"
        if [ -f "$config_template" ]; then
            cp "$config_template" "$config_file"
            echo -e "${GREEN}✓ Created config.yml - please edit it with your API tokens${NC}"
            return 0
        else
            echo -e "${RED}✗ Template file not found: $config_template${NC}"
            return 1
        fi
    fi
    return 0
}

# Function to parse YAML config file
parse_config_yml() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}⚠ Config file not found: $config_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Reading configuration from config.yml...${NC}"
    
    # Parse GitHub token
    GITHUB_TOKEN=$(grep -A 5 "^github:" "$config_file" | grep "personal_access_token:" | sed 's/.*personal_access_token:[[:space:]]*["\x27]\?\([^"\x27]*\)["\x27]\?.*/\1/' | tr -d ' ')
    
    # Parse Atlassian config
    ATLASSIAN_DOMAIN=$(grep -A 10 "^atlassian:" "$config_file" | grep "domain:" | sed 's/.*domain:[[:space:]]*["\x27]\?\([^"\x27]*\)["\x27]\?.*/\1/' | tr -d ' ')
    ATLASSIAN_EMAIL=$(grep -A 10 "^atlassian:" "$config_file" | grep "email:" | sed 's/.*email:[[:space:]]*["\x27]\?\([^"\x27]*\)["\x27]\?.*/\1/' | tr -d ' ')
    ATLASSIAN_TOKEN=$(grep -A 10 "^atlassian:" "$config_file" | grep "api_token:" | sed 's/.*api_token:[[:space:]]*["\x27]\?\([^"\x27]*\)["\x27]\?.*/\1/' | tr -d ' ')
    
    # Clean up placeholder values
    [ "$GITHUB_TOKEN" = "your_github_token_here" ] && GITHUB_TOKEN=""
    [ "$ATLASSIAN_DOMAIN" = "your_company.atlassian.net" ] && ATLASSIAN_DOMAIN=""
    [ "$ATLASSIAN_EMAIL" = "your_email@example.com" ] && ATLASSIAN_EMAIL=""
    [ "$ATLASSIAN_TOKEN" = "your_atlassian_token_here" ] && ATLASSIAN_TOKEN=""
    
    # Display what was found (without showing actual tokens)
    echo -e "  ${GREEN}✓ GitHub token:${NC} $([ -n "$GITHUB_TOKEN" ] && echo "configured" || echo "not configured")"
    echo -e "  ${GREEN}✓ Atlassian domain:${NC} $([ -n "$ATLASSIAN_DOMAIN" ] && echo "$ATLASSIAN_DOMAIN" || echo "not configured")"
    echo -e "  ${GREEN}✓ Atlassian email:${NC} $([ -n "$ATLASSIAN_EMAIL" ] && echo "$ATLASSIAN_EMAIL" || echo "not configured")"
    echo -e "  ${GREEN}✓ Atlassian token:${NC} $([ -n "$ATLASSIAN_TOKEN" ] && echo "configured" || echo "not configured")"
    
    return 0
}

# Function to check if npm is installed
check_npm() {
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}Error: npm is not installed.${NC}"
        echo "Please install Node.js and npm to continue."
        exit 1
    fi
    echo -e "${GREEN}✓ npm is available${NC}"
}

# Function to check if required packages are installed globally
check_and_install_packages() {
    echo -e "${YELLOW}Checking and installing required MCP packages...${NC}"
    
    local packages=(
        "@modelcontextprotocol/server-github"
        "@context7/mcp-server"
        "@modelcontextprotocol/server-playwright"
        "@modelcontextprotocol/server-atlassian"
    )
    
    for package in "${packages[@]}"; do
        echo -e "  Checking $package..."
        if npm list -g "$package" &> /dev/null; then
            echo -e "    ${GREEN}✓ $package is already installed${NC}"
        else
            echo -e "    ${YELLOW}Installing $package globally...${NC}"
            if npm install -g "$package"; then
                echo -e "    ${GREEN}✓ $package installed successfully${NC}"
            else
                echo -e "    ${RED}✗ Failed to install $package${NC}"
                echo -e "    ${YELLOW}Please install manually: npm install -g $package${NC}"
            fi
        fi
    done
}

# Function to create MCP config directory in project
create_config_directory() {
    echo -e "${YELLOW}Creating MCP configuration directory in project...${NC}"
    
    if [ ! -d "$CLAUDE_CODE_CONFIG_DIR" ]; then
        mkdir -p "$CLAUDE_CODE_CONFIG_DIR"
        echo -e "${GREEN}✓ Created directory: $CLAUDE_CODE_CONFIG_DIR${NC}"
    else
        echo -e "${GREEN}✓ Configuration directory already exists${NC}"
    fi
}

# Function to backup existing MCP configuration
backup_existing_config() {
    if [ -f "$MCP_CONFIG_FILE" ]; then
        local backup_file="${MCP_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$MCP_CONFIG_FILE" "$backup_file"
        echo -e "${YELLOW}⚠ Backed up existing configuration to: $backup_file${NC}"
    fi
}


# Function to generate MCP configuration
generate_mcp_config() {
    local project_dir=$1
    
    echo -e "\n${YELLOW}Generating MCP configuration...${NC}"
    
    # Create the base configuration structure
    cat > "$MCP_CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
EOF

    # Add GitHub token if provided
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "        \"GITHUB_PERSONAL_ACCESS_TOKEN\": \"$GITHUB_TOKEN\"" >> "$MCP_CONFIG_FILE"
    else
        echo "        \"GITHUB_PERSONAL_ACCESS_TOKEN\": \"your_github_token_here\"" >> "$MCP_CONFIG_FILE"
    fi

    cat >> "$MCP_CONFIG_FILE" << EOF
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp-server"],
      "env": {
        "CONTEXT7_PROJECT_PATH": "$project_dir"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    },
EOF

    # Add Atlassian configuration if provided
    if [ -n "$ATLASSIAN_DOMAIN" ]; then
        cat >> "$MCP_CONFIG_FILE" << EOF
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-atlassian"],
      "env": {
        "ATLASSIAN_DOMAIN": "$ATLASSIAN_DOMAIN",
        "ATLASSIAN_EMAIL": "$ATLASSIAN_EMAIL",
        "ATLASSIAN_API_TOKEN": "$ATLASSIAN_TOKEN"
      }
    }
EOF
    else
        cat >> "$MCP_CONFIG_FILE" << 'EOF'
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-atlassian"],
      "env": {
        "ATLASSIAN_DOMAIN": "your_domain.atlassian.net",
        "ATLASSIAN_EMAIL": "your_email@example.com",
        "ATLASSIAN_API_TOKEN": "your_atlassian_token_here"
      }
    }
EOF
    fi

    cat >> "$MCP_CONFIG_FILE" << 'EOF'
  }
}
EOF
    
    echo -e "${GREEN}✓ MCP configuration generated at: $MCP_CONFIG_FILE${NC}"
}

# Function to validate configuration
validate_config() {
    echo -e "\n${YELLOW}Validating configuration...${NC}"
    
    if [ -f "$MCP_CONFIG_FILE" ]; then
        # Check if the JSON is valid
        if command -v node &> /dev/null; then
            if node -e "JSON.parse(require('fs').readFileSync('$MCP_CONFIG_FILE', 'utf8'))" 2>/dev/null; then
                echo -e "${GREEN}✓ Configuration JSON is valid${NC}"
            else
                echo -e "${RED}✗ Configuration JSON is invalid${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}⚠ Node.js not available to validate JSON${NC}"
        fi
        
        # Check file permissions
        if [ -r "$MCP_CONFIG_FILE" ]; then
            echo -e "${GREEN}✓ Configuration file is readable${NC}"
        else
            echo -e "${RED}✗ Configuration file is not readable${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Configuration file was not created${NC}"
        return 1
    fi
}

# Function to display usage instructions
display_usage_instructions() {
    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}      MCP Configuration Complete!          ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo -e "${BLUE}Configuration Details:${NC}"
    echo "  • Config file: $MCP_CONFIG_FILE"
    echo "  • Project path: ${1:-'Not specified'}"
    echo
    echo -e "${BLUE}Configured MCP Servers:${NC}"
    echo "  • GitHub - Repository and issue management"
    echo "  • Context7 - Advanced code context analysis"
    echo "  • Playwright - Web automation and testing"
    echo "  • Atlassian - Jira and Confluence integration"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Copy the MCP configuration to Claude Code's config directory:"
    echo "     mkdir -p ~/.config/claude-code"
    echo "     cp $MCP_CONFIG_FILE ~/.config/claude-code/"
    echo "  2. Restart Claude Code to load the new MCP configuration"
    echo "  3. Verify MCP servers are working by testing commands"
    echo "  4. Update tokens/credentials in the config file if needed"
    echo
    echo -e "${BLUE}Testing MCP Servers:${NC}"
    echo "  • GitHub: Ask Claude to list repositories or issues"
    echo "  • Context7: Ask Claude to analyze your codebase structure"
    echo "  • Playwright: Ask Claude to automate web browser tasks"
    echo "  • Atlassian: Ask Claude to search Jira issues or Confluence pages"
    echo
    if [ -n "$GITHUB_TOKEN" ] || [ -n "$ATLASSIAN_DOMAIN" ]; then
        echo -e "${GREEN}✓ API credentials configured from config.yml${NC}"
    else
        echo -e "${YELLOW}⚠ Edit config.yml to configure API credentials for full functionality${NC}"
    fi
}

# Function to handle errors
handle_error() {
    echo -e "\n${RED}============================================${NC}"
    echo -e "${RED}           Setup Failed!                   ${NC}"
    echo -e "${RED}============================================${NC}"
    echo
    echo -e "${YELLOW}Common issues and solutions:${NC}"
    echo "  • npm not installed: Install Node.js from https://nodejs.org"
    echo "  • Permission denied: Try running with appropriate permissions"
    echo "  • Network issues: Check your internet connection"
    echo "  • Package installation failed: Try running: npm cache clean --force"
    echo
    echo -e "${BLUE}For help, please check:${NC}"
    echo "  • Claude Code documentation"
    echo "  • MCP server documentation on GitHub"
    echo
    exit 1
}

# Main function
main() {
    # Get project directory from command line argument
    local project_dir=$1
    
    if [ -z "$project_dir" ]; then
        echo -e "${YELLOW}No project directory specified. Using current directory: $(pwd)${NC}"
        project_dir=$(pwd)
    fi
    
    # Validate project directory
    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Project directory does not exist: $project_dir${NC}"
        echo "Please provide a valid project directory path."
        exit 1
    fi
    
    # Convert to absolute path
    project_dir=$(realpath "$project_dir" 2>/dev/null || readlink -f "$project_dir" 2>/dev/null || echo "$project_dir")
    
    # Set configuration paths based on project directory
    CLAUDE_CODE_CONFIG_DIR="$project_dir/.claude-code"
    MCP_CONFIG_FILE="$CLAUDE_CODE_CONFIG_DIR/mcp_servers.json"
    CONFIG_YML_FILE="$project_dir/setup/config.yml"
    
    display_header
    
    echo -e "${BLUE}Project Directory:${NC} $project_dir"
    echo
    
    # Trap errors
    trap handle_error ERR
    
    # Main setup steps
    check_npm
    echo
    
    check_and_install_packages
    echo
    
    create_config_directory
    echo
    
    backup_existing_config
    echo
    
    # Create and read config.yml
    create_config_template "$project_dir/setup/config.yml.template" "$CONFIG_YML_FILE"
    echo
    
    if [ -f "$CONFIG_YML_FILE" ]; then
        parse_config_yml "$CONFIG_YML_FILE"
    else
        echo -e "${YELLOW}⚠ Config file not found. Using default configuration.${NC}"
    fi
    echo
    
    # Generate configuration
    generate_mcp_config "$project_dir"
    
    # Validate configuration
    validate_config
    
    # Display completion message
    display_usage_instructions "$project_dir"
    
    echo
    echo -e "${GREEN}MCP setup complete! 🚀${NC}"
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed, run main function
    main "$@"
fi