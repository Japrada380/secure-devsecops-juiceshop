# Threat Intelligence

## External Threat Intelligence

### IOC 1

**IP Address:** 185.220.101.22

Observed activity:

- Successful AWS Console login
- Data exfiltration
- Long-lived outbound encrypted session

Threat Intelligence Summary:

- Tor Exit Node
- Frequently associated with anonymous traffic
- High-risk indicator requiring immediate investigation
- Commonly observed during credential abuse and exfiltration campaigns

Required enrichment (to be validated with public sources):

| Source | Information |
|---------|-------------|
| VirusTotal | Reputation |
| AbuseIPDB | Abuse score |
| Shodan | Exposed services |
| ASN | Network owner |
| Country | Geolocation |
| OTX / MISP | Threat intelligence feeds |

---

## Compromised AWS Resources

Affected IAM User

- svc-monitoring

Affected Bucket

- fleetpay-prod-drivers

Affected KMS Key

- prod-data-key

Affected EC2

- i-0abc1234def56789

Malicious Container

- docker.io/attacker/exfil:latest

---

## Initial Threat Assessment

Attack Type

Credential compromise followed by privilege escalation and large-scale data exfiltration.

Potential ATT&CK Tactics

- Initial Access
- Persistence
- Privilege Escalation
- Defense Evasion
- Credential Access
- Discovery
- Collection
- Exfiltration

Severity

CRITICAL