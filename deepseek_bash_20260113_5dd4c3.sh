# Create one-time setup script
cat > setup.sh << 'EOF'
#!/bin/bash

echo "🚀 Setting up See U Dating App..."

# Create structure
mkdir -p assets/{images,icons,css,js} pages scripts .vscode .github/workflows

# Create files
touch index.html 404.html CNAME robots.txt sitemap.xml _config.yml .nojekyll README.md LICENSE .gitignore package.json deploy.sh

# Set domain
echo "seeu.co.za" > CNAME

# Create gitignore
cat > .gitignore << 'GITIGNORE'
node_modules/
.env
.DS_Store
GITIGNORE

# Initialize Git
git init
git add .
git commit -m "Initial setup"

echo "✅ Setup complete!"
echo "Next steps:"
echo "1. Add your HTML code to index.html"
echo "2. Create GitHub repo at https://github.com/new"
echo "3. Run: git remote add origin https://github.com/YOUR-USERNAME/seeu-dating.git"
echo "4. Run: git push -u origin main"
echo "5. Configure GitHub Pages in repo settings"
EOF

chmod +x setup.sh