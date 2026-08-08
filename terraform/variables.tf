variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "fleetsec"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "prod"
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)

  default = {
    Project     = "FleetSec"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}