variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
  default     = "fleetsec"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region used to build regional ARNs."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the baseline VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "application_subnet_cidr" {
  description = "CIDR block for the application subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "data_subnet_cidr" {
  description = "CIDR block for the data subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period."
  type        = number
  default     = 365
}

variable "initial_secret_placeholder" {
  description = "Optional bootstrap value. Prefer populating the secret outside Terraform."
  type        = string
  default     = "REPLACE_AFTER_DEPLOYMENT"
  sensitive   = true
}

variable "create_initial_secret_version" {
  description = "Create a bootstrap secret version in Terraform state. Disabled by default."
  type        = bool
  default     = false
}

variable "secret_rotation_lambda_arn" {
  description = "ARN of the Lambda rotation function. Leave null until a compatible database rotation function is deployed."
  type        = string
  default     = null
}
