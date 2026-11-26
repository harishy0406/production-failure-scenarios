#!/usr/bin/env bash
# Standalone TLS certificate monitor script.
# Usage: ./cert_check_cron.sh <host> <port> <threshold_days>
# Suitable for execution in cron jobs or Nagios/Zabbix checks.
set -euo pipefail

TARGET_HOST="${1:-localhost}"
TARGET_PORT="${2:-8443}"
THRESHOLD_DAYS="${3:-14}"

SECONDS_THRESHOLD=$(( THRESHOLD_DAYS * 86400 ))

echo "Checking certificate on ${TARGET_HOST}:${TARGET_PORT} (Threshold: ${THRESHOLD_DAYS} days)..."

if ! echo | openssl s_client -connect "${TARGET_HOST}:${TARGET_PORT}" -servername "$TARGET_HOST" 2>/dev/null | openssl x509 -noout -checkend "$SECONDS_THRESHOLD"; then
    echo "[ALERT] Certificate on ${TARGET_HOST}:${TARGET_PORT} will expire within ${THRESHOLD_DAYS} days!"
    exit 1
fi

echo "[OK] Certificate is healthy and valid beyond the ${THRESHOLD_DAYS}-day threshold."
exit 0
