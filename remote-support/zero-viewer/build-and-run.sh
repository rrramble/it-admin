#!/usr/bin/env bash

#########################################
# Builds and runs a container
#########################################

set -e
echo "Starting Deployment"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/setup/constants.conf"

clients_db_path="${SCRIPT_DIR}/${CLIENTS_DB_PATH}"
operators_db_path="${SCRIPT_DIR}/${OPERATORS_DB_PATH}"

# Check if credential files exist
if [ ! -f "$clients_db_path" ] || [ ! -f "$operators_db_path" ]; then
    echo "❌ ERROR: Configuration file '$clients_db_path' or '$operators_db_path' missing!"
    exit 1
fi

# Stop and remove old container if it exists
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "♺ Found old container. Stopping and removing."
    docker rm -f "$CONTAINER_NAME"
fi

echo "Building Docker image"
docker build --pull -t "$IMAGE_NAME" "${SCRIPT_DIR}"

echo "⚡ Launching container: $CONTAINER_NAME"
docker run \
    -d \
    -p "${EXTERNAL_SSH_PORT}:${INTERNAL_SSH_PORT}" \
    -v "${clients_db_path}:${SERVER_CLIENTS_DB_PATH}:ro" \
    -v "${operators_db_path}:${SERVER_OPERATORS_DB_PATH}:ro" \
    --restart no \
    --name "$CONTAINER_NAME" \
    "$IMAGE_NAME"

echo "✅ Server is listening on port $EXTERNAL_SSH_PORT"
echo "=================================================="
