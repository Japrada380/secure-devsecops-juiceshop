data "aws_iam_policy_document" "config_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = "${local.name}-config"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "security_baseline" {
  name     = "${local.name}-config-recorder"
  role_arn = aws_iam_role.config.arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "security_baseline" {
  name           = "${local.name}-config-delivery"
  s3_bucket_name = aws_s3_bucket.logs.bucket
  s3_key_prefix  = "config"
  snapshot_delivery_properties { delivery_frequency = "TwentyFour_Hours" }
  depends_on = [aws_config_configuration_recorder.security_baseline, aws_s3_bucket_policy.logs]
}

resource "aws_config_configuration_recorder_status" "security_baseline" {
  name       = aws_config_configuration_recorder.security_baseline.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.security_baseline]
}
