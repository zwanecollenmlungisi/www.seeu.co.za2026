cat > 404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>See U | Page Not Found</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #0F172A;
            color: #F8FAFC;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-align: center;
        }
        .container {
            max-width: 500px;
            padding: 2rem;
        }
        h1 {
            color: #FF3366;
            font-size: 4rem;
            margin: 0;
        }
        a {
            color: #FF3366;
            text-decoration: none;
            font-weight: bold;
            display: inline-block;
            margin-top: 2rem;
            padding: 0.75rem 1.5rem;
            border: 2px solid #FF3366;
            border-radius: 8px;
            transition: all 0.3s;
        }
        a:hover {
            background: #FF3366;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>404</h1>
        <h2>Page Not Found</h2>
        <p>The page you're looking for doesn't exist or has been moved.</p>
        <a href="/">Return to See U Dating</a>
    </div>
    
    <script>
        // Redirect to main app for SPA routing
        if (window.location.pathname !== '/') {
            setTimeout(() => {
                window.location.href = '/';
            }, 3000);
        }
    </script>
</body>
</html>
EOF