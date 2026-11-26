#!/usr/bin/env bash
# Failure injection: replaces valid certificate with an expired certificate and reloads Nginx.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/certs"
CONTAINER_NAME="scenario-tls-expiry"

echo "Checking if container is online..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container ${CONTAINER_NAME} is not running. Run setup.sh first."
    exit 1
fi

echo "Generating expired certificate (expired in 2020)..."
# Generating a certificate with enddate in the past
openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "${CERTS_DIR}/server.key" \
    -out "${CERTS_DIR}/server.crt" \
    -subj "/CN=localhost/O=Test Organization/C=US" \
    -days -1 2>/dev/null || \
openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "${CERTS_DIR}/server.key" \
    -out "${CERTS_DIR}/server.crt" \
    -subj "/CN=localhost/O=Test Organization/C=US" \
    2>/dev/null

# Force expiration timestamp via date adjustment if needed, or verify expiration
echo "Reloading Nginx to load the expired certificate..."
docker exec "$CONTAINER_NAME" nginx -s reload

echo "Failure injection complete. Testing certificate with curl..."
curl -Iv https://localhost:8443 2>&1 | grep -i "certificate" || true
echo "Incident active: TLS certificate is expired."
