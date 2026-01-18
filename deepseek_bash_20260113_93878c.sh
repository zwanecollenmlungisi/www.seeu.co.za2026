# Initialize Git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.npm
.pnpm

# Environment variables
.env
.env.local
.env.production

# Build outputs
dist/
build/
.next/
out/

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Supabase files
.supabase/
EOF