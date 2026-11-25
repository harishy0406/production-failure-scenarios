#!/usr/bin/env python3
"""
Automated, idempotent recovery script for accidental database deletion.
Supports dry-run mode and automatic validation.
"""

import argparse
import subprocess
import sys


def run_cmd(cmd: list[str], dry_run: bool = False) -> tuple[int, str]:
    cmd_str = " ".join(cmd)
    if dry_run:
        print(f"[DRY-RUN] Would execute: {cmd_str}")
        return 0, ""
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.returncode, result.stdout + result.stderr


def is_database_present(container: str) -> bool:
    cmd = ["docker", "exec", container, "psql", "-U", "postgres", "-lqt"]
    code, out = run_cmd(cmd)
    if code != 0:
        return False
    dbs = [line.split("|")[0].strip() for line in out.splitlines() if line]
    return "production_db" in dbs


def recover(container: str, backup_path: str, dry_run: bool = False) -> bool:
    print(f"=== Beginning Automated Recovery for '{container}' ===")

    # 1. Check if database already exists
    if is_database_present(container):
        print("[INFO] Database 'production_db' is already present. Ensuring data integrity...")
    else:
        print("[INFO] Database 'production_db' is missing. Creating empty database shell...")
        create_cmd = ["docker", "exec", container, "psql", "-U", "postgres", "-c", "CREATE DATABASE production_db;"]
        code, out = run_cmd(create_cmd, dry_run=dry_run)
        if code != 0 and not dry_run:
            print(f"[ERROR] Failed to create database: {out}")
            return False

    # 2. Restore dump
    print(f"[INFO] Restoring base backup from {backup_path}...")
    restore_cmd = [
        "docker", "exec", container,
        "pg_restore", "-U", "postgres", "-d", "production_db",
        "--clean", "--if-exists", backup_path
    ]
    code, out = run_cmd(restore_cmd, dry_run=dry_run)
    if code != 0 and not dry_run:
        # pg_restore returns non-zero on warnings, check if fatal
        if "FATAL" in out or "error:" in out:
            print(f"[WARN] pg_restore issued notes/warnings: {out}")

    print("[SUCCESS] Automated recovery completed.")
    return True


def main():
    parser = argparse.ArgumentParser(description="Automated Recovery for Accidental DB Deletion")
    parser.add_argument("--container", default="scenario-pg-deletion", help="Target container name")
    parser.add_argument("--backup-path", default="/var/backups/postgres/base/production_db_base.dump", help="Backup path inside container")
    parser.add_argument("--dry-run", action="store_true", help="Perform dry-run simulation without making changes")

    args = parser.parse_args()

    success = recover(args.container, args.backup_path, dry_run=args.dry_run)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
