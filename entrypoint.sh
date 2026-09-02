#!/bin/sh
set -e
mkdir -p /var/log/supervisor /run/supervisor
exec "$@"
