#!/bin/sh

# Convert line endings if needed & ensure execution
export PORT="${PORT:-8080}"

echo "=== Starting up ==="
echo "PORT set to: $PORT"

# Start Xray in background
echo "Starting Xray..."
/usr/local/bin/xray run -c /etc/xray.json &
XRAY_PID=$!
echo "Xray started (PID $XRAY_PID)"

# Wait for Xray to be ready
sleep 3

# Generate HAProxy config with correct PORT
echo "Generating HAProxy config for port $PORT..."
sed "s/\$PORT/$PORT/g" /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

# Validate HAProxy config
echo "Validating HAProxy config..."
if ! haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg; then
  echo "ERROR: HAProxy config invalid!"
  cat /usr/local/etc/haproxy/haproxy.cfg
  exit 1
fi
echo "HAProxy config OK"

# Start HAProxy (foreground = PID 1)
echo "Starting HAProxy on port $PORT..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
