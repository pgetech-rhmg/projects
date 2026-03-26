variable "ecr_name" {
  description = "Name of the repository."
  type        = string
}

variable "kms_key" {
  description = "The ARN of the KMS key"
  type        = string
  default     = null
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Error! Valid values for image tag mutability are (MUTABLE, IMMUTABLE)."
  }
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = false
}

variable "policy" {
  description = "Valid JSON document representing a resource policy"
  type        = any
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for ECR."
  }
}

variable "lifecycle_policy_enable" {
  description = "Enable or disable lifecycle policy."
  type        = bool
  default     = false
}

variable "lifecycle_policy" {
  description = "The policy document for lifecycle policy."
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.lifecycle_policy))
    error_message = "Error! Invalid JSON for lifecycle policy. Provide a valid JSON for ECR."
  }
}

variable "replication_configuration_enable" {
  description = "Enable or disable replication configuration for a registry."
  type        = bool
  default     = false
}

variable "replication_configuration_region" {
  description = "A Region to replicate."
  type        = string
  default     = null
}

variable "replication_configuration_registry_id" {
  description = "The account ID of the destination registry to replicate."
  type        = string
  default     = null
}

variable "replication_configuration_filter" {
  description = "The repository filter details."
  type        = string
  default     = null
}

variable "replication_configuration_filter_type" {
  description = "The repository filter type."
  type        = string
  default     = null

  validation {
    condition = anytrue([
      var.replication_configuration_filter_type == null,
      var.replication_configuration_filter_type == "PREFIX_MATCH"
    ])
    error_message = "Error! Valid values for replication configuration filter type is (PREFIX_MATCH)."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
