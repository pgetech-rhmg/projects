variable "studio_lifecycle_config_name" {
  description = "The name of the Studio Lifecycle Configuration to create."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,62}$", var.studio_lifecycle_config_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "studio_lifecycle_config_app_type" {
  description = "The App type that the Lifecycle Configuration is attached to. Valid values are JupyterServer and KernelGateway."
  type        = string
  validation {
    condition     = contains(["JupyterServer", "KernelGateway"], var.studio_lifecycle_config_app_type)
    error_message = "Error! values for 'studio_lifecycle_config_app_type' should be 'JupyterServer & KernelGateway ."
  }
}

variable "studio_lifecycle_config_content" {
  description = "The content of your Studio Lifecycle Configuration script. This content must be base64 encoded."
  type        = string
  validation {
    condition     = can(base64encode(var.studio_lifecycle_config_content))
    error_message = "Error! Invalid policy. Content must be base64 encoded."
  }
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