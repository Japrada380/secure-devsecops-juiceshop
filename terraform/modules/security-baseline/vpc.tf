resource "aws_vpc" "fleetsec" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.common_tags, { Name = "${local.name}-vpc" })
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.fleetsec.id
  tags   = merge(local.common_tags, { Name = "${local.name}-default-deny-all" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.fleetsec.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, { Name = "${local.name}-public", Tier = "public" })
}

resource "aws_subnet" "application" {
  vpc_id                  = aws_vpc.fleetsec.id
  cidr_block              = var.application_subnet_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, { Name = "${local.name}-app", Tier = "application" })
}

resource "aws_subnet" "data" {
  vpc_id                  = aws_vpc.fleetsec.id
  cidr_block              = var.data_subnet_cidr
  map_public_ip_on_launch = false
  tags                    = merge(local.common_tags, { Name = "${local.name}-data", Tier = "database" })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${local.name}/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.security_logs.arn
  tags              = local.common_tags
}

data "aws_iam_policy_document" "flow_logs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = "${local.name}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.vpc_flow_logs.arn, "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "publish-vpc-flow-logs"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "vpc" {
  vpc_id                   = aws_vpc.fleetsec.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn             = aws_iam_role.flow_logs.arn
  max_aggregation_interval = 60
  tags                     = local.common_tags
}
