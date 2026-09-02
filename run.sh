#!/bin/sh

set -eu

PORT="${PORT:-8080}"

echo "CONTAINER STARTING"
echo "PORT=${PORT}"

echo "Checking Xray configuration"

/usr/local/bin/xray run -test -c /etc/xray.json

echo "Starting Xray"

/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!

sleep 2

if ! kill -0 "$XRAY_PID" 2>/dev/null
then
echo "Xray failed to start"
exit 1
fi

echo "Creating HAProxy configuration"

sed "s/PORT/${PORT}/g" /usr/local/etc/haproxy/haproxy.cfg > /tmp/haproxy.cfg

echo "Checking HAProxy configuration"

haproxy -c -f /tmp/haproxy.cfg

echo "Starting HAProxy"

exec haproxy -db -f /tmp/haproxy.cfg
