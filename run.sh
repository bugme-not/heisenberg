#!/bin/sh

set -eu

PORT="${PORT:-8080}"

echo "======================================"
echo "Starting container"
echo "PORT=${PORT}"
echo "======================================"

echo "===== XRAY CONFIG TEST ====="
/usr/local/bin/xray run -test -c /etc/xray.json

echo "===== HAPROXY CONFIG TEST ====="
haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

echo "===== STARTING XRAY ====="
/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!

sleep 2

if ! kill -0 "$XRAY_PID" 2>/dev/null; then
    echo "ERROR: Xray failed to start"
    exit 1
fi

echo "Xray started with PID ${XRAY_PID}"

trap 'kill "$XRAY_PID" 2>/dev/null || true' INT TERM EXIT

echo "===== STARTING HAPROXY ====="

exec haproxy \
    -W \
    -db \
    -f /usr/local/etc/haproxy/haproxy.cfg
