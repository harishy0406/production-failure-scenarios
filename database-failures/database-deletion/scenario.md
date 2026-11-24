# Detailed Scenario Narrative: Accidental Database Deletion

## Context
During off-peak maintenance, an engineer intended to purge a temporary staging database named `production_db_staging` on a remote host. Due to a connection string configuration error, the client session was connected directly to the primary cluster.

The command executed was:
```sql
DROP DATABASE production_db;
```

Within seconds, application error rates climbed to 100%, and incoming user requests began returning HTTP 500 errors.

## Failure Lifecycle Walkthrough

### Phase 1: Failure Identification
- APM monitors alert on sudden database connection drops: `FATAL: database "production_db" does not exist`.
- Application connection pools exhaust as retry loops fail.

### Phase 2: Failure Simulation
- A PostgreSQL container is initialized with seeded customer data and transaction activity.
- Base backups and WAL archiving are configured.
- The failure script drops the database to simulate the incident.

### Phase 3: Impact Assessment
- Blast radius covers all customer-facing read and write operations.
- Downtime clock starts immediately.

### Phase 4: Forensic Investigation
- PostgreSQL server log examination isolates the drop timestamp.
- Backup manifest is inspected for latest valid base snapshot.
- WAL archive sequence is verified for continuity.

### Phase 5: Recovery
- PostgreSQL server instance is stopped or switched to recovery mode.
- Base backup files are deployed to data directory.
- `recovery.signal` and `target_time` are configured for PITR.
- Cluster is brought back online and recovery replay completes.

### Phase 6: Post-Recovery Validation
- Row counts, schema constraints, and transaction log checksums are validated.
- Application connectivity is tested.

### Phase 7: Prevention
- Least privilege access implemented; destructive commands restricted to emergency superuser roles with multi-party approval.
