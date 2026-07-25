#!/usr/bin/env bash

#########################################
# Stops running containers
#########################################

set -e

CONTAINERS=(
    "zeroviewer-server"
)

echo "=================================================="
echo "Stopping Zero-Viewer Gateway Containers"

for container in "${CONTAINERS[@]}"; do
    if [ -n "$(docker ps -aq -f "name=^${container}$")" ]; then
        docker rm -f "$container"
        echo "Removed '$container'."
    else
        echo "⚠️ '$container' is not present."
    fi
done
