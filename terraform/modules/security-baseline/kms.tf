##############################################
# KMS KEY FOR S3 / CLOUDTRAIL
##############################################

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "s3" {
  description             = "CMK for S3 encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid = "EnableRootPermissions"

        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = "kms:*"

        Resource = "*"
      },

      {
        Sid = "AllowCloudTrail"

        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-s3-kms"
    }
  )
}

resource "aws_kms_alias" "s3" {
  name          = "alias/fleetsec-s3"
  target_key_id = aws_kms_key.s3.key_id
}