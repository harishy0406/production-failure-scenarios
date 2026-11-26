#!/usr/bin/env bash
# Validation script: confirms valid certificate dates and successful HTTPS handshake.
set -euo pipefail

CONTAINER_NAME="scenario-tls-expiry"
TARGET_PORT="8443"

echo "=== [1/4] Checking Container Runtime State ==="
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[FAIL] Container ${CONTAINER_NAME} is not running!"
    exit 1
fi
echo "[PASS] Container is running."

echo "=== [2/4] Testing Nginx Configuration Syntax ==="
docker exec "$CONTAINER_NAME" nginx -t
echo "[PASS] Nginx configuration syntax is valid."

echo "=== [3/4] Verifying TLS Certificate Expiration Date ==="
# Verify certificate is valid for at least the next 24 hours (86400 seconds)
CERT_DATES=$(echo | openssl s_client -connect "localhost:${TARGET_PORT}" -servername localhost 2>/dev/null | openssl x509 -noout -dates || true)

if [ -z "$CERT_DATES" ]; then
    echo "[FAIL] Could not retrieve TLS certificate from localhost:${TARGET_PORT}!"
    exit 1
fi

echo "Active Certificate Dates:"
echo "$CERT_DATES"

if echo | openssl s_client -connect "localhost:${TARGET_PORT}" -servername localhost 2>/dev/null | openssl x509 -checkend 86400 -noout; then
    echo "[PASS] Certificate is valid and not expired."
else
    echo "[FAIL] Certificate is expired or will expire within 24 hours!"
    exit 1
fi

echo "=== [4/4] Testing HTTPS Application Response ==="
RESPONSE=$(curl -sk "https://localhost:${TARGET_PORT}/" || true)
echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"healthy"'; then
    echo "[PASS] HTTPS request returned healthy response."
else
    echo "[FAIL] Unexpected response from HTTPS service!"
    exit 1
fi

echo "=== [ALL PASS] TLS certificate recovery validated successfully! ==="
