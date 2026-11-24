# Root Cause Analysis: Accidental Database Deletion

## 1. Incident Overview
- **Incident Description:** Total drop of `production_db` via interactive SQL session.
- **Root Cause Classification:** Operational human error enabled by lack of administrative least-privilege guardrails.

## 2. Forensic Timeline & Evidence
- **Log Source:** `/var/log/postgresql/postgresql.log`
- **Identified Log Entry:**
  ```text
  2026-11-24 14:15:22 UTC [1042] postgres@production_db STATEMENT:  DROP DATABASE production_db;
  2026-11-24 14:15:23 UTC [1042] postgres@production_db LOG:  database "production_db" dropped
  ```

## 3. Contributing Factors
1. **Excessive Privileges:** The operator console possessed unrestricted superuser credentials (`postgres`).
2. **Missing Environment Safeguards:** Staging and production credentials shared identical host configurations without environment visual indicators.
3. **Absence of DDL Protection:** Destructive operations like `DROP DATABASE` had no soft-delete or confirmation gates.
