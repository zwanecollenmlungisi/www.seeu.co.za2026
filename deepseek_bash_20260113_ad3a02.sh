# Fix permissions
chmod +x *.sh

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Reset Git if needed
rm -rf .git
git init

# Check GitHub Pages status
curl -I https://seeu.co.za

# Test locally
python3 -m http.server 8000