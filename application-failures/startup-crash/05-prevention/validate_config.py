#!/usr/bin/env python3
"""
Pre-flight configuration validation script for CI/CD pipelines.
Validates environment file against required schema before deployment.
Exits with 0 if valid, exits with 1 if mandatory variables are missing.
"""

import argparse
import os
import sys

DEFAULT_REQUIRED_KEYS = [
    "PORT",
    "APP_ENV",
    "DATABASE_URL",
    "JWT_SECRET"
]


def validate_env_file(filepath: str, required_keys: list[str]) -> bool:
    if not os.path.exists(filepath):
        print(f"[FAIL] Configuration file not found: {filepath}")
        return False

    loaded_keys = {}
    with open(filepath, "r") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                print(f"[WARN] Line {line_num} does not contain key=value format: {line}")
                continue
            k, v = line.split("=", 1)
            loaded_keys[k.strip()] = v.strip()

    missing = []
    empty = []

    for req in required_keys:
        if req not in loaded_keys:
            missing.append(req)
        elif not loaded_keys[req]:
            empty.append(req)

    if missing or empty:
        if missing:
            print(f"[ERROR] Missing required keys: {', '.join(missing)}")
        if empty:
            print(f"[ERROR] Keys present but have empty values: {', '.join(empty)}")
        return False

    print(f"[OK] Configuration '{filepath}' is valid. All {len(required_keys)} required keys verified.")
    return True


def main():
    parser = argparse.ArgumentParser(description="Pre-flight Environment Validator")
    parser.add_argument("--env-file", default="01-simulation/.env", help="Path to environment file to validate")
    parser.add_argument("--keys", nargs="+", default=DEFAULT_REQUIRED_KEYS, help="List of required key names")

    args = parser.parse_args()

    success = validate_env_file(args.env_file, args.keys)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
