#!/bin/sh

set -eu

PORT="${PORT:-8080}"

echo "CONTAINER STARTING"
echo "PORT=${PORT}"

echo "Creating HAProxy configuration"

sed "s/__PORT__/${PORT}/g" \
    /usr/local/etc/haproxy/haproxy.cfg \
    > /tmp/haproxy.cfg

echo "Checking HAProxy configuration"

haproxy -c -f /tmp/haproxy.cfg

echo "Starting HAProxy"

haproxy -db -f /tmp/haproxy.cfg &
HAPROXY_PID=$!

sleep 1

if ! kill -0 "$HAPROXY_PID" 2>/dev/null
then
    echo "HAProxy failed to start"
    exit 1
fi

echo "Starting Xray"

/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!

echo "Xray PID=${XRAY_PID}"

wait "$HAPROXY_PID"
