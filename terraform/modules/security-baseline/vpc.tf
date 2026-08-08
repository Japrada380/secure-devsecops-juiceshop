resource "aws_vpc" "fleetsec" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.fleetsec.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-public"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "application" {
  vpc_id     = aws_vpc.fleetsec.id
  cidr_block = "10.0.2.0/24"

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-app"
      Tier = "application"
    }
  )
}

resource "aws_subnet" "data" {
  vpc_id     = aws_vpc.fleetsec.id
  cidr_block = "10.0.3.0/24"

  tags = merge(
    var.tags,
    {
      Name = "fleetsec-data"
      Tier = "database"
    }
  )
}