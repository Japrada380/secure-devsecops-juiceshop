resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "fleetsec-rds-credentials"
  recovery_window_in_days = 30

  kms_key_id = aws_kms_key.s3.arn

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-rds-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    username            = "dbadmin"
    initial_placeholder = var.initial_secret_placeholder
  })
}