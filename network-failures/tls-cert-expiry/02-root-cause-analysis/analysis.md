# Root Cause Analysis: TLS Certificate Expiration

## 1. Incident Overview
- **Incident Description:** Clients cannot establish secure connections to the edge proxy.
- **Root Cause Classification:** Expired X.509 certificate served on TLS port 443 (or test port 8443).

## 2. Forensic Investigation & Evidence

### Step 1: Probe the Handshake with Curl
Run a verbose curl request against the proxy endpoint:
```bash
curl -Iv https://localhost:8443 2>&1 | grep -E "(expire|SSL|issuer)"
```

Sample output:
```text
* SSL certificate verify result: certificate has expired (10)
* Closing connection 0
curl: (60) SSL certificate problem: certificate has expired
```

### Step 2: Inspect Server Certificate via OpenSSL
Connect to the TLS socket and parse the X.509 dates directly:
```bash
echo | openssl s_client -connect localhost:8443 -servername localhost 2>/dev/null | openssl x509 -noout -dates -subject -issuer
```

Sample output:
```text
notBefore=Nov 20 00:00:00 2024 GMT
notAfter=Nov 25 00:00:00 2024 GMT
subject=CN = localhost
issuer=CN = localhost
```
The `notAfter` date precedes the current system timestamp, proving the certificate has expired.

### Step 3: Inspect Files on Disk
Check the certificate file currently mounted into the web server:
```bash
openssl x509 -in /etc/nginx/certs/server.crt -noout -enddate
```

If the file on disk is already updated, Nginx simply needs a reload signal (`nginx -s reload`). If the file on disk is expired, renewal must be performed.

## 3. Contributing Factors
1. Lack of monitoring alerts for expiration dates 30 days in advance.
2. Failure to automate certificate replacement and daemon reload.
