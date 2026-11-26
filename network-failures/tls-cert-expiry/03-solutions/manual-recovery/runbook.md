# Manual Recovery Runbook: TLS Certificate Expiry

**Target Service:** Nginx Reverse Proxy (`scenario-tls-expiry`)  
**Target Port:** 8443 (HTTPS)  
**Required Tools:** `openssl`, `docker`, `curl`

---

## Step 1: Verify the Expiration on the Endpoint
Check the live handshake to confirm expiration:
```bash
echo | openssl s_client -connect localhost:8443 -servername localhost 2>/dev/null | openssl x509 -noout -dates
```
Confirm that `notAfter` is in the past.

---

## Step 2: Generate Renewed Certificate Keypair
Generate a fresh certificate valid for 90 days (standard industry validity):
```bash
openssl req -x509 -nodes -days 90 -newkey rsa:2048 \
    -keyout 01-simulation/certs/server.key \
    -out 01-simulation/certs/server.crt \
    -subj "/CN=localhost/O=Production/C=US"
```

---

## Step 3: Validate the New Certificate Before Reload
Verify the generated file syntax and validity window before telling Nginx to reload:
```bash
openssl x509 -in 01-simulation/certs/server.crt -noout -text | grep -A 2 "Validity"
```
Ensure `Not After` displays a valid future timestamp.

---

## Step 4: Graceful Nginx Reload
Test configuration and reload Nginx without dropping active client connections:
```bash
# Verify configuration syntax
docker exec scenario-tls-expiry nginx -t

# Trigger zero-downtime worker reload
docker exec scenario-tls-expiry nginx -s reload
```

---

## Step 5: Verify the Handshake
Confirm the live endpoint is now serving the renewed certificate:
```bash
echo | openssl s_client -connect localhost:8443 -servername localhost 2>/dev/null | openssl x509 -noout -enddate
```
Proceed to run `./04-testing/validation.sh` to complete acceptance verification.
