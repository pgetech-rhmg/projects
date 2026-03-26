# Variables for tags

variable "tags" {
  description = "Key-value map of resources tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

# Variables for project

variable "project_name" {
  description = "The name of the Project."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-.]?[a-zA-Z0-9]){0,31}$", var.project_name))
    error_message = "Allowed characters: a-z, A-Z, 0-9, - (hyphen)."
  }
}

variable "service_catalog_provisioning_details" {
  description = "The product ID and provisioning artifact ID to provision a service catalog."
  type        = list(any)
}

variable "project_description" {
  description = "A description for the project."
  type        = string
  default     = null
}