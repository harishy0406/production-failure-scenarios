#!/usr/bin/env python3
"""
Reusable HTTP & TCP endpoint health probe utility.
Used across scenarios to assert endpoint reachability, response time, and HTTP status codes.
"""

import argparse
import socket
import sys
import time
import urllib.error
import urllib.request


def check_http(url: str, expected_code: int = 200, timeout: float = 3.0) -> bool:
    start_time = time.time()
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "HealthCheckProbe/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as response:
            latency = (time.time() - start_time) * 1000
            if response.status == expected_code:
                print(f"[OK] {url} returned status {response.status} in {latency:.2f}ms")
                return True
            print(f"[WARN] {url} returned status {response.status} (expected {expected_code})")
            return False
    except urllib.error.HTTPError as e:
        print(f"[FAIL] HTTP error: {e.code} for {url}")
        return e.code == expected_code
    except Exception as e:
        print(f"[FAIL] Connection error for {url}: {e}")
        return False


def check_tcp(host: str, port: int, timeout: float = 3.0) -> bool:
    start_time = time.time()
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    try:
        s.connect((host, port))
        latency = (time.time() - start_time) * 1000
        print(f"[OK] TCP connection to {host}:{port} established in {latency:.2f}ms")
        s.close()
        return True
    except Exception as e:
        print(f"[FAIL] TCP connection to {host}:{port} failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Service Health Probe Utility")
    parser.add_argument("--url", type=str, help="HTTP/HTTPS URL to probe")
    parser.add_argument("--host", type=str, help="Host for TCP probe")
    parser.add_argument("--port", type=int, help="Port for TCP probe")
    parser.add_argument("--expected-code", type=int, default=200, help="Expected HTTP status")
    parser.add_argument("--retries", type=int, default=3, help="Retry attempts")
    parser.add_argument("--interval", type=float, default=2.0, help="Seconds between retries")
    parser.add_argument("--timeout", type=float, default=3.0, help="Timeout in seconds")

    args = parser.parse_args()

    for attempt in range(1, args.retries + 1):
        if attempt > 1:
            time.sleep(args.interval)

        success = False
        if args.url:
            success = check_http(args.url, args.expected_code, args.timeout)
        elif args.host and args.port:
            success = check_tcp(args.host, args.port, args.timeout)
        else:
            print("Error: Specify either --url or both --host and --port.")
            sys.exit(1)

        if success:
            sys.exit(0)

    print(f"[FAILED] Probe failed after {args.retries} attempts.")
    sys.exit(1)


if __name__ == "__main__":
    main()
