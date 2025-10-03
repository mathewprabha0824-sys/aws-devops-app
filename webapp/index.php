<?php
$hostname = gethostname();
$ip = $_SERVER['SERVER_ADDR'] ?? 'N/A';
$version = getenv('APP_VERSION') ?: '1.0.0';
$environment = getenv('ENVIRONMENT') ?: 'staging';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Assessment - Web App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 50px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            width: 100%;
            text-align: center;
        }
        h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 30px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .info-grid {
            display: grid;
            gap: 15px;
            margin: 30px 0;
        }
        .info-item {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            border-radius: 10px;
            color: white;
        }
        .info-label {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        .info-value {
            font-size: 1.3em;
            font-weight: bold;
        }
        .status {
            display: inline-block;
            padding: 10px 30px;
            background: #10b981;
            color: white;
            border-radius: 25px;
            margin-top: 20px;
            font-weight: bold;
        }
        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
        .env-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: bold;
            margin-top: 10px;
        }
        .env-staging { background: #fbbf24; color: #78350f; }
        .env-production { background: #10b981; color: #064e3b; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS DevOps Assessment</h1>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Server Hostname</div>
                <div class="info-value"><?php echo htmlspecialchars($hostname); ?></div>
            </div>
            <div class="info-item">
                <div class="info-label">Server IP Address</div>
                <div class="info-value"><?php echo htmlspecialchars($ip); ?></div>
            </div>
            <div class="info-item">
                <div class="info-label">Application Version</div>
                <div class="info-value">v<?php echo htmlspecialchars($version); ?></div>
            </div>
        </div>

        <div class="status">✅ Status: Running</div>
        
        <div class="env-badge env-<?php echo $environment; ?>">
            Environment: <?php echo strtoupper($environment); ?>
        </div>

        <div class="footer">
            <p>Deployed via: Terraform + Jenkins CI/CD Pipeline</p>
            <p>Timestamp: <?php echo date('Y-m-d H:i:s'); ?></p>
        </div>
    </div>
</body>
</html>