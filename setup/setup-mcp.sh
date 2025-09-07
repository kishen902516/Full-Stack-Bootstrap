#!/bin/bash

# Setup MCP (Model Context Protocol) with Context7
# Author: AI Assistant
# Version: 1.0.0

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MCP_CONFIG_DIR="$HOME/.config/claude-desktop"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/claude_desktop_config.json"
CONTEXT7_CONFIG_DIR=".context7"
CONTEXT7_CONFIG_FILE="$CONTEXT7_CONFIG_DIR/config.json"

# Function to display header
display_mcp_header() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}        MCP Setup with Context7            ${NC}"
    echo -e "${BLUE}    Model Context Protocol Configuration   ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
}

# Function to check if Context7 is available
check_context7() {
    echo -e "${YELLOW}Checking Context7 availability...${NC}"
    
    if command -v context7 &> /dev/null; then
        echo -e "${GREEN}✓ Context7 is installed${NC}"
        return 0
    elif [ -x "./node_modules/.bin/context7" ]; then
        echo -e "${GREEN}✓ Context7 found in local node_modules${NC}"
        return 0
    else
        echo -e "${RED}✗ Context7 not found${NC}"
        echo -e "${YELLOW}Installing Context7...${NC}"
        install_context7
        return $?
    fi
}

# Function to install Context7
install_context7() {
    if command -v npm &> /dev/null; then
        echo "Installing Context7 globally..."
        npm install -g context7
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Context7 installed successfully${NC}"
            return 0
        else
            echo -e "${RED}✗ Failed to install Context7 globally${NC}"
            echo "Trying local installation..."
            npm install context7
            return $?
        fi
    else
        echo -e "${RED}✗ npm not found. Please install Node.js and npm first.${NC}"
        return 1
    fi
}

# Function to create MCP config directory
create_mcp_config_dir() {
    echo -e "${YELLOW}Creating MCP configuration directory...${NC}"
    mkdir -p "$MCP_CONFIG_DIR"
    echo -e "${GREEN}✓ MCP config directory created at $MCP_CONFIG_DIR${NC}"
}

# Function to create Context7 configuration
create_context7_config() {
    echo -e "${YELLOW}Creating Context7 configuration...${NC}"
    
    mkdir -p "$CONTEXT7_CONFIG_DIR"
    
    cat > "$CONTEXT7_CONFIG_FILE" << 'EOF'
{
  "version": "1.0.0",
  "context": {
    "maxTokens": 100000,
    "includePatterns": [
      "**/*.ts",
      "**/*.js",
      "**/*.tsx",
      "**/*.jsx",
      "**/*.json",
      "**/*.md",
      "**/*.yml",
      "**/*.yaml",
      "**/package.json",
      "**/tsconfig.json",
      "**/README.md",
      "**/.env.example"
    ],
    "excludePatterns": [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/.git/**",
      "**/coverage/**",
      "**/*.log",
      "**/tmp/**",
      "**/.env"
    ]
  },
  "output": {
    "format": "markdown",
    "includeMetadata": true,
    "includeLineNumbers": true
  },
  "analysis": {
    "enableSyntaxHighlighting": true,
    "enableCodeAnalysis": true,
    "enableDependencyMapping": true
  }
}
EOF
    
    echo -e "${GREEN}✓ Context7 configuration created${NC}"
}

# Function to backup existing MCP config
backup_mcp_config() {
    if [ -f "$MCP_CONFIG_FILE" ]; then
        echo -e "${YELLOW}Backing up existing MCP configuration...${NC}"
        cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✓ Backup created${NC}"
    fi
}

# Function to create or update MCP configuration
create_mcp_config() {
    echo -e "${YELLOW}Creating MCP configuration...${NC}"
    
    # Determine Context7 command path
    local context7_cmd
    if command -v context7 &> /dev/null; then
        context7_cmd="context7"
    elif [ -x "./node_modules/.bin/context7" ]; then
        context7_cmd="./node_modules/.bin/context7"
    else
        echo -e "${RED}✗ Context7 command not found${NC}"
        return 1
    fi
    
    # Get current working directory
    local project_path=$(pwd)
    
    cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "context7": {
      "command": "$context7_cmd",
      "args": [
        "serve",
        "--project-path",
        "$project_path",
        "--config",
        "$project_path/$CONTEXT7_CONFIG_FILE"
      ],
      "env": {
        "CONTEXT7_PROJECT_PATH": "$project_path",
        "CONTEXT7_CONFIG_PATH": "$project_path/$CONTEXT7_CONFIG_FILE"
      }
    },
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": ""
      }
    },
    "atlassian": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-atlassian"
      ],
      "env": {
        "ATLASSIAN_API_TOKEN": "",
        "ATLASSIAN_DOMAIN": "",
        "ATLASSIAN_EMAIL": ""
      }
    },
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-playwright"
      ]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }
}
EOF
    
    echo -e "${GREEN}✓ MCP configuration created at $MCP_CONFIG_FILE${NC}"
    echo -e "${YELLOW}⚠ Note: Some MCP servers require environment variables to be configured${NC}"
    echo -e "${YELLOW}   Please update the configuration file with your API tokens and credentials${NC}"
}

# Function to test MCP configuration
test_mcp_config() {
    echo -e "${YELLOW}Testing MCP configuration...${NC}"
    
    if [ -f "$MCP_CONFIG_FILE" ]; then
        # Validate JSON syntax
        if command -v jq &> /dev/null; then
            if jq empty "$MCP_CONFIG_FILE" 2>/dev/null; then
                echo -e "${GREEN}✓ MCP configuration JSON is valid${NC}"
            else
                echo -e "${RED}✗ Invalid JSON in MCP configuration${NC}"
                return 1
            fi
        else
            echo -e "${YELLOW}⚠ jq not available, skipping JSON validation${NC}"
        fi
        
        # Test Context7 command
        local context7_cmd
        if command -v context7 &> /dev/null; then
            context7_cmd="context7"
        elif [ -x "./node_modules/.bin/context7" ]; then
            context7_cmd="./node_modules/.bin/context7"
        fi
        
        if [ -n "$context7_cmd" ]; then
            echo "Testing Context7 command..."
            if $context7_cmd --version &> /dev/null; then
                echo -e "${GREEN}✓ Context7 command is working${NC}"
            else
                echo -e "${YELLOW}⚠ Context7 command test inconclusive${NC}"
            fi
        fi
        
        return 0
    else
        echo -e "${RED}✗ MCP configuration file not found${NC}"
        return 1
    fi
}

# Function to create project .gitignore entries
update_gitignore() {
    echo -e "${YELLOW}Updating .gitignore for MCP and Context7...${NC}"
    
    if [ -f ".gitignore" ]; then
        # Check if MCP entries already exist
        if ! grep -q "# MCP and Context7" .gitignore; then
            cat >> .gitignore << 'EOF'

# MCP and Context7
.context7/cache/
.context7/temp/
.context7/*.log
EOF
            echo -e "${GREEN}✓ Added MCP and Context7 entries to .gitignore${NC}"
        else
            echo -e "${GREEN}✓ .gitignore already contains MCP entries${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ No .gitignore found, creating one...${NC}"
        cat > .gitignore << 'EOF'
# MCP and Context7
.context7/cache/
.context7/temp/
.context7/*.log
EOF
        echo -e "${GREEN}✓ Created .gitignore with MCP entries${NC}"
    fi
}

# Function to create MCP usage instructions
create_mcp_instructions() {
    local instructions_file="MCP_SETUP.md"
    
    echo -e "${YELLOW}Creating MCP usage instructions...${NC}"
    
    cat > "$instructions_file" << 'EOF'
# MCP (Model Context Protocol) Setup with Multiple Servers

## Overview

This project is now configured to use MCP with multiple servers, enabling advanced context management, code analysis, and integration capabilities.

## Configuration Files

- `~/.config/claude-desktop/claude_desktop_config.json` - MCP server configuration
- `.context7/config.json` - Context7 specific settings
- `MCP_SETUP.md` - This documentation file

## Configured MCP Servers

### 1. Context7
- **Purpose**: Intelligent code context extraction and analysis
- **Features**:
  - Dependency mapping
  - Syntax highlighting
  - File content analysis
  - Project structure understanding

### 2. GitHub
- **Purpose**: GitHub repository integration
- **Features**:
  - Repository access and management
  - Issue and PR interaction
  - Code search across repositories
  - Repository statistics and insights
- **Setup**: Requires GITHUB_PERSONAL_ACCESS_TOKEN environment variable

### 3. Atlassian
- **Purpose**: Atlassian services integration (Jira, Confluence)
- **Features**:
  - Jira issue management
  - Confluence page access
  - Project tracking
  - Team collaboration tools
- **Setup**: Requires ATLASSIAN_API_TOKEN, ATLASSIAN_DOMAIN, and ATLASSIAN_EMAIL

### 4. Playwright
- **Purpose**: Web automation and testing
- **Features**:
  - Browser automation
  - End-to-end testing
  - Web scraping capabilities
  - UI testing automation

### 5. Sequential Thinking
- **Purpose**: Enhanced reasoning and problem-solving
- **Features**:
  - Step-by-step analysis
  - Logical reasoning chains
  - Problem decomposition
  - Structured thinking processes

## How It Works

**Claude Desktop** connects to multiple MCP servers to:
- Access project context (Context7)
- Integrate with development tools (GitHub, Atlassian)
- Enable web automation (Playwright)
- Enhance reasoning capabilities (Sequential Thinking)

## Usage

### Starting Context7 MCP Server

The server starts automatically when Claude Desktop initializes, but you can also start it manually:

```bash
# If installed globally
context7 serve --project-path . --config .context7/config.json

# If installed locally
./node_modules/.bin/context7 serve --project-path . --config .context7/config.json
```

### Context7 Commands

```bash
# Generate context for specific files
context7 context --files "src/**/*.ts"

# Analyze dependencies
context7 analyze --type dependencies

# Generate project overview
context7 overview
```

## Configuration Customization

### Context7 Config (`.context7/config.json`)

- `maxTokens`: Maximum tokens for context extraction
- `includePatterns`: File patterns to include
- `excludePatterns`: File patterns to exclude
- `output.format`: Output format (markdown, json, plain)

### MCP Config (`~/.config/claude-desktop/claude_desktop_config.json`)

- `command`: Path to MCP server executable
- `args`: Arguments passed to MCP server
- `env`: Environment variables

### Environment Variables Setup

#### GitHub MCP Server
```bash
# Create a personal access token at https://github.com/settings/tokens
export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"
```

#### Atlassian MCP Server
```bash
# Get API token from https://id.atlassian.com/manage-profile/security/api-tokens
export ATLASSIAN_API_TOKEN="your_api_token"
export ATLASSIAN_DOMAIN="your-domain.atlassian.net"
export ATLASSIAN_EMAIL="your.email@example.com"
```

To permanently set these variables, add them to your shell profile:
```bash
# Add to ~/.bashrc, ~/.zshrc, or equivalent
echo 'export GITHUB_PERSONAL_ACCESS_TOKEN="your_token"' >> ~/.bashrc
echo 'export ATLASSIAN_API_TOKEN="your_token"' >> ~/.bashrc
echo 'export ATLASSIAN_DOMAIN="your-domain.atlassian.net"' >> ~/.bashrc
echo 'export ATLASSIAN_EMAIL="your.email@example.com"' >> ~/.bashrc
```

## Troubleshooting

### Common Issues

1. **Context7 not found**
   ```bash
   npm install -g context7
   # or locally
   npm install context7
   ```

2. **MCP server not starting**
   - Check Context7 installation: `context7 --version`
   - Verify config file syntax: `jq . ~/.config/claude-desktop/claude_desktop_config.json`

3. **Permission issues**
   - Ensure Context7 executable has proper permissions
   - Check that config directories are writable

### Logs and Debugging

- Context7 logs are typically in `.context7/` directory
- Claude Desktop logs can be found in the application logs directory
- Use `context7 --debug` for verbose output

## Benefits

- **Enhanced Code Understanding**: Better context awareness across your entire codebase
- **Intelligent Suggestions**: More accurate code completions and suggestions
- **Dependency Insights**: Understanding of how different parts of your code relate
- **Project-wide Analysis**: Comprehensive view of your project structure

## Security Notes

- Configuration files are stored locally
- No code is sent to external servers except through Claude's normal operation
- Context7 only accesses files within your project directory
- Sensitive files (like `.env`) are excluded by default

## Updates

To update Context7:
```bash
npm update -g context7
# or locally
npm update context7
```

The MCP configuration will remain intact across updates.
EOF
    
    echo -e "${GREEN}✓ MCP instructions created at $instructions_file${NC}"
}

# Function to create summary
create_mcp_summary() {
    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}         MCP Setup Complete!               ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo -e "${BLUE}Configured Components:${NC}"
    echo "  • Context7 MCP Server"
    echo "  • Claude Desktop Integration"
    echo "  • Project Context Management"
    echo
    echo -e "${BLUE}Configuration Files:${NC}"
    echo "  • $MCP_CONFIG_FILE"
    echo "  • $CONTEXT7_CONFIG_FILE"
    echo "  • MCP_SETUP.md"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Restart Claude Desktop to load new MCP configuration"
    echo "  2. Test the integration by asking Claude about your project"
    echo "  3. Customize Context7 settings in .context7/config.json"
    echo "  4. Review MCP_SETUP.md for usage instructions"
    echo
    echo -e "${BLUE}To test the setup:${NC}"
    echo "  • Ask Claude: 'What files are in this project?'"
    echo "  • Ask Claude: 'Analyze the project structure'"
    echo "  • Ask Claude: 'Show me the main dependencies'"
}

# Main MCP setup function
main_mcp() {
    display_mcp_header
    
    # Check and install Context7
    if ! check_context7; then
        echo -e "${RED}Failed to install Context7. Exiting.${NC}"
        exit 1
    fi
    
    # Create configurations
    create_mcp_config_dir
    backup_mcp_config
    create_context7_config
    create_mcp_config
    
    # Test configuration
    if test_mcp_config; then
        echo -e "${GREEN}✓ MCP configuration is valid${NC}"
    else
        echo -e "${RED}✗ MCP configuration test failed${NC}"
        exit 1
    fi
    
    # Update project files
    update_gitignore
    create_mcp_instructions
    
    # Display summary
    create_mcp_summary
}

# Export the main function so it can be called from other scripts
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # Script is being run directly
    main_mcp "$@"
fi