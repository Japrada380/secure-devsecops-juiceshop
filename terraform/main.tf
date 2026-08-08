module "security_baseline" {
  source = "./modules/security-baseline"

  tags = var.common_tags
}