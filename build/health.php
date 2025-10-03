<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'healthy',
    'timestamp' => date('c'),
    'hostname' => gethostname(),
    'version' => getenv('APP_VERSION') ?: '1.0.0'
], JSON_PRETTY_PRINT);