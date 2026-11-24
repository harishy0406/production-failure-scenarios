# Test Cases and Validation Plan

## Validation Objectives
Ensure that post-recovery, the database is healthy, the application can reconnect, and data integrity meets RPO requirements.

## Test Cases

| Test ID | Objective | Command / Procedure | Expected Result |
|---|---|---|---|
| TC-01 | Database Connectivity | `pg_isready -d production_db` | Returns exit code 0 |
| TC-02 | Schema Verification | Query `information_schema.tables` | All expected application tables exist |
| TC-03 | Row Count Integrity | Count rows in critical tables (`users`, `orders`) | Row counts match pre-drop checkpoint |
| TC-04 | Transaction Continuity | Check latest transaction timestamp | Transaction log timestamp is within RPO window (< 60s from drop) |
| TC-05 | Write Ability | Insert test canary record and delete it | Transaction commits successfully |
