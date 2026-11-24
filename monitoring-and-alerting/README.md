# Monitoring and Observability Failures

Scenarios addressing failures in telemetry pipelines, missed alerts, monitoring agent breakdowns, and observability blackouts.

## Focus Areas
- Silent alert delivery failures and broken notification channels
- Telemetry storage exhaustion and metric drop-offs
- Prometheus server failures and ingestion backpressure
- Logging pipeline backpressure and buffer drops (Vector/Fluentbit/Logstash)
- Grafana dashboard service outages and visualization blind spots

## Scenario Index
| Scenario | Focus Tech | Severity | Status |
|---|---|---|---|
| Alertmanager Route Black Hole | Prometheus, Alertmanager | P1 | Planned |
| Telemetry Ingestion Disk Saturation | Prometheus / VictoriaMetrics | P1 | Planned |
| Log Pipeline Buffer Overflow | Fluentbit, Vector | P2 | Planned |
