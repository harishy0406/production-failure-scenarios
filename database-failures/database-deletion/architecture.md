# Architecture Specification: Database Deletion Scenario

## System Components

1. **PostgreSQL Container:**
   - Image: `postgres:16-alpine`
   - Volumes:
     - `/var/lib/postgresql/data` (Active database cluster)
     - `/var/backups/postgres/base` (Full snapshot storage)
     - `/var/backups/postgres/wal` (Archived WAL segments)

2. **Workload Generator:**
   - Lightweight script writing periodic order/user transactions to simulate ongoing production traffic prior to failure.

3. **Archive Process:**
   - WAL archiving enabled via `archive_command = 'test ! -f /var/backups/postgres/wal/%f && cp %p /var/backups/postgres/wal/%f'`.
