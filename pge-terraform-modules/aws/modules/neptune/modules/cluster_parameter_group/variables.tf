#variables for neptune cluster parameter group
variable "neptune_cluster_parameter_group_family" {
  description = "The family of the neptune cluster parameter group."
  type        = string
  default     = "neptune1"
}

variable "neptune_cluster_parameter_group_name" {
  description = "The name of the neptune cluster parameter group. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "neptune_cluster_parameter_group_description" {
  description = "The description of the neptune cluster parameter group. Defaults to Managed by Terraform"
  type        = string
  default     = null
}

variable "parameter" {
  description = "A list of neptune parameters to apply"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 10 && vi <= 2147483647 if ki == "neptune_query_timeout"])
    error_message = "Parameter neptune_query_timeout can be given values between 10 and 2147483647!"
  }

  validation {
    condition     = contains(keys(var.parameter), "neptune_streams") ? contains(values(var.parameter), "0") || contains(values(var.parameter), "1") : true
    error_message = "Valid values for neptune_streams are 0 and 1!"
  }

  validation {
    condition     = contains(keys(var.parameter), "neptune_lookup_cache") ? contains(values(var.parameter), "0") || contains(values(var.parameter), "1") : true
    error_message = "Valid values for neptune_lookup_cache are 0 and 1!"
  }

  validation {
    condition     = contains(keys(var.parameter), "neptune_dfe_query_engine") ? contains(values(var.parameter), "enabled") || contains(values(var.parameter), "viaQueryHint") : true
    error_message = "Valid values for neptune_dfe_query_engine are enabled and viaQueryHint!"
  }

  validation {
    condition     = contains(keys(var.parameter), "neptune_result_cache") ? contains(values(var.parameter), "0") || contains(values(var.parameter), "1") : true
    error_message = "Valid values for neptune_result_cache are 0 and 1!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : can(regex("^arn:aws:iam::\\w+", vi)) if ki == "neptune_ml_iam_role"])
    error_message = "For neptune_ml_iam_role, value must be valid IAM role ARN used in Neptune ML in form of 'arn:aws:iam::xxxxxx'!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : can(regex("^[a-zA-Z0-9](-*[a-zA-Z0-9]){0,62}", vi)) if ki == "neptune_ml_endpoint"])
    error_message = "For neptune_ml_endpoint, the value can be any valid SageMaker endpoint name. The name can have up to 63 characters. Valid characters: A-Z, a-z, 0-9, and - (hyphen)!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : can(jsondecode(vi)) if ki == "neptune_autoscaling_config"])
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON for parameter neptune_autoscaling_config!"
  }

}

#variables for tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}