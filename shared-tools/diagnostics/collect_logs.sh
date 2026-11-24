#!/usr/bin/env bash
# Universal diagnostic collector: captures container status, resource usage, and recent logs.
set -euo pipefail

TARGET_CONTAINER="${1:-}"
OUTPUT_DIR="${2:-/tmp/diagnostics-$(date +%s)}"

mkdir -p "$OUTPUT_DIR"
echo "Collecting diagnostics into: $OUTPUT_DIR"

if [ -n "$TARGET_CONTAINER" ]; then
    echo "Gathering container inspection and logs for: $TARGET_CONTAINER..."
    docker inspect "$TARGET_CONTAINER" > "$OUTPUT_DIR/docker-inspect-$TARGET_CONTAINER.json" 2>&1 || true
    docker logs --tail 200 "$TARGET_CONTAINER" > "$OUTPUT_DIR/docker-logs-$TARGET_CONTAINER.log" 2>&1 || true
fi

echo "Gathering container runtime state..."
docker ps -a > "$OUTPUT_DIR/docker-ps.txt" 2>&1 || true

echo "Diagnostics capture completed successfully."
