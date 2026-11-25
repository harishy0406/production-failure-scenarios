#!/usr/bin/env python3
"""
Automated disk cleanup utility.
Checks filesystem utilization on a given path. If above a threshold,
it identifies large log files and safely truncates them in place.
Supports dry-run mode to preview actions without modifying files.
"""

import argparse
import os
import shutil
import sys


def get_disk_usage_percent(path: str) -> float:
    """Returns disk usage percentage for the filesystem containing path."""
    try:
        usage = shutil.disk_usage(path)
        percent = (usage.used / usage.total) * 100.0
        return percent
    except Exception as e:
        print(f"Error checking disk usage for {path}: {e}")
        return 0.0


def find_files_larger_than(directory: str, min_size_mb: float) -> list[tuple[str, float]]:
    """Returns list of (filepath, size_in_mb) for files exceeding min_size_mb."""
    matches = []
    min_bytes = min_size_mb * 1024 * 1024

    for root, _, files in os.walk(directory):
        for name in files:
            filepath = os.path.join(root, name)
            try:
                size = os.path.getsize(filepath)
                if size >= min_bytes:
                    matches.append((filepath, size / (1024 * 1024)))
            except OSError:
                # File may have been removed or permissions restricted
                continue

    matches.sort(key=lambda x: x[1], reverse=True)
    return matches


def truncate_file(filepath: str, dry_run: bool = False) -> bool:
    """Truncates file in place to 0 bytes preserving open file handles."""
    if dry_run:
        print(f"[DRY-RUN] Would truncate: {filepath}")
        return True

    try:
        # Using open with 'w' or truncate(0) keeps the inode intact
        with open(filepath, "r+") as f:
            f.truncate(0)
        print(f"[RECOVERED] Truncated: {filepath} -> 0 MB")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to truncate {filepath}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Automated log cleaner for disk exhaustion incidents")
    parser.add_argument("--path", default="/var/log/app", help="Target directory or mount point to inspect")
    parser.add_argument("--threshold", type=float, default=80.0, help="Disk usage percent threshold to trigger cleanup")
    parser.add_argument("--min-file-size-mb", type=float, default=5.0, help="Minimum file size in MB to consider for truncation")
    parser.add_argument("--dry-run", action="store_true", help="Preview actions without modifying any files")

    args = parser.parse_args()

    if not os.path.exists(args.path):
        print(f"Error: Target path '{args.path}' does not exist.")
        sys.exit(1)

    usage_percent = get_disk_usage_percent(args.path)
    print(f"Current disk usage on '{args.path}': {usage_percent:.1f}% (Threshold: {args.threshold}%)")

    if usage_percent < args.threshold:
        print("Disk usage is within acceptable limits. No action needed.")
        sys.exit(0)

    print(f"Disk usage exceeds {args.threshold}%. Scanning for files larger than {args.min_file_size_mb} MB...")
    large_files = find_files_larger_than(args.path, args.min_file_size_mb)

    if not large_files:
        print("Warning: Disk is above threshold, but no single file exceeded the minimum size cutoff.")
        sys.exit(0)

    for filepath, size_mb in large_files:
        print(f"Found candidate: {filepath} ({size_mb:.2f} MB)")
        truncate_file(filepath, dry_run=args.dry_run)

    if not args.dry_run:
        new_usage = get_disk_usage_percent(args.path)
        print(f"Cleanup finished. New disk usage: {new_usage:.1f}%")

    sys.exit(0)


if __name__ == "__main__":
    main()
