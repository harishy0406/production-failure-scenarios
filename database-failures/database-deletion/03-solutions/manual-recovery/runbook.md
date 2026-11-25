# Manual Recovery Runbook: Accidental Database Deletion

**Incident Class:** Accidental `DROP DATABASE`  
**Target Database:** `production_db`  
**Required Tools:** `docker`, `psql`, `pg_restore`

---

## Step 1: Verify Outage and Identify Backup
Confirm that `production_db` is missing:
```bash
docker exec -it scenario-pg-deletion psql -U postgres -lqt | cut -d \| -f 1 | grep -w "production_db"
```
*(If no output is returned, the database does not exist).*

Verify that the latest base backup exists in the backup volume:
```bash
docker exec -it scenario-pg-deletion ls -lh /var/backups/postgres/base/
```
Confirm the presence of `production_db_base.dump`.

---

## Step 2: Create Clean Database Shell
Recreate the empty target database:
```bash
docker exec -it scenario-pg-deletion psql -U postgres -c "CREATE DATABASE production_db;"
```

---

## Step 3: Execute pg_restore
Restore schema definitions and table data from the base backup dump:
```bash
docker exec -it scenario-pg-deletion pg_restore -U postgres -d production_db -v /var/backups/postgres/base/production_db_base.dump
```

---

## Step 4: Quick Operational Verification
Confirm table availability:
```bash
docker exec -it scenario-pg-deletion psql -U postgres -d production_db -c "\dt"
```
Query row counts:
```bash
docker exec -it scenario-pg-deletion psql -U postgres -d production_db -c "SELECT COUNT(*) FROM customers; SELECT COUNT(*) FROM orders;"
```

Proceed to run `./04-testing/validation.sh` for full data integrity verification.
