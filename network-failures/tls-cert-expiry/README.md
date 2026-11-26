---
title: "TLS/SSL Certificate Expiration"
category: "network-failures"
severity: "P1"
technologies: ["OpenSSL", "Nginx", "Docker", "Bash", "Python"]
difficulty: "Beginner"
estimated_time: "15m"
status: "Draft"
---

# Scenario: TLS/SSL Certificate Expiration

## 1. Summary
A production public reverse proxy begins rejecting HTTPS connections after its SSL certificate passes its validity timestamp. Browsers display security warnings, and automated API clients fail with exit code errors like `SSL_ERROR_EXPIRED_CERT_DATE` or `certificate has expired`.

This scenario covers simulating an expired TLS certificate on Nginx in Docker, diagnosing certificate expiration timestamps with OpenSSL, performing zero-downtime certificate renewal, and configuring automated renewal probes.

## 2. Metadata
- **Category:** Network Failures
- **Severity:** P1 (High, client traffic blocked by TLS validation)
- **Primary Tech:** OpenSSL, Nginx, Docker, Bash, Python
- **Estimated Time:** 15 minutes
- **Status:** Draft

## 3. Quick Start
Execute the following commands from this scenario directory:

1. **Start the sandbox environment:**
   ```bash
   ./01-simulation/setup.sh
   ```
2. **Inject the expired certificate:**
   ```bash
   ./01-simulation/reproduce-failure.sh
   ```
3. **Investigate the TLS handshake:**
   Follow diagnostic steps in `02-root-cause-analysis/analysis.md` using `curl` and `openssl s_client`.
4. **Apply certificate renewal:**
   Follow manual steps in `03-solutions/manual-recovery/runbook.md` or execute the automated renewal script:
   ```bash
   python3 03-solutions/automated-recovery/renew_certificate.py
   ```
5. **Validate TLS health:**
   ```bash
   ./04-testing/validation.sh
   ```
6. **Teardown the sandbox:**
   ```bash
   ./01-simulation/teardown.sh
   ```

## 4. Incident Impact
- **Blast Radius:** All incoming HTTPS traffic routed through the edge proxy.
- **RTO:** Under 5 minutes if certificate generation and zero-downtime reload are automated.
- **RPO:** Zero (no persistent data loss, purely a transport-layer availability failure).

## 5. Recovery Approaches
- **Approach 1 (Manual):** Generate a valid certificate keypair using OpenSSL, copy to `/etc/nginx/certs/`, and reload Nginx via `nginx -s reload`.
- **Approach 2 (Automated):** Use `renew_certificate.py` to generate an updated certificate, place it on the volume, and trigger a graceful Nginx reload without dropping connections.

## 6. Prevention
- Configure automated certificate management with Certbot or cert-manager.
- Set up monitoring alerts (Prometheus blackbox exporter or custom cron probe) triggering 30 days and 7 days prior to expiry.
