#variables for cluster parameter group
variable "docdb_cluster_parameter_group_family" {
  description = "The family of the documentDB cluster parameter group."
  type        = string
}

variable "docdb_cluster_parameter_group_name" {
  description = "The name of the documentDB cluster parameter group. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "docdb_cluster_parameter_group_description" {
  description = "The description of the documentDB cluster parameter group. Defaults to Managed by Terraform"
  type        = string
  default     = null
}

variable "parameter" {
  description = "A list of documentDB parameters to apply"
  type        = list(map(string))
  default     = []

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 3600 && vi <= 604800 if ki == "change_stream_log_retention_duration"])
    error_message = "Parameter change_stream_log_retention_duration can be given values between 3600 and 604800!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : contains(["enabled", "disabled"], vi) if ki == "profiler"])
    error_message = "Valid values for profiler are enabled and disabled!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 0.0 && vi <= 1.0 if ki == "profiler_sampling_rate"])
    error_message = "Parameter profiler_sampling_rate can be given values between 0.0 and 1.0!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 50 && vi <= 2147483646 if ki == "profiler_threshold_ms"])
    error_message = "Parameter profiler_threshold_ms can be given values between 50 and 2147483646!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : contains(["enabled", "disabled"], vi) if ki == "ttl_monitor"])
    error_message = "Valid values for ttl_monitor are enabled and disabled!"
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