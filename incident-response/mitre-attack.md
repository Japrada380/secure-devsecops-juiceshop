# MITRE ATT&CK Mapping

| ATT&CK ID | Technique | Evidence | Mitigation |
|------------|-----------|----------|------------|
| T1078 | Valid Accounts | Successful login using compromised IAM credentials | MFA, credential rotation, IAM Identity Center |
| T1098 | Account Manipulation | AdministratorAccess attached to svc-monitoring | Least privilege, SCPs, IAM monitoring |
| T1562 | Impair Defenses | Attempt to delete CloudTrail | SCP protection, CloudTrail log validation |
| T1530 | Data from Cloud Storage Object | 387 S3 GetObject operations | S3 monitoring, anomaly detection |
| T1041 | Exfiltration Over C2 Channel | 49 GB outbound traffic to external IP | Network monitoring, GuardDuty |
| T1610 | Deploy Container | Malicious ECS task registration | Image signing, ECR scanning, deployment approvals |

---

## Summary

The attack followed a complete cloud attack lifecycle:

1. Initial Access
2. Privilege Escalation
3. Defense Evasion
4. Collection
5. Exfiltration
6. Persistence