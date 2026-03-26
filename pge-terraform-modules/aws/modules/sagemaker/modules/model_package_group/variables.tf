variable "model_package_group_name" {
  description = "The name of the model group."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.model_package_group_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "model_package_group_description" {
  description = "A description for the model group."
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}