#!/usr/bin/env python3
"""
Lightweight production microservice simulator.
Validates startup configuration constraints before binding socket.
"""

import http.server
import json
import os
import sys

REQUIRED_ENV_VARS = [
    "DATABASE_URL",
    "JWT_SECRET",
    "APP_ENV"
]

PORT = int(os.environ.get("PORT", 8080))


def validate_environment():
    print(f"[{os.environ.get('APP_ENV', 'unknown')}] Validating runtime environment...", flush=True)
    missing = [var for var in REQUIRED_ENV_VARS if not os.environ.get(var)]

    if missing:
        sys.stderr.write(f"[CRITICAL] Missing required environment configuration: {', '.join(missing)}\n")
        sys.stderr.write("[CRITICAL] Service initialization aborted. Exiting with status 1.\n")
        sys.stderr.flush()
        sys.exit(1)

    print("[INFO] All required configuration keys verified successfully.", flush=True)


class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            payload = {
                "status": "healthy",
                "env": os.environ.get("APP_ENV"),
                "database": "connected"
            }
            self.wfile.write(json.dumps(payload).encode("utf-8"))
        else:
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            payload = {
                "service": "auth-service",
                "version": "v2.4.0",
                "status": "running"
            }
            self.wfile.write(json.dumps(payload).encode("utf-8"))

    def log_message(self, format, *args):
        # Concise logging format
        print(f"[HTTP] {self.address_string()} - {format % args}", flush=True)


def main():
    validate_environment()

    server_address = ("", PORT)
    httpd = http.server.HTTPServer(server_address, HealthHandler)
    print(f"[INFO] Service listening on port {PORT}...", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("[INFO] Shutting down service gracefully...", flush=True)
        httpd.server_close()


if __name__ == "__main__":
    main()
