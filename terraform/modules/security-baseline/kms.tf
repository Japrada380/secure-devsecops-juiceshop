resource "aws_kms_key" "s3" {
  description             = "CMK for S3 encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

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