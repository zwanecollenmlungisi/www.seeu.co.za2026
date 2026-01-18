# Check what we've created
ls -la

# Should see:
# index.html  404.html  CNAME  robots.txt  sitemap.xml
# _config.yml  .nojekyll  README.md  LICENSE  .gitignore
# package.json  deploy.sh  assets/  pages/  scripts/  .vscode/  .github/

# Check folder structure
tree -I 'node_modules|.git' -L 2