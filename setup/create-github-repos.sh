#!/bin/bash

# Create GitHub repositories for polyrepo architecture
# Author: AI Assistant
# Version: 1.0.0 - Polyrepo Generator

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_ORG=""
CONTRACTS_REPO_SUFFIX="-contracts"
INITIAL_BRANCH="initial-setup"

# Repository types
declare -A REPO_TYPES=(
    ["service"]="Backend service"
    ["webapp"]="Frontend web application"
    ["job"]="Background job/worker"
    ["mobile"]="Mobile application"
    ["lib"]="Shared library"
)

# Function to display header
display_header() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}     GitHub Polyrepo Architecture Setup    ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
        echo "Please install it: https://cli.github.com/"
        echo "On Windows: winget install --id GitHub.cli"
        echo "On macOS: brew install gh"
        echo "On Linux: sudo apt install gh"
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}Error: You are not authenticated with GitHub CLI.${NC}"
        echo "Please run: gh auth login"
        exit 1
    fi
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: Git is not installed.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisites checked${NC}"
}

# Function to get project configuration
get_project_config() {
    echo -e "\n${BLUE}Project Configuration:${NC}"
    
    # Get project name
    read -p "Enter project name (e.g., 'my-awesome-project'): " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}Project name is required${NC}"
        exit 1
    fi
    
    # Suggest GitHub repo name (convert to lowercase, replace spaces with hyphens)
    SUGGESTED_REPO_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
    read -p "GitHub repository base name [$SUGGESTED_REPO_NAME]: " REPO_BASE_NAME
    REPO_BASE_NAME=${REPO_BASE_NAME:-$SUGGESTED_REPO_NAME}
    
    # Get organization (optional)
    echo
    echo -e "${CYAN}Organization/User account:${NC}"
    CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")
    if [ -n "$CURRENT_USER" ]; then
        echo "Current user: $CURRENT_USER"
        echo "Leave empty to create repos under your personal account"
    fi
    read -p "Enter organization name (optional): " GITHUB_ORG
    
    if [ -n "$GITHUB_ORG" ]; then
        REPO_PREFIX="$GITHUB_ORG"
    else
        REPO_PREFIX="$CURRENT_USER"
    fi
    
    echo
    echo -e "${CYAN}Repository visibility:${NC}"
    echo "1) Private (recommended)"
    echo "2) Public"
    read -p "Select visibility (1-2) [1]: " visibility_choice
    visibility_choice=${visibility_choice:-1}
    
    if [ "$visibility_choice" = "2" ]; then
        REPO_VISIBILITY="public"
    else
        REPO_VISIBILITY="private"
    fi
}

# Function to select repositories to create
select_repositories() {
    echo -e "\n${BLUE}Select repositories to create:${NC}"
    
    # Always create contracts repo
    CONTRACTS_REPO="${REPO_BASE_NAME}${CONTRACTS_REPO_SUFFIX}"
    echo -e "${GREEN}✓ Contracts repo: $CONTRACTS_REPO (always created)${NC}"
    
    # Track selected repos
    declare -g -A SELECTED_REPOS
    SELECTED_REPOS["contracts"]="$CONTRACTS_REPO"
    
    echo
    echo "Select additional repositories:"
    
    # Service repositories
    echo -e "\n${CYAN}Backend Services:${NC}"
    read -p "API service repo name (e.g., ${REPO_BASE_NAME}-api) [skip with enter]: " api_repo
    if [ -n "$api_repo" ]; then
        SELECTED_REPOS["api-service"]="$api_repo"
    fi
    
    read -p "Auth service repo name (e.g., ${REPO_BASE_NAME}-auth) [skip with enter]: " auth_repo
    if [ -n "$auth_repo" ]; then
        SELECTED_REPOS["auth-service"]="$auth_repo"
    fi
    
    read -p "Additional service repo name [skip with enter]: " additional_service
    if [ -n "$additional_service" ]; then
        SELECTED_REPOS["additional-service"]="$additional_service"
    fi
    
    # Web applications
    echo -e "\n${CYAN}Frontend Applications:${NC}"
    read -p "Web app repo name (e.g., ${REPO_BASE_NAME}-web) [skip with enter]: " web_repo
    if [ -n "$web_repo" ]; then
        SELECTED_REPOS["webapp"]="$web_repo"
    fi
    
    read -p "Admin dashboard repo name (e.g., ${REPO_BASE_NAME}-admin) [skip with enter]: " admin_repo
    if [ -n "$admin_repo" ]; then
        SELECTED_REPOS["admin-webapp"]="$admin_repo"
    fi
    
    # Jobs/Workers
    echo -e "\n${CYAN}Background Jobs:${NC}"
    read -p "Background job repo name (e.g., ${REPO_BASE_NAME}-worker) [skip with enter]: " worker_repo
    if [ -n "$worker_repo" ]; then
        SELECTED_REPOS["worker"]="$worker_repo"
    fi
    
    # Mobile apps (optional)
    echo -e "\n${CYAN}Mobile Applications (optional):${NC}"
    read -p "Mobile app repo name (e.g., ${REPO_BASE_NAME}-mobile) [skip with enter]: " mobile_repo
    if [ -n "$mobile_repo" ]; then
        SELECTED_REPOS["mobile"]="$mobile_repo"
    fi
    
    # Option for frontend platform monorepo
    echo -e "\n${CYAN}Frontend Platform Monorepo (Nx/Lerna):${NC}"
    echo "Create if you have multiple Angular/React apps sharing lots of UI"
    read -p "Frontend platform repo name [skip with enter]: " platform_repo
    if [ -n "$platform_repo" ]; then
        SELECTED_REPOS["frontend-platform"]="$platform_repo"
    fi
}

# Function to confirm configuration
confirm_configuration() {
    echo -e "\n${YELLOW}Configuration Summary:${NC}"
    echo "Project: $PROJECT_NAME"
    echo "Base name: $REPO_BASE_NAME"
    echo "Owner: $REPO_PREFIX"
    echo "Visibility: $REPO_VISIBILITY"
    echo "Initial branch: $INITIAL_BRANCH"
    echo
    echo -e "${CYAN}Repositories to create:${NC}"
    
    for key in "${!SELECTED_REPOS[@]}"; do
        repo_name="${SELECTED_REPOS[$key]}"
        repo_url="https://github.com/$REPO_PREFIX/$repo_name"
        echo "  • $repo_name ($key) - $repo_url"
    done
    
    echo
    read -p "Proceed with creating these repositories? (y/n): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${RED}Repository creation cancelled.${NC}"
        exit 0
    fi
}

# Function to create repository with initial setup
create_repository() {
    local repo_type=$1
    local repo_name=$2
    
    echo -e "\n${YELLOW}Creating repository: $repo_name...${NC}"
    
    # Create GitHub repository
    local visibility_flag="--$REPO_VISIBILITY"
    if [ -n "$GITHUB_ORG" ]; then
        gh repo create "$GITHUB_ORG/$repo_name" $visibility_flag --description "Part of $PROJECT_NAME polyrepo architecture"
    else
        gh repo create "$repo_name" $visibility_flag --description "Part of $PROJECT_NAME polyrepo architecture"
    fi
    
    # Create local directory and initialize
    local temp_dir="/tmp/$repo_name-setup"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    # Initialize git repo
    git init
    git branch -M "$INITIAL_BRANCH"
    
    # Create appropriate initial files based on repo type
    create_initial_files "$repo_type" "$repo_name"
    
    # Add remote and push
    if [ -n "$GITHUB_ORG" ]; then
        git remote add origin "https://github.com/$GITHUB_ORG/$repo_name.git"
    else
        git remote add origin "https://github.com/$REPO_PREFIX/$repo_name.git"
    fi
    
    git add .
    git commit -m "🚀 Initial repository setup for $PROJECT_NAME

Part of polyrepo architecture setup.
Repository type: $repo_type

🤖 Generated with Full-Stack-Bootstrap"
    
    git push -u origin "$INITIAL_BRANCH"
    
    echo -e "${GREEN}✓ Repository created: $repo_name${NC}"
    
    # Return to original directory
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Function to create initial files based on repository type
create_initial_files() {
    local repo_type=$1
    local repo_name=$2
    
    case "$repo_type" in
        "contracts")
            create_contracts_repo_files "$repo_name"
            ;;
        "api-service"|"auth-service"|"additional-service")
            create_service_repo_files "$repo_name" "$repo_type"
            ;;
        "webapp"|"admin-webapp")
            create_webapp_repo_files "$repo_name" "$repo_type"
            ;;
        "worker")
            create_worker_repo_files "$repo_name"
            ;;
        "mobile")
            create_mobile_repo_files "$repo_name"
            ;;
        "frontend-platform")
            create_platform_repo_files "$repo_name"
            ;;
    esac
}

# Function to create contracts repository files
create_contracts_repo_files() {
    local repo_name=$1
    
    cat > README.md << EOF
# $PROJECT_NAME - Contracts

Shared contracts, API specifications, and type definitions for the $PROJECT_NAME ecosystem.

## Contents

- **API Contracts**: OpenAPI/Swagger specifications
- **Protocol Buffers**: gRPC service definitions
- **Type Definitions**: Shared TypeScript interfaces and types
- **Design Tokens**: Shared design system tokens
- **Schemas**: JSON schemas for data validation

## Structure

\`\`\`
contracts/
├── api/                 # REST API specifications
│   ├── openapi/        # OpenAPI 3.0 specs
│   └── schemas/        # JSON schemas
├── grpc/               # gRPC protocol definitions
│   └── proto/          # .proto files
├── types/              # Shared type definitions
│   ├── typescript/     # TypeScript interfaces
│   └── json/           # JSON type definitions
├── design-tokens/      # Design system tokens
│   ├── colors.json
│   ├── typography.json
│   └── spacing.json
└── docs/               # Contract documentation
```

## Usage

This repository publishes versioned packages:

- \`@$REPO_BASE_NAME/api-types\` - TypeScript API types
- \`@$REPO_BASE_NAME/design-tokens\` - Design system tokens
- \`@$REPO_BASE_NAME/schemas\` - Validation schemas

## Publishing

Contracts are automatically published to npm registry on tag creation:

\`\`\`bash
git tag v1.0.0
git push origin v1.0.0
\`\`\`

## Related Repositories

Part of the $PROJECT_NAME polyrepo architecture:

$(for key in "${!SELECTED_REPOS[@]}"; do
    if [ "$key" != "contracts" ]; then
        echo "- [${SELECTED_REPOS[$key]}](https://github.com/$REPO_PREFIX/${SELECTED_REPOS[$key]})"
    fi
done)
EOF

    # Create directory structure
    mkdir -p contracts/{api/{openapi,schemas},grpc/proto,types/{typescript,json},design-tokens,docs}
    
    # Create package.json for publishing
    cat > package.json << EOF
{
  "name": "@$REPO_BASE_NAME/contracts",
  "version": "0.1.0",
  "description": "Shared contracts for $PROJECT_NAME",
  "main": "index.js",
  "types": "index.d.ts",
  "scripts": {
    "build": "npm run build:types && npm run build:tokens",
    "build:types": "tsc",
    "build:tokens": "echo 'Build design tokens'",
    "validate": "npm run validate:openapi && npm run validate:schemas",
    "validate:openapi": "swagger-codegen validate -i contracts/api/openapi/**/*.yaml || true",
    "validate:schemas": "ajv compile -s contracts/api/schemas/**/*.json || true"
  },
  "keywords": ["contracts", "api", "types", "polyrepo"],
  "license": "MIT",
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  }
}
EOF

    # Create basic TypeScript config
    cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./contracts/types/typescript",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["contracts/types/typescript/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

    # Create example files
    cat > contracts/types/typescript/common.ts << EOF
// Common type definitions shared across all services
export interface ApiResponse<T = any> {
  data?: T;
  error?: ApiError;
  meta?: ResponseMeta;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

export interface ResponseMeta {
  pagination?: PaginationMeta;
  timestamp: string;
  requestId: string;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}
EOF

    cat > contracts/design-tokens/colors.json << EOF
{
  "colors": {
    "primary": {
      "50": "#f0f9ff",
      "500": "#3b82f6",
      "900": "#1e3a8a"
    },
    "gray": {
      "50": "#f9fafb",
      "500": "#6b7280",
      "900": "#111827"
    }
  }
}
EOF

    # Create GitHub Actions for publishing
    mkdir -p .github/workflows
    cat > .github/workflows/publish.yml << EOF
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
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      
      - run: npm ci
      - run: npm run build
      - run: npm run validate
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: \${{ secrets.NPM_TOKEN }}
EOF
}

# Function to create service repository files
create_service_repo_files() {
    local repo_name=$1
    local service_type=$2
    
    local service_description
    case "$service_type" in
        "api-service") service_description="Main API service" ;;
        "auth-service") service_description="Authentication and authorization service" ;;
        *) service_description="Backend service" ;;
    esac
    
    cat > README.md << EOF
# $PROJECT_NAME - $(echo $service_type | tr '-' ' ' | sed 's/\b\w/\U&/g')

$service_description for the $PROJECT_NAME ecosystem.

## Architecture

This service follows Clean Architecture principles:

- **Domain Layer**: Business entities and rules
- **Application Layer**: Use cases and business logic
- **Infrastructure Layer**: Database, external services
- **Presentation Layer**: Controllers, middleware

## Structure

\`\`\`
src/
├── domain/           # Business logic (no framework dependencies)
├── application/      # Use cases and DTOs
├── infrastructure/   # Database, external services
├── presentation/     # Controllers, routes, middleware
└── shared/          # Common utilities
\`\`\`

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env

# Run database migrations
npm run migrate

# Start development server
npm run dev
\`\`\`

## Dependencies

- **Contracts**: [@$REPO_BASE_NAME/contracts](https://github.com/$REPO_PREFIX/$CONTRACTS_REPO)

## Related Services

Part of the $PROJECT_NAME polyrepo architecture:

$(for key in "${!SELECTED_REPOS[@]}"; do
    if [ "$key" != "$service_type" ]; then
        echo "- [${SELECTED_REPOS[$key]}](https://github.com/$REPO_PREFIX/${SELECTED_REPOS[$key]})"
    fi
done)
EOF

    # Create basic package.json for Node.js service
    cat > package.json << EOF
{
  "name": "$repo_name",
  "version": "0.1.0",
  "description": "$service_description for $PROJECT_NAME",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.ts",
    "typecheck": "tsc --noEmit",
    "migrate": "echo 'Run database migrations'"
  },
  "dependencies": {
    "@$REPO_BASE_NAME/contracts": "^0.1.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "eslint": "^8.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0"
  },
  "keywords": ["service", "api", "polyrepo"],
  "license": "MIT"
}
EOF

    # Create basic structure
    mkdir -p src/{domain,application,infrastructure,presentation,shared}
    
    # Create example index file
    cat > src/index.ts << EOF
// $service_description entry point
import { createServer } from './presentation/server';

const PORT = process.env.PORT || 3000;

async function main() {
  const server = createServer();
  
  server.listen(PORT, () => {
    console.log(\`🚀 $service_description running on port \${PORT}\`);
  });
}

main().catch(console.error);
EOF

    # Create Docker files
    create_service_docker_files "$repo_name"
}

# Function to create webapp repository files
create_webapp_repo_files() {
    local repo_name=$1
    local webapp_type=$2
    
    local app_description
    case "$webapp_type" in
        "webapp") app_description="Frontend web application" ;;
        "admin-webapp") app_description="Admin dashboard" ;;
    esac
    
    cat > README.md << EOF
# $PROJECT_NAME - $(echo $webapp_type | tr '-' ' ' | sed 's/\b\w/\U&/g')

$app_description for the $PROJECT_NAME ecosystem.

## Tech Stack

- **Framework**: Angular/React (to be determined)
- **Language**: TypeScript
- **Styling**: Tailwind CSS / Styled Components
- **State Management**: NgRx / Redux Toolkit
- **Testing**: Jest + Testing Library

## Structure

\`\`\`
src/
├── app/             # Application modules
├── components/      # Reusable UI components
├── pages/           # Page components
├── services/        # API services
├── store/           # State management
├── types/           # Type definitions
└── utils/           # Utility functions
\`\`\`

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run tests
npm run test
\`\`\`

## Dependencies

- **Contracts**: [@$REPO_BASE_NAME/contracts](https://github.com/$REPO_PREFIX/$CONTRACTS_REPO) - Shared types and design tokens

## Related Services

Part of the $PROJECT_NAME polyrepo architecture:

$(for key in "${!SELECTED_REPOS[@]}"; do
    if [ "$key" != "$webapp_type" ]; then
        echo "- [${SELECTED_REPOS[$key]}](https://github.com/$REPO_PREFIX/${SELECTED_REPOS[$key]})"
    fi
done)
EOF

    # Create basic package.json for webapp
    cat > package.json << EOF
{
  "name": "$repo_name",
  "version": "0.1.0",
  "description": "$app_description for $PROJECT_NAME",
  "scripts": {
    "dev": "echo 'Start development server'",
    "build": "echo 'Build for production'",
    "preview": "echo 'Preview production build'",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.{ts,tsx}",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@$REPO_BASE_NAME/contracts": "^0.1.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "eslint": "^8.0.0"
  },
  "keywords": ["webapp", "frontend", "polyrepo"],
  "license": "MIT"
}
EOF

    # Create Docker files
    create_webapp_docker_files "$repo_name"
}

# Function to create worker repository files
create_worker_repo_files() {
    local repo_name=$1
    
    cat > README.md << EOF
# $PROJECT_NAME - Background Worker

Background job processing service for the $PROJECT_NAME ecosystem.

## Responsibilities

- Process background jobs and tasks
- Handle scheduled operations
- Send notifications and emails
- Data processing and analytics

## Tech Stack

- **Runtime**: Node.js
- **Queue**: Redis/Bull/BullMQ
- **Language**: TypeScript
- **Database**: PostgreSQL (shared)

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env

# Start worker
npm run start

# Development mode
npm run dev
\`\`\`

## Dependencies

- **Contracts**: [@$REPO_BASE_NAME/contracts](https://github.com/$REPO_PREFIX/$CONTRACTS_REPO)

## Related Services

Part of the $PROJECT_NAME polyrepo architecture.
EOF

    create_service_docker_files "$repo_name"
}

# Function to create mobile repository files
create_mobile_repo_files() {
    local repo_name=$1
    
    cat > README.md << EOF
# $PROJECT_NAME - Mobile App

Mobile application for the $PROJECT_NAME ecosystem.

## Tech Stack

- **Framework**: React Native / Flutter (to be determined)
- **Language**: TypeScript / Dart
- **State Management**: Redux Toolkit / Bloc
- **Navigation**: React Navigation / Go Router

## Getting Started

\`\`\`bash
# Install dependencies
npm install  # or flutter pub get

# iOS
npm run ios  # or flutter run

# Android
npm run android  # or flutter run
\`\`\`

## Dependencies

- **Contracts**: [@$REPO_BASE_NAME/contracts](https://github.com/$REPO_PREFIX/$CONTRACTS_REPO)

## Related Services

Part of the $PROJECT_NAME polyrepo architecture.
EOF
}

# Function to create frontend platform repository files
create_platform_repo_files() {
    local repo_name=$1
    
    cat > README.md << EOF
# $PROJECT_NAME - Frontend Platform

Nx monorepo containing multiple frontend applications and shared UI libraries.

## Structure

\`\`\`
apps/
├── web/             # Main web application
├── admin/           # Admin dashboard
└── mobile-web/      # Mobile web app

libs/
├── ui/              # Shared UI components
├── utils/           # Utility functions
├── data-access/     # API services
└── design-tokens/   # Design system tokens
\`\`\`

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Serve web app
nx serve web

# Serve admin app
nx serve admin

# Build all apps
nx build-all

# Test all projects
nx test-all
\`\`\`

## Dependencies

- **Contracts**: [@$REPO_BASE_NAME/contracts](https://github.com/$REPO_PREFIX/$CONTRACTS_REPO)

## Related Services

Part of the $PROJECT_NAME polyrepo architecture.
EOF

    # Create nx.json for Nx workspace
    cat > nx.json << EOF
{
  "\$schema": "./node_modules/nx/schemas/nx-schema.json",
  "npmScope": "$REPO_BASE_NAME",
  "affected": {
    "defaultBase": "main"
  },
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "lint", "test", "e2e"]
      }
    }
  }
}
EOF
}

# Function to create Docker files for services
create_service_docker_files() {
    local repo_name=$1
    
    cat > Dockerfile << EOF
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY dist/ ./dist/

EXPOSE 3000

CMD ["node", "dist/index.js"]
EOF

    cat > .dockerignore << EOF
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.local
Dockerfile
.dockerignore
coverage
.nyc_output
.DS_Store
*.log
EOF
}

# Function to create Docker files for webapps
create_webapp_docker_files() {
    local repo_name=$1
    
    cat > Dockerfile << EOF
# Build stage
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

    cat > nginx.conf << EOF
events {}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files \$uri \$uri/ /index.html;
        }
    }
}
EOF
}

# Main execution function
main() {
    display_header
    check_prerequisites
    get_project_config
    select_repositories
    confirm_configuration
    
    echo -e "\n${YELLOW}Creating repositories...${NC}"
    
    # Create repositories
    for repo_type in "${!SELECTED_REPOS[@]}"; do
        repo_name="${SELECTED_REPOS[$repo_type]}"
        create_repository "$repo_type" "$repo_name"
    done
    
    # Create summary
    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}     Repository Creation Complete!         ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo -e "${BLUE}Created Repositories:${NC}"
    
    for repo_type in "${!SELECTED_REPOS[@]}"; do
        repo_name="${SELECTED_REPOS[$repo_type]}"
        echo "  • https://github.com/$REPO_PREFIX/$repo_name"
    done
    
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Clone repositories locally"
    echo "  2. Set up development environment for each service"
    echo "  3. Configure CI/CD pipelines"
    echo "  4. Set up monitoring and logging"
    echo "  5. Implement inter-service communication"
    echo
    echo -e "${BLUE}Polyrepo Benefits:${NC}"
    echo "  ✓ Simple CI/CD per service"
    echo "  ✓ Clear ownership boundaries"
    echo "  ✓ Independent deployments"
    echo "  ✓ Technology diversity"
    echo "  ✓ Easier permissions management"
}

# Run main function
main