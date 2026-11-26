# Network Failure Scenarios

Case studies addressing network routing breakdowns, transport security lapses, traffic bottlenecks, and service discovery failures.

## Focus Areas
- Domain Name System (DNS) outages and lookup failures
- TLS/SSL certificate expiration and cipher mismatches
- Firewall, iptables, and security group misconfigurations
- Reverse proxy, ingress, and load balancer failures
- Packet loss, latency degradation, and MTU issues

## Scenario Index
| Scenario | Focus Tech | Severity | Status | Path |
|---|---|---|---|---|
| TLS Certificate Expiry | OpenSSL, Nginx, Docker | P1 | Draft | [tls-cert-expiry](./tls-cert-expiry/) |
| DNS Resolution Failure | CoreDNS / BIND | P1 | Planned | `dns-resolution-failure` |
| Firewall Misconfiguration | iptables / nftables | P1 | Planned | `firewall-misconfiguration` |
| Reverse Proxy Upstream Dropping | Nginx / HAProxy | P2 | Planned | `reverse-proxy-dropping` |
