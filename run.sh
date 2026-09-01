#!/bin/sh
set -e

/usr/local/bin/xray run -c /etc/xray.json &
sleep 3
exec /usr/local/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg
