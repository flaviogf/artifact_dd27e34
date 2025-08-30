#!/bin/bash

set -e

rm -f tmp/pids/server.pid

bin/rails db:prepare 2>/dev/null || true

exec "$@"
