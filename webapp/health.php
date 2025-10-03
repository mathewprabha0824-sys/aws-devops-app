<?php
header('Content-Type: application/json');

$health = [
    'status' => 'healthy',
    'timestamp' => date('c'),
    'hostname' => gethostname(),
    'version' => '1.0.0',
    'checks' => [
        'web_server' => 'ok',
        'php' => 'ok'
    ]
];

http_response_code(200);
echo json_encode($health, JSON_PRETTY_PRINT);
?>