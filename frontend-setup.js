const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Function to execute shell commands
function runCommand(command) {
  console.log(`Running: ${command}`);
  execSync(command, { stdio: 'inherit' });
}

// Function to create a file with content
function createFile(filePath, content) {
  fs.writeFileSync(filePath, content);
}

// Main function to setup the project
function setupProject() {
  const projectName = 'my-react-app';

  // Step 1: Initialize the project with Vite
  runCommand(`pnpm create vite@latest ${projectName} --template react-ts`);
  process.chdir(projectName);
  runCommand('pnpm install');

  // Step 2: Install ESLint and Prettier
  runCommand(
    'pnpm add -D eslint prettier eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y eslint-plugin-import @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-config-airbnb eslint-config-prettier eslint-plugin-prettier'
  );

  // Step 3: Configure ESLint
  const eslintConfig = {
    env: {
      browser: true,
      es2021: true,
      node: true,
    },
    extends: [
      'airbnb',
      'airbnb-typescript',
      'plugin:react/recommended',
      'plugin:@typescript-eslint/recommended',
      'plugin:prettier/recommended',
    ],
    parser: '@typescript-eslint/parser',
    parserOptions: {
      ecmaFeatures: {
        jsx: true,
      },
      ecmaVersion: 12,
      sourceType: 'module',
      project: './tsconfig.json',
    },
    plugins: ['react', '@typescript-eslint', 'prettier'],
    rules: {
      'prettier/prettier': 'error',
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'react/jsx-filename-extension': [1, { extensions: ['.tsx'] }],
      '@typescript-eslint/explicit-module-boundary-types': 'off',
    },
  };
  createFile('.eslintrc.json', JSON.stringify(eslintConfig, null, 2));

  // Step 4: Configure Prettier
  const prettierConfig = {
    singleQuote: true,
    trailingComma: 'all',
    printWidth: 80,
    tabWidth: 2,
    useTabs: false,
    semi: true,
    bracketSpacing: true,
    jsxBracketSameLine: false,
    arrowParens: 'avoid',
  };
  createFile('.prettierrc', JSON.stringify(prettierConfig, null, 2));

  // Step 5: Add scripts to package.json
  const packageJsonPath = path.join(process.cwd(), 'package.json');
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  packageJson.scripts = {
    ...packageJson.scripts,
    lint: 'eslint . --ext .ts,.tsx --fix',
    format: 'prettier --write .',
  };
  fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));

  // Step 6: Set up VSCode (Optional)
  const vscodeSettings = {
    'editor.formatOnSave': true,
    'editor.defaultFormatter': 'esbenp.prettier-vscode',
    'eslint.validate': [
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
    ],
    'eslint.alwaysShowStatus': true,
    'eslint.format.enable': true,
    'eslint.run': 'onType',
  };
  const vscodeDir = path.join(process.cwd(), '.vscode');
  if (!fs.existsSync(vscodeDir)) {
    fs.mkdirSync(vscodeDir);
  }
  createFile(
    path.join(vscodeDir, 'settings.json'),
    JSON.stringify(vscodeSettings, null, 2)
  );

  // Step 7: Run the setup
  runCommand('pnpm run lint');
  runCommand('pnpm run format');

  // Step 8: Start the development server
  runCommand('pnpm run dev');

  console.log('Project setup complete!');
}

// Run the setup function
setupProject();
