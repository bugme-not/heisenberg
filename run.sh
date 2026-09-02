#!/bin/sh

set -eu

PORT="${PORT:-8080}"

echo "========================================="
echo "Container starting"
echo "PORT=${PORT}"
echo "========================================="

echo "===== Checking Xray binary ====="
/usr/local/bin/xray version

echo "===== Checking Xray configuration ====="
/usr/local/bin/xray run -test -c /etc/xray.json

echo "===== Checking HAProxy configuration ====="
/usr/local/sbin/haproxy \
    -c \
    -f /usr/local/etc/haproxy/haproxy.cfg

echo "========================================="
echo "Starting Xray"
echo "========================================="

/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!

sleep 2

if ! kill -0 "${XRAY_PID}" 2>/dev/null; then
    echo "ERROR: Xray exited during startup."
    exit 1
fi

echo "Xray started successfully. PID=${XRAY_PID}"

echo "========================================="
echo "Starting HAProxy"
echo "Listening on 0.0.0.0:${PORT}"
echo "========================================="

exec /usr/local/sbin/haproxy \
    -W \
    -db \
    -f /usr/local/etc/haproxy/haproxy.cfg
