#!/usr/bin/env bash
# Starts the isolated simulation container with a 30MB mounted log partition.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Starting isolated test container..."
docker compose up -d

echo "Waiting for app to start writing logs..."
sleep 3

# Verify the container is running
if ! docker ps --format '{{.Names}}' | grep -q "^scenario-disk-exhaustion$"; then
    echo "Error: Container failed to start."
    exit 1
fi

echo "Environment is ready. You can inspect initial disk status with:"
echo "docker exec -it scenario-disk-exhaustion df -h /var/log/app"
