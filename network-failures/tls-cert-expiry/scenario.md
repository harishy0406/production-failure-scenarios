# Detailed Scenario Narrative: TLS Certificate Expiry

## Context
At 00:00 UTC on the first of the month, customer support received a flood of user reports: the web application was displaying a red browser warning banner stating "Your connection is not private" with error code `NET::ERR_CERT_DATE_INVALID`.

At the same time, automated payment webhooks and mobile mobile clients failed completely because strict TLS validation aborted HTTP client handshakes:
```text
curl: (60) SSL certificate problem: certificate has expired
```

## Why It Happens in Production
1. **Manual Renewal Processes:** A team relies on calendar reminders rather than automated renewal daemons like Certbot or cert-manager.
2. **ACME Challenge Failures:** Automated renewal scripts fail silently (e.g. DNS API token expired, rate limit hit, or port 80 challenge blocked by firewall), and no alert was fired before the expiration date arrived.
3. **Forgotten Server Reload:** The certificate was renewed on disk, but Nginx or HAProxy was never signaled to reload the certificate into memory.

## Investigation Path
1. Check endpoint with `curl -Iv https://localhost:8443` to inspect the handshake.
2. Extract the exact expiration date using `openssl s_client`:
   ```bash
   openssl s_client -connect localhost:8443 -servername localhost </dev/null 2>/dev/null | openssl x509 -noout -dates
   ```
3. Verify certificate files on disk versus the in-memory certificate served by Nginx.

## Resolution
Generate or renew the certificate files, verify their validity dates with OpenSSL, and issue a zero-downtime reload to Nginx:
```bash
nginx -s reload
```
This forces Nginx worker processes to load the new certificate for new connections without killing active requests.
