resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${local.name}-rds-credentials"
  description             = "Database credentials managed outside Terraform after bootstrap"
  recovery_window_in_days = 30
  kms_key_id              = aws_kms_key.secrets.arn
  tags                    = merge(local.common_tags, { Name = "${local.name}-rds-credentials" })
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  count     = var.create_initial_secret_version ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username            = "dbadmin"
    initial_placeholder = var.initial_secret_placeholder
  })
  lifecycle { ignore_changes = [secret_string] }
}

resource "aws_secretsmanager_secret_rotation" "rds_credentials" {
  count               = var.secret_rotation_lambda_arn == null ? 0 : 1
  secret_id           = aws_secretsmanager_secret.rds_credentials.id
  rotation_lambda_arn = var.secret_rotation_lambda_arn

  rotation_rules {
    automatically_after_days = 30
  }
}
