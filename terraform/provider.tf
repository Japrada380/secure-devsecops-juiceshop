provider "aws" {
  region = var.aws_region

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  default_tags {
    tags = {
      Project     = "Secure DevSecOps Juice Shop"
      Environment = "Production"
      Owner       = "Simon Movilidad Technical Assessment"
      ManagedBy   = "Terraform"
    }
  }
}