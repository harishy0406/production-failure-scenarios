#!/usr/bin/env python3
"""
Automated configuration recovery tool for startup crashes.
Validates .env keys against required schema, restores missing entries from reference backup,
and restarts the application container.
Supports dry-run mode.
"""

import argparse
import os
import subprocess
import sys
import time
import urllib.request

REQUIRED_KEYS = ["DATABASE_URL", "JWT_SECRET", "APP_ENV"]


def read_env_file(filepath: str) -> dict[str, str]:
    env = {}
    if not os.path.exists(filepath):
        return env
    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            env[k.strip()] = v.strip()
    return env


def recover_config(env_path: str, backup_path: str, dry_run: bool = False) -> bool:
    print(f"Inspecting active configuration: {env_path}")
    active_env = read_env_file(env_path)
    backup_env = read_env_file(backup_path)

    missing = [k for k in REQUIRED_KEYS if k not in active_env or not active_env[k]]

    if not missing:
        print("[INFO] All required keys are already present in .env.")
        return True

    print(f"[WARN] Detected missing required configuration keys: {', '.join(missing)}")

    for key in missing:
        if key in backup_env:
            val = backup_env[key]
            print(f"[RECOVER] Restoring '{key}' from reference backup: {val}")
            if not dry_run:
                with open(env_path, "a") as f:
                    f.write(f"\n# Restored by automated recovery\n{key}={val}\n")
        else:
            print(f"[ERROR] Cannot recover '{key}': key not found in backup file {backup_path}")
            return False

    return True


def restart_service(simulation_dir: str, container: str, dry_run: bool = False) -> bool:
    if dry_run:
        print("[DRY-RUN] Would restart container via docker compose.")
        return True

    print("Recreating container with restored configuration...")
    cmd = ["docker", "compose", "up", "-d", "--force-recreate"]
    res = subprocess.run(cmd, cwd=simulation_dir, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"[ERROR] Failed to restart container: {res.stderr}")
        return False

    print("Waiting for container startup...")
    time.sleep(3)
    return True


def verify_health(url: str = "http://localhost:8080/health", retries: int = 5) -> bool:
    print(f"Verifying service health on {url}...")
    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "RecoveryValidator/1.0"})
            with urllib.request.urlopen(req, timeout=2.0) as resp:
                if resp.status == 200:
                    print(f"[SUCCESS] Service is online and healthy (Status {resp.status}).")
                    return True
        except Exception as e:
            print(f"Attempt {attempt}/{retries}: waiting for healthy response ({e})...")
            time.sleep(2)
    return False


def main():
    parser = argparse.ArgumentParser(description="Automated Startup Crash Config Recovery")
    parser.add_argument("--env-file", default="01-simulation/.env", help="Path to target .env file")
    parser.add_argument("--backup-file", default="01-simulation/config.example.env", help="Path to reference config")
    parser.add_argument("--simulation-dir", default="01-simulation", help="Path to simulation directory")
    parser.add_argument("--container", default="scenario-startup-crash", help="Container name")
    parser.add_argument("--dry-run", action="store_true", help="Preview recovery actions without executing")

    args = parser.parse_args()

    if not recover_config(args.env_file, args.backup_file, dry_run=args.dry_run):
        sys.exit(1)

    if not restart_service(args.simulation_dir, args.container, dry_run=args.dry_run):
        sys.exit(1)

    if not args.dry_run:
        if not verify_health():
            print("[FAIL] Service did not return healthy status after recovery!")
            sys.exit(1)

    print("[COMPLETED] Application startup recovery finished successfully.")
    sys.exit(0)


if __name__ == "__main__":
    main()
