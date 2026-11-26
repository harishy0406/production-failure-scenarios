#!/usr/bin/env bash
# Cleans up the simulation container and removes generated certificates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Stopping simulation container..."
docker compose down --remove-orphans

echo "Removing test certificate files..."
rm -rf "${SCRIPT_DIR}/certs"

echo "Teardown complete."
