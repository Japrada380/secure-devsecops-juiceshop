variable "tags" {
  description = "Common resource tags"

  type = map(string)

  default = {}
}
variable "initial_secret_placeholder" {
  description = "Placeholder value used only for initial secret creation."
  type        = string
  default     = "REPLACE_AFTER_DEPLOYMENT"
}