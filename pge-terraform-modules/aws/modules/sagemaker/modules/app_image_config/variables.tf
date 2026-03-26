variable "app_image_config_name" {
  description = "The name of the App Image Config."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,100}$", var.app_image_config_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "kernel_gateway_image_config" {
  description = "The default branch for the Git repository."
  type        = map(any)
  default     = {}
  validation {
    condition     = contains(keys(var.kernel_gateway_image_config.file_system_config), "default_gid") ? anytrue([for key, val in var.kernel_gateway_image_config.file_system_config : contains(["0", "100"], val) if key == "default_gid"]) : true
    error_message = "Valid values for 'default_gid' are 0 and 100!"
  }
  validation {
    condition     = contains(keys(var.kernel_gateway_image_config.file_system_config), "default_uid") ? anytrue([for key, val in var.kernel_gateway_image_config.file_system_config : contains(["0", "1000"], val) if key == "default_uid"]) : true
    error_message = "Valid values for 'default_uid' are 0 and 1000!"
  }
  validation {
    condition     = contains(keys(var.kernel_gateway_image_config.file_system_config), "default_gid") && contains(keys(var.kernel_gateway_image_config.file_system_config), "default_uid") ? anytrue([for key, val in var.kernel_gateway_image_config.file_system_config : contains(["0"], val) if key == "default_gid"]) && anytrue([for key, val in var.kernel_gateway_image_config.file_system_config : contains(["0"], val) if key == "default_uid"]) || anytrue([for key, val in var.kernel_gateway_image_config.file_system_config : contains(["100"], val) if key == "default_gid"]) && anytrue([for key, val in var.kernel_gateway_image_config.file_system_config : contains(["1000"], val) if key == "default_uid"]) : true
    error_message = "When specifying default_gid and default_uid, Valid value pairs are [0, 0] and [100, 1000]."
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