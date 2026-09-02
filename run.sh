#!/bin/sh

echo "=== CONTAINER STARTING ==="
echo "PORT env: ${PORT:-8080}"

/usr/local/bin/xray run -c /etc/xray.json &
echo "Xray started in background"

sleep 3

echo "Starting HAProxy on :8080..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
