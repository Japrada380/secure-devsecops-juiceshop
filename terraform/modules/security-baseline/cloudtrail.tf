resource "aws_cloudtrail" "security_baseline" {
  name                          = "fleetsec-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  kms_key_id = aws_kms_key.s3.arn

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-cloudtrail"
    }
  )
}