<?php
$data = [
    'PROVISION_CONTEXT' => getenv('PROVISION_CONTEXT')
];

echo json_encode($data);