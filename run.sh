#!/bin/sh
export PORT="${PORT:-8080}"

echo "=== Starting up ==="
echo "PORT set to: $PORT"

# Start Xray
echo "Starting Xray..."
/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!
echo "Xray started (PID $XRAY_PID)"

sleep 3

# Generate HAProxy config with correct port
echo "Generating HAProxy config..."
sed "s/\$PORT/$PORT/g" /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

# Validate
echo "Validating HAProxy config..."
if ! haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg; then
  echo "ERROR: HAProxy config invalid!"
  exit 1
fi
echo "HAProxy config OK"

# Start HAProxy
echo "Starting HAProxy on port $PORT..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
