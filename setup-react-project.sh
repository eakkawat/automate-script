#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
check_prerequisites() {
    local tools=("npm" "npx" "git" "pnpm")
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            echo -e "${YELLOW}Error: $tool is not installed.${NC}"
            exit 1
        fi
    done
}

# Setup project function
setup_react_project() {
    # Project name input
    read -p "Enter project name: " PROJECT_NAME

    # Validate project name
    if [[ -z "$PROJECT_NAME" ]]; then
        echo -e "${YELLOW}Project name cannot be empty!${NC}"
        exit 1
    fi

    # Create Vite React TypeScript project
    echo -e "${GREEN}Creating Vite React TypeScript project...${NC}"
    mkdir "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit
    pnpm create vite . --template react-ts

    # Initialize git
    git init

    # Install dependencies
    echo -e "${GREEN}Installing project dependencies...${NC}"
    pnpm install

    # ESLint and Prettier dependencies
    echo -e "${GREEN}Installing ESLint and Prettier...${NC}"
    pnpm add -D \
        eslint@^8.2.0 \
        prettier \
        eslint-plugin-react@^7.28.0 \
        eslint-plugin-react-hooks@^4.3.0 \
        eslint-plugin-jsx-a11y \
        eslint-plugin-import \
        @typescript-eslint/parser@^7.0.0 \
        @typescript-eslint/eslint-plugin@^7.0.0 \
        eslint-config-airbnb \
        eslint-config-airbnb-typescript \
        eslint-config-prettier \
        eslint-plugin-prettier

    # Create ESLint configuration
    echo -e "${GREEN}Creating ESLint configuration...${NC}"
    cat > .eslintrc.json << EOL
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "airbnb",
    "airbnb-typescript",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 12,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": ["react", "@typescript-eslint", "prettier"],
  "rules": {
    "prettier/prettier": "error",
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off",
    "react/jsx-filename-extension": [1, { "extensions": [".tsx"] }],
    "@typescript-eslint/explicit-module-boundary-types": "off"
  }
}
EOL

    # Create Prettier configuration
    echo -e "${GREEN}Creating Prettier configuration...${NC}"
    cat > .prettierrc << EOL
{
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "bracketSpacing": true,
  "jsxBracketSameLine": false,
  "arrowParens": "avoid"
}
EOL

    # Update package.json scripts
    echo -e "${GREEN}Updating package.json scripts...${NC}"
    npm pkg set scripts.lint="eslint . --ext .ts,.tsx --fix"
    npm pkg set scripts.format="prettier --write ."
    npm pkg set scripts.prepare="husky install"

    # Install Husky for git hooks
    pnpm add -D husky lint-staged
    npx husky install
    npx husky add .husky/pre-commit "npx lint-staged"

    # Create VSCode settings
    mkdir -p .vscode
    cat > .vscode/settings.json << EOL
{
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
    "eslint.alwaysShowStatus": true,
    "eslint.format.enable": true,
    "eslint.run": "onType"
}
EOL

    # Initial commit
    git add .
    git commit -m "Initial project setup with React, TypeScript, ESLint, and Prettier"

    echo -e "${GREEN}Project setup complete! 🚀${NC}"
    echo -e "${YELLOW}To start the development server, run:${NC}"
    echo -e "cd $PROJECT_NAME && npm run dev"
}

# Main script execution
main() {
    check_prerequisites
    setup_react_project
}

# Run the main function
main