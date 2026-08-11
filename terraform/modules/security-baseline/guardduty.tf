# checkov:skip=CKV2_AWS_3:Organization-wide enrollment must be configured from the AWS Organizations delegated GuardDuty administrator account.
resource "aws_guardduty_detector" "security_baseline" {
  #checkov:skip=CKV2_AWS_3:Organization-wide enrollment must be configured from the AWS Organizations delegated GuardDuty administrator account.
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = merge(local.common_tags, { Name = "${local.name}-guardduty" })
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.security_baseline.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.security_baseline.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.security_baseline.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}
