data "aws_iam_policy_document" "kms" {
  #checkov:skip=CKV_AWS_109:KMS key policies require Resource "*" to refer to the key to which the policy is attached; principals and service use are constrained below.
  #checkov:skip=CKV_AWS_111:KMS key policies require Resource "*"; write-capable service actions are constrained by service principal, source account, and source ARN.
  #checkov:skip=CKV_AWS_356:AWS KMS key policy statements use Resource "*" because the key ARN is not available inside its own policy.
  statement {
    sid       = "EnableAccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowCloudTrailEncryption"
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt", "kms:DescribeKey"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${local.name}-cloudtrail"]
    }
  }

  statement {
    sid       = "AllowAWSLogServices"
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "logs.${var.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "security_logs" {
  description             = "KMS key for ${local.name} security logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = merge(local.common_tags, { Name = "${local.name}-security-logs" })
}

resource "aws_kms_alias" "security_logs" {
  name          = "alias/${local.name}-security-logs"
  target_key_id = aws_kms_key.security_logs.key_id
}

data "aws_iam_policy_document" "kms_secrets" {
  #checkov:skip=CKV_AWS_109:KMS key policies require Resource "*" to refer to the key to which the policy is attached; use is constrained by principal and kms:ViaService.
  #checkov:skip=CKV_AWS_111:KMS key policies require Resource "*"; cryptographic actions are constrained to the account and Secrets Manager service path.
  #checkov:skip=CKV_AWS_356:AWS KMS key policy statements use Resource "*" because the key ARN is not available inside its own policy.
  statement {
    sid       = "EnableAccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "AllowSecretsManagerUse"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.aws_region}.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "secrets" {
  description             = "KMS key for ${local.name} application secrets"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_secrets.json
  tags                    = merge(local.common_tags, { Name = "${local.name}-secrets" })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}
