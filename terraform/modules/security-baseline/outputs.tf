output "module_name" {
  description = "Stable module identifier retained for compatibility."
  value       = "security-baseline"
}

output "vpc_id" {
  description = "ID of the baseline VPC."
  value       = aws_vpc.fleetsec.id
}

output "subnet_ids" {
  description = "Subnet IDs grouped by tier."
  value = {
    public      = aws_subnet.public.id
    application = aws_subnet.application.id
    data        = aws_subnet.data.id
  }
}

output "log_bucket_name" {
  description = "Central security log bucket name."
  value       = aws_s3_bucket.logs.bucket
}

output "cloudtrail_arn" {
  description = "ARN of the multi-region trail."
  value       = aws_cloudtrail.security_baseline.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the regional WAF web ACL."
  value       = aws_wafv2_web_acl.fleetsec.arn
}

output "rds_secret_arn" {
  description = "ARN of the database credentials secret."
  value       = aws_secretsmanager_secret.rds_credentials.arn
  sensitive   = true
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_application_role_arn" {
  description = "ARN of the ECS application role."
  value       = aws_iam_role.ecs_application.arn
}
