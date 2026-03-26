# Variables for Model Package Group Policy

variable "model_package_group_name" {
  description = "The name of the model package group."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,62}$", var.model_package_group_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, _ - (hyphen)."
  }
}

variable "model_package_group_resource_policy" {
  description = "The resource policy for the model group."
  type        = string
  validation {
    condition     = length(var.model_package_group_resource_policy) <= 20480
    error_message = "Error! Length of policy should be less than or equals to 20480"
  }
}