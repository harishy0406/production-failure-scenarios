#!/usr/bin/env bash
# Sandbox Teardown: stops containers and cleans up environment files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Tearing down simulation container..."
docker compose down --remove-orphans

if [ -f .env ]; then
    rm -f .env
fi

echo "Teardown complete."
