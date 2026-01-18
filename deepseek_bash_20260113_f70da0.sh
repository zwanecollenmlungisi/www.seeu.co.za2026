cat > deploy.sh << 'EOF'
#!/bin/bash

# Deployment script for See U Dating App
echo "🚀 Deploying See U to GitHub Pages..."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if in correct directory
if [ ! -f "index.html" ]; then
    echo -e "${RED}Error: index.html not found. Run from project root.${NC}"
    exit 1
fi

# Check Git status
echo -e "${GREEN}Step 1: Checking Git status...${NC}"
git status

# Add all files
echo -e "${GREEN}Step 2: Adding files to Git...${NC}"
git add .

# Commit
echo -e "${GREEN}Step 3: Committing changes...${NC}"
read -p "Enter commit message: " commit_message
if [ -z "$commit_message" ]; then
    commit_message="Deploy update $(date '+%Y-%m-%d %H:%M:%S')"
fi
git commit -m "$commit_message"

# Push to GitHub
echo -e "${GREEN}Step 4: Pushing to GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ Deployment initiated!${NC}"
echo -e "${YELLOW}Your site will be live at:${NC}"
echo "🌐 https://seeu.co.za"
echo "📊 Check deployment: https://github.com/YOUR-USERNAME/seeu-dating/actions"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Wait 1-2 minutes for GitHub Pages build"
echo "2. Visit https://seeu.co.za"
echo "3. Test all features"
EOF

# Make deploy script executable
chmod +x deploy.sh