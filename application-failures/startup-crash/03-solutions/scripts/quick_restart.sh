#!/usr/bin/env bash
# Quick helper to restart container and monitor startup logs
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIMULATION_DIR="${SCRIPT_DIR}/../../01-simulation"
CONTAINER_NAME="scenario-startup-crash"

echo "Restarting service via Docker Compose..."
cd "$SIMULATION_DIR"
docker compose up -d --force-recreate

echo "Monitoring startup logs for 5 seconds..."
sleep 3
docker logs --tail 15 "$CONTAINER_NAME"
