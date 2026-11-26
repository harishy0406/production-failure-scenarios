#!/usr/bin/env bash
# Initializes the isolated Nginx container with a valid initial SSL certificate.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CERTS_DIR="${SCRIPT_DIR}/certs"
mkdir -p "$CERTS_DIR"

echo "Generating valid initial SSL certificate (valid for 365 days)..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${CERTS_DIR}/server.key" \
    -out "${CERTS_DIR}/server.crt" \
    -subj "/CN=localhost/O=Test Organization/C=US" \
    2>/dev/null

echo "Starting Nginx simulation container..."
docker compose up -d

echo "Waiting for Nginx readiness..."
sleep 2

if ! docker ps --format '{{.Names}}' | grep -q "^scenario-tls-expiry$"; then
    echo "Error: Container failed to start."
    exit 1
fi

echo "Nginx is running with a valid certificate on port 8443."
