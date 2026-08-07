# AWS CLI Containment Playbook

## Objective

Contain the active compromise while preserving forensic evidence.

---

## Step 1 - Disable compromised IAM user

```bash
aws iam update-login-profile \
  --user-name svc-monitoring \
  --password-reset-required
```

Rollback

Restore the account after credential rotation and investigation.

---

## Step 2 - Detach AdministratorAccess

```bash
aws iam detach-user-policy \
  --user-name svc-monitoring \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Rollback

Reattach only approved least-privilege policies.

---

## Step 3 - Revoke active sessions

```bash
aws iam delete-login-profile \
  --user-name svc-monitoring
```

Rollback

Create a new login profile after incident closure.

---

## Step 4 - Isolate compromised EC2

```bash
aws ec2 modify-instance-attribute \
  --instance-id i-0abc1234def56789 \
  --groups sg-quarantine
```

Rollback

Restore the original Security Group after forensic analysis.

---

## Step 5 - Preserve forensic evidence

Create EBS snapshot

```bash
aws ec2 create-snapshot \
  --volume-id vol-xxxxxxxx \
  --description "IR Snapshot"
```

Copy CloudTrail logs

```bash
aws s3 cp s3://cloudtrail-logs ./evidence --recursive
```

Rollback

Not applicable.