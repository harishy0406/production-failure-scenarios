#!/usr/bin/env bash
# Sandbox Teardown: stops and removes all containers and volumes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Tearing down scenario sandbox..."
docker compose down -v --remove-orphans
echo "Sandbox teardown complete."
