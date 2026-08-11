##############################################
# IAM ACCOUNT PASSWORD POLICY
##############################################

resource "aws_iam_account_password_policy" "security_baseline" {
  minimum_password_length      = 14
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true

  allow_users_to_change_password = true

  max_password_age          = 90
  password_reuse_prevention = 24
  hard_expiry               = false
}

##############################################
# ECS TASK EXECUTION ROLE
##############################################

resource "aws_iam_role" "ecs_task_execution" {
  name = "fleetsec-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-ecs-task-execution-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############################################
# ECS APPLICATION ROLE
##############################################

resource "aws_iam_role" "ecs_application" {
  name = "fleetsec-ecs-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-ecs-application-role"
    }
  )
}

##############################################
# SECRETS MANAGER ACCESS POLICY
##############################################

resource "aws_iam_policy" "secrets_access" {
  name        = "fleetsec-secrets-access"
  description = "Least privilege access to Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_access" {
  role       = aws_iam_role.ecs_application.name
  policy_arn = aws_iam_policy.secrets_access.arn
}