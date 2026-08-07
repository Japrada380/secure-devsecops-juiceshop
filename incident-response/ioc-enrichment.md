# IOC Enrichment

## Incident Summary

Detection window: T+00:00 to T+02:00 UTC

---

## Indicators of Compromise (IOCs)

| IOC | Type | Evidence | Description |
|------|------|----------|-------------|
| 185.220.101.22 | IP Address | GuardDuty / VPC Flow Logs | Tor exit node used for unauthorized access and data exfiltration |
| svc-monitoring | IAM User | CloudTrail | Service account abused after privilege escalation |
| AdministratorAccess | IAM Policy | CloudTrail | Attached to svc-monitoring during the attack |
| fleetpay-prod-drivers | S3 Bucket | CloudTrail | Bucket accessed 387 times during exfiltration |
| prod-data-key | AWS KMS CMK | CloudTrail | KMS key decrypted multiple times |
| i-0abc1234def56789 | EC2 Instance | GuardDuty | Instance involved in DNS data exfiltration |
| docker.io/attacker/exfil:latest | Docker Image | ECS RegisterTaskDefinition | Malicious container registered in production |

---

## Behavioral Indicators

- Successful console login from Tor network.
- Privilege escalation through AdministratorAccess.
- Massive S3 object downloads.
- Multiple KMS decrypt operations.
- Long-lived outbound encrypted connection.
- Malicious ECS task registration.
- Attempted CloudTrail deletion (anti-forensics).
- DNS Data Exfiltration detected by GuardDuty.

---

## Initial Assessment

Severity: CRITICAL

Primary risks:

- Unauthorized AWS access.
- Privilege escalation.
- Confidential data theft.
- Persistence through ECS.
- Anti-forensics attempts.