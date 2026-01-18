# Complete setup command - Copy and paste entire block
mkdir seeu-dating-app && cd seeu-dating-app && \
mkdir -p assets/{images,icons,css,js} pages scripts .vscode .github/workflows && \
touch index.html 404.html CNAME robots.txt sitemap.xml _config.yml .nojekyll README.md LICENSE .gitignore package.json deploy.sh && \
echo "seeu.co.za" > CNAME && \
cat > .gitignore << 'EOF'
node_modules/
.env
.DS_Store
*.log
EOF
git init && \
cat > package.json << 'EOF'
{
  "name": "seeu-dating",
  "version": "1.0.0",
  "scripts": {
    "dev": "npx live-server --port=3000",
    "deploy": "bash deploy.sh"
  }
}
EOF
cat > deploy.sh << 'EOF'
#!/bin/bash
git add .
git commit -m "Deploy $(date)"
git push origin main
EOF
chmod +x deploy.sh && \
echo "✅ Basic setup complete!" && \
echo "📁 Now add your HTML code to index.html" && \
echo "🌐 Then create repo at: https://github.com/new"