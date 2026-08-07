# Root Cause Analysis (RCA)

## Executive Summary

The incident began with the successful use of compromised AWS credentials belonging to the `svc-monitoring` service account. The attacker leveraged valid credentials to authenticate, escalate privileges, access sensitive resources, and exfiltrate data before attempting to disable logging.

---

## Probable Initial Access

**Hypothesis:**

Compromised AWS credentials associated with the `svc-monitoring` IAM user.

Possible causes include:

- Credential leakage
- Inadequate secret management
- Lack of credential rotation
- Absence of multi-factor authentication (MFA)

---

## Attack Path

1. Successful AWS Console login from a Tor exit node.
2. Creation of a login profile for `svc-monitoring`.
3. Privilege escalation by attaching the `AdministratorAccess` policy.
4. Bulk access to the `fleetpay-prod-drivers` S3 bucket.
5. Multiple decrypt operations against the `prod-data-key` KMS key.
6. Large outbound encrypted connection (~49 GB).
7. Registration of a malicious ECS task using `docker.io/attacker/exfil:latest`.
8. Attempt to delete CloudTrail logs (blocked by SCP).
9. GuardDuty detection of DNS data exfiltration.

---

## Why Existing Controls Failed

- Excessive IAM permissions.
- Insufficient credential protection.
- Lack of preventive controls for privilege escalation.
- Monitoring detected the attack but did not prevent early-stage actions.
- Insufficient anomaly detection for abnormal S3 access.

---

## Lessons Learned

- Enforce least privilege.
- Enable MFA for privileged users.
- Rotate credentials regularly.
- Strengthen monitoring and automated response.
- Protect logs against tampering.