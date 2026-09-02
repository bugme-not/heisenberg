#!/bin/sh
set +e

echo "CONTAINER STARTING"
echo "PORT: ${PORT:-8080}"

/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!
echo "Xray started PID $XRAY_PID"

sleep 3

echo "Starting HAProxy on 0.0.0.0:8080"
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
