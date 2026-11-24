# Database Failure Scenarios

This directory houses realistic database failure simulations, forensic root cause analyses, recovery procedures, and prevention patterns.

## Focus Areas
- Data loss, accidental deletion, and disaster recovery (PITR, backup restoration)
- Storage exhaustion and write-ahead log (WAL) saturation
- Connection pool depletion and deadlocks
- Data corruption and replica desynchronization

## Scenario Index
| Scenario | Focus Tech | Severity | Status | Path |
|---|---|---|---|---|
| Accidental Database Deletion | PostgreSQL, Docker | P0 | Draft | [database-deletion](./database-deletion/) |
| Disk-Full Database Crash | PostgreSQL, Linux | P0 | Planned | `disk-full-crash` |
| Connection Pool Exhaustion | PostgreSQL, PgBouncer | P1 | Planned | `pool-exhaustion` |
| Database Corruption | PostgreSQL, Linux | P1 | Planned | `data-corruption` |
| Replication Lag & Desync | MySQL / Postgres | P2 | Planned | `replication-failure` |
