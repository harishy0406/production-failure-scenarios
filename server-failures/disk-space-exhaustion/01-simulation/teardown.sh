#!/usr/bin/env bash
# Tears down the simulation container and removes all associated resources.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Cleaning up simulation container..."
docker compose down --remove-orphans
echo "Teardown complete."
