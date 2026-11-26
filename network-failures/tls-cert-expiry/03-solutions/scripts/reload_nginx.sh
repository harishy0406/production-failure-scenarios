#!/usr/bin/env bash
# Verifies Nginx configuration syntax and issues a zero-downtime reload.
set -euo pipefail

CONTAINER_NAME="${1:-scenario-tls-expiry}"

echo "Checking if container $CONTAINER_NAME is running..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container $CONTAINER_NAME is not running."
    exit 1
fi

echo "Testing Nginx configuration syntax inside container..."
docker exec "$CONTAINER_NAME" nginx -t

echo "Issuing graceful reload signal (SIGHUP / nginx -s reload)..."
docker exec "$CONTAINER_NAME" nginx -s reload

echo "Reload completed successfully. No active connections were dropped."
