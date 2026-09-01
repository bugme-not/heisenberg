#!/bin/sh
set -e
/usr/local/bin/xray run -c /etc/xray.json &
sleep 5
exec docker-entrypoint.sh haproxy -f /usr/local/etc/haproxy/haproxy.cfg
