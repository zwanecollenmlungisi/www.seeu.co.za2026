# VS Code settings
cat > .vscode/settings.json << 'EOF'
{
    "editor.formatOnSave": true,
    "editor.tabSize": 2,
    "files.autoSave": "afterDelay",
    "git.enableSmartCommit": true,
    "liveServer.settings.port": 3000,
    "html.format.wrapAttributes": "auto",
    "files.exclude": {
        "**/.git": true,
        "**/node_modules": true
    }
}
EOF

# VS Code extensions
cat > .vscode/extensions.json << 'EOF'
{
    "recommendations": [
        "esbenp.prettier-vscode",
        "ritwickdey.liveserver",
        "ms-vscode.vscode-typescript-next",
        "bradlc.vscode-tailwindcss",
        "oderwat.indent-rainbow",
        "usernamehw.errorlens",
        "github.vscode-pull-request-github",
        "eamodio.gitlens"
    ]
}
EOF