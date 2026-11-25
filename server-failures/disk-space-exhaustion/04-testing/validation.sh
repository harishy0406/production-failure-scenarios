#!/usr/bin/env bash
# Validation script: verifies disk capacity has recovered and app writes are healthy.
set -euo pipefail

CONTAINER_NAME="scenario-disk-exhaustion"
MOUNT_PATH="/var/log/app"

echo "=== [1/4] Checking Container Runtime State ==="
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[FAIL] Container ${CONTAINER_NAME} is not running!"
    exit 1
fi
echo "[PASS] Container is running."

echo "=== [2/4] Verifying Partition Capacity on ${MOUNT_PATH} ==="
USAGE_PERCENT=$(docker exec "$CONTAINER_NAME" df "$MOUNT_PATH" | awk 'NR==2 {gsub("%","",$5); print $5}')
echo "Current disk usage: ${USAGE_PERCENT}% (Maximum allowed: 80%)"

if [ "$USAGE_PERCENT" -ge 80 ]; then
    echo "[FAIL] Disk usage is still too high (${USAGE_PERCENT}%)!"
    exit 1
fi
echo "[PASS] Disk usage is within safe operating range."

echo "=== [3/4] Testing Write Ability (Canary File) ==="
docker exec "$CONTAINER_NAME" touch "${MOUNT_PATH}/.validation_canary"
docker exec "$CONTAINER_NAME" rm "${MOUNT_PATH}/.validation_canary"
echo "[PASS] Canary file write and deletion succeeded."

echo "=== [4/4] Checking Application Error Output ==="
RECENT_ERRORS=$(docker logs --tail 10 "$CONTAINER_NAME" 2>&1 | grep -c "No space left on device" || true)
if [ "$RECENT_ERRORS" -gt 0 ]; then
    echo "[WARN] Found previous error entries in recent logs, but current disk space is free."
fi

echo "=== [ALL PASS] Disk space recovery verified successfully! ==="
