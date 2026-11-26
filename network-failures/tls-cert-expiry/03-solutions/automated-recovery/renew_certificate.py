#!/usr/bin/env python3
"""
Automated TLS certificate renewal tool.
Inspects certificate expiration, regenerates X.509 keypairs when expired or near expiry,
and triggers a zero-downtime Nginx reload.
Supports dry-run mode.
"""

import argparse
import datetime
import os
import subprocess
import sys


def get_cert_expiration_date(cert_path: str) -> datetime.datetime | None:
    """Reads certificate notAfter timestamp via OpenSSL."""
    if not os.path.exists(cert_path):
        return None
    try:
        cmd = ["openssl", "x509", "-in", cert_path, "-noout", "-enddate"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        # Output format: notAfter=Nov 25 12:00:00 2026 GMT
        date_str = result.stdout.strip().split("notAfter=")[-1]
        exp_date = datetime.datetime.strptime(date_str, "%b %d %H:%M:%S %Y %Z")
        return exp_date.replace(tzinfo=datetime.timezone.utc)
    except Exception as e:
        print(f"Error reading certificate date: {e}")
        return None


def renew_certificate(certs_dir: str, validity_days: int = 90, dry_run: bool = False) -> bool:
    """Generates new certificate and key."""
    key_path = os.path.join(certs_dir, "server.key")
    crt_path = os.path.join(certs_dir, "server.crt")

    cmd = [
        "openssl", "req", "-x509", "-nodes",
        "-days", str(validity_days),
        "-newkey", "rsa:2048",
        "-keyout", key_path,
        "-out", crt_path,
        "-subj", "/CN=localhost/O=AutomatedRenewal/C=US"
    ]

    if dry_run:
        print(f"[DRY-RUN] Would generate new cert at {crt_path} valid for {validity_days} days.")
        return True

    print(f"Generating new certificate (valid for {validity_days} days)...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Failed to generate certificate: {result.stderr}")
        return False
    print("New certificate generated successfully.")
    return True


def reload_server(container: str, dry_run: bool = False) -> bool:
    """Tests config and reloads Nginx."""
    if dry_run:
        print(f"[DRY-RUN] Would test and reload Nginx in container {container}.")
        return True

    print(f"Testing Nginx config in {container}...")
    test_res = subprocess.run(["docker", "exec", container, "nginx", "-t"], capture_output=True, text=True)
    if test_res.returncode != 0:
        print(f"Nginx config test failed: {test_res.stderr}")
        return False

    print(f"Reloading Nginx in {container}...")
    reload_res = subprocess.run(["docker", "exec", container, "nginx", "-s", "reload"], capture_output=True, text=True)
    if reload_res.returncode != 0:
        print(f"Nginx reload failed: {reload_res.stderr}")
        return False
    print("Nginx reloaded successfully.")
    return True


def main():
    parser = argparse.ArgumentParser(description="Automated TLS Certificate Renewal")
    parser.add_argument("--certs-dir", default="01-simulation/certs", help="Path to directory containing server.crt and server.key")
    parser.add_argument("--container", default="scenario-tls-expiry", help="Nginx container name")
    parser.add_argument("--days", type=int, default=90, help="Validity period for renewed certificate in days")
    parser.add_argument("--threshold-days", type=int, default=15, help="Renew if expiring within this number of days")
    parser.add_argument("--dry-run", action="store_true", help="Preview renewal actions without modifying files")

    args = parser.parse_args()

    cert_file = os.path.join(args.certs_dir, "server.crt")
    exp_date = get_cert_expiration_date(cert_file)

    now = datetime.datetime.now(datetime.timezone.utc)
    if exp_date:
        days_left = (exp_date - now).total_seconds() / 86400.0
        print(f"Current certificate expires on: {exp_date.isoformat()} ({days_left:.1f} days remaining)")

        if days_left > args.threshold_days:
            print(f"Certificate is still valid for {days_left:.1f} days (threshold is {args.threshold_days} days). No renewal needed.")
            sys.exit(0)
        else:
            print(f"Certificate is expired or expiring within {args.threshold_days} days. Proceeding with renewal...")
    else:
        print("Certificate not found or unreadable. Generating new certificate...")

    if not renew_certificate(args.certs_dir, validity_days=args.days, dry_run=args.dry_run):
        sys.exit(1)

    if not reload_server(args.container, dry_run=args.dry_run):
        sys.exit(1)

    print("[SUCCESS] Certificate renewed and web server reloaded.")
    sys.exit(0)


if __name__ == "__main__":
    main()
