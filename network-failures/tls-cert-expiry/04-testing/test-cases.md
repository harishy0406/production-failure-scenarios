# Test Cases: TLS Certificate Expiry

## Acceptance Criteria
Following certificate renewal, the endpoint must satisfy these checks before closing the incident:

| Test ID | Objective | Procedure | Expected Result |
|---|---|---|---|
| TC-01 | Container Health | `docker ps` | `scenario-tls-expiry` is running and healthy |
| TC-02 | Valid Certificate Date | `openssl s_client` + `openssl x509 -checkend 86400` | Expiration date is at least 24 hours in the future (exit code 0) |
| TC-03 | HTTPS Handshake | `curl -k https://localhost:8443/` | Returns HTTP 200 with status "healthy" |
| TC-04 | Zero-Downtime Reload | `docker exec scenario-tls-expiry nginx -t` | Configuration syntax is valid |
| TC-05 | HTTP to HTTPS Redirect | `curl -sI http://localhost:8080/` | Returns HTTP 301 redirecting to port 8443 |
