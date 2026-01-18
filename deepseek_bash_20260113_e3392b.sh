# 1. Create project
mkdir seeu-dating-app
cd seeu-dating-app

# 2. Initialize
echo "seeu.co.za" > CNAME
touch .nojekyll

# 3. Setup Git
git init
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore

# 4. Create basic files
touch index.html 404.html

# 5. Create GitHub repo manually at github.com
# 6. Then:
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/seeu-dating.git
git push -u origin main

# 7. Configure GitHub Pages in repo settings