#!/usr/bin/env bash
# Emergency script to truncate oversized log files in place without breaking open file descriptors.
set -euo pipefail

TARGET_FILE="${1:-/var/log/app/app.log}"

echo "Checking target file: $TARGET_FILE"

if [ ! -f "$TARGET_FILE" ]; then
    echo "Warning: $TARGET_FILE does not exist as a regular file."
    echo "Checking for open deleted file descriptors via /proc..."
    
    DELETED_FD=$(ls -l /proc/*/fd/* 2>/dev/null | grep "$TARGET_FILE (deleted)" | head -n 1 | awk '{print $9}' || true)
    
    if [ -n "$DELETED_FD" ]; then
        echo "Found deleted file handle at $DELETED_FD. Truncating directly..."
        : > "$DELETED_FD"
        echo "Successfully freed blocks from deleted file descriptor."
        exit 0
    else
        echo "No open handles found for $TARGET_FILE."
        exit 1
    fi
fi

CURRENT_SIZE=$(du -h "$TARGET_FILE" | awk '{print $1}')
echo "Current size of $TARGET_FILE: $CURRENT_SIZE"

echo "Truncating $TARGET_FILE in place..."
: > "$TARGET_FILE"

NEW_SIZE=$(du -h "$TARGET_FILE" | awk '{print $1}')
echo "New size of $TARGET_FILE: $NEW_SIZE"
echo "Truncation complete. File descriptor remained valid."
