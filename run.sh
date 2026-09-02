#!/bin/sh

export PORT="${PORT:-8080}"

echo "[start] Starting Xray..."
/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!
echo "[start] Xray started — PID: $XRAY_PID"

sleep 2

echo "[start] Validating HAProxy config..."
if ! haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg; then
  echo "[ERROR] HAProxy config invalid — aborting"
  exit 1
fi
echo "[start] HAProxy config OK"

echo "[start] Starting HAProxy on port $PORT..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
