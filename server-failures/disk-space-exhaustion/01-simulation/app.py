#!/usr/bin/env python3
"""
Simple worker process simulating a backend service logging events to disk.
"""

import datetime
import os
import sys
import time

LOG_DIR = "/var/log/app"
LOG_FILE = os.path.join(LOG_DIR, "app.log")

os.makedirs(LOG_DIR, exist_ok=True)

print(f"Starting worker process. Target log file: {LOG_FILE}", flush=True)

# Keep the file handle open to simulate a typical daemon
with open(LOG_FILE, "a") as f:
    counter = 1
    while True:
        timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat()
        message = f"[{timestamp}] [INFO] Processing background batch event #{counter}\n"

        try:
            f.write(message)
            f.flush()
            counter += 1
            time.sleep(1)
        except OSError as e:
            # When disk hits 100%, Errno 28 (ENOSPC) will be caught here
            sys.stderr.write(f"[{timestamp}] [CRITICAL] Write failed: {e}\n")
            sys.stderr.flush()
            time.sleep(2)
