# Preventive Measures: TLS Certificate Expiry

## 1. Automated Certificate Lifecycle Management
- Transition from manual renewal to automated ACME protocol clients (Let's Encrypt with Certbot or cert-manager in Kubernetes).
- Use automated hooks (`--deploy-hook "nginx -s reload"`) to ensure web server worker processes reload certificates automatically upon renewal.

## 2. Prometheus Blackbox Exporter Monitoring
Deploy Prometheus Blackbox Exporter to probe external endpoints and export the certificate expiry metric `probe_ssl_earliest_cert_expiry`.

Configure Alertmanager rules:

```yaml
groups:
  - name: tls_alerts
    rules:
      - alert: TLSCertificateExpiringIn30Days
        expr: (probe_ssl_earliest_cert_expiry - time()) / 86400 < 30
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "SSL certificate for {{ $labels.instance }} expires in less than 30 days"

      - alert: TLSCertificateExpiringIn7Days
        expr: (probe_ssl_earliest_cert_expiry - time()) / 86400 < 7
        for: 15m
        labels:
          severity: critical
        annotations:
          summary: "CRITICAL: SSL certificate for {{ $labels.instance }} expires in less than 7 days"
```

## 3. Scheduled Health Probes
Run a lightweight cron job or daemon that checks all internal and external domain endpoints daily and notifies alerting channels if validity is under 14 days.
