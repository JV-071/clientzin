<?php
// Local announcement feed. Add announcements to this array when available.
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-cache');
$announcements = [];
echo json_encode(['ptc' => $announcements], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
