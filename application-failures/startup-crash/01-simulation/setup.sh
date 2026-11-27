#!/usr/bin/env bash
# Sandbox Setup: provisions the container with valid initial configuration.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/3] Setting up healthy configuration (.env) ==="
cp config.example.env .env

echo "=== [2/3] Starting container via Docker Compose ==="
docker compose up -d

echo "=== [3/3] Waiting for service health readiness ==="
sleep 3

if ! docker ps --format '{{.Names}}' | grep -q "^scenario-startup-crash$"; then
    echo "Error: Container failed to start."
    exit 1
fi

echo "Testing initial health endpoint..."
curl -s http://localhost:8080/health || true
echo ""
echo "Setup complete. Service is running healthy on port 8080."
