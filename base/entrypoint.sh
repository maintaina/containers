#!/usr/bin/env bash
echo "Config stage"

echo "Handing over to pid 1 command"
exec "$@"