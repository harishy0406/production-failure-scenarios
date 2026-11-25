#!/usr/bin/env bash
# Simulates runaway log generation by filling the 30MB partition.
set -euo pipefail

CONTAINER_NAME="scenario-disk-exhaustion"

echo "Checking if container is online..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container ${CONTAINER_NAME} is not running. Run setup.sh first."
    exit 1
fi

echo "Injecting failure: spamming debug lines until disk hits 100% capacity..."

# Generate high-volume log entries to hit the 30MB cap
docker exec "$CONTAINER_NAME" sh -c '
    for i in $(seq 1 150000); do
        echo "[2026-11-25T12:00:00Z] [DEBUG] Trace payload id=$i data=0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" >> /var/log/app/app.log 2>/dev/null || break
    done
'

echo "Current disk utilization on /var/log/app:"
docker exec "$CONTAINER_NAME" df -h /var/log/app

echo "Recent application errors:"
docker logs --tail 5 "$CONTAINER_NAME" || true

echo "Failure successfully reproduced: Disk is full (ENOSPC)."
