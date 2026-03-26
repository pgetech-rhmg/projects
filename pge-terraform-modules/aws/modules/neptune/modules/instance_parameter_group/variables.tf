variable "neptune_instance_parameter_group_family" {
  description = "The family of the Neptune parameter group"
  type        = string
  default     = "neptune1"
}

variable "neptune_instance_parameter_group_name" {
  description = "The name of the Neptune parameter group"
  type        = string
}

variable "neptune_instance_parameter_group_description" {
  description = "The description of the Neptune parameter group"
  type        = string
  default     = null
}

variable "parameter" {
  description = " The parameter of the Neptune parameter group"
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.parameter), "neptune_dfe_query_engine") ? contains(values(var.parameter), "enabled") || contains(values(var.parameter), "viaQueryHint") : true
    error_message = "Valid values for neptune_dfe_query_engine are enabled and viaQueryHint!"
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 10 && vi <= 2147483647 if ki == "neptune_query_timeout"])
    error_message = "Parameter neptune_query_timeout can be given values between 10 and 2147483647!"
  }

  validation {
    condition     = contains(keys(var.parameter), "neptune_result_cache") ? contains(values(var.parameter), "0") || contains(values(var.parameter), "1") : true
    error_message = "Valid values for neptune_result_cache are 0 and 1!"
  }

}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  tags    = var.tags
  version = "0.1.2"
}