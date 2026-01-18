cat > package.json << 'EOF'
{
  "name": "seeu-dating",
  "version": "1.0.0",
  "description": "Premium dating app for South Africa",
  "main": "index.html",
  "scripts": {
    "dev": "node scripts/dev.js",
    "deploy": "bash deploy.sh",
    "preview": "npx serve ."
  },
  "keywords": ["dating", "south-africa", "supabase"],
  "author": "See U Dating",
  "license": "MIT",
  "devDependencies": {
    "live-server": "^1.2.2"
  }
}
EOF