#!/usr/bin/env python3
"""
Python verification script to assert data integrity post-recovery.
Checks expected rows, relationships, and constraints.
"""

import subprocess
import sys


def run_sql(query: str, container: str = "scenario-pg-deletion") -> str:
    cmd = ["docker", "exec", container, "psql", "-U", "postgres", "-d", "production_db", "-t", "-c", query]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"Query failed: {res.stderr}")
    return res.stdout.strip()


def main():
    print("Executing automated post-recovery integrity checks...")
    try:
        customers = int(run_sql("SELECT COUNT(*) FROM customers;"))
        orders = int(run_sql("SELECT COUNT(*) FROM orders;"))

        assert customers >= 3, f"Expected at least 3 customers, found {customers}"
        assert orders >= 4, f"Expected at least 4 orders, found {orders}"

        # Verify foreign key integrity
        orphan_orders = int(run_sql("SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customer_id = c.id WHERE c.id IS NULL;"))
        assert orphan_orders == 0, f"Integrity violation: {orphan_orders} orphaned orders detected!"

        print("[PASS] All relational integrity and row count checks succeeded.")
        sys.exit(0)
    except Exception as e:
        print(f"[FAIL] Integrity verification failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
