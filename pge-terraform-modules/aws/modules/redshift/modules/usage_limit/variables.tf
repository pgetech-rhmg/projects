#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

#Variables for usage_limit
variable "cluster_identifier" {
  description = "The identifier of the cluster that you want to limit usage."
  type        = string
}

variable "breach_action" {
  description = "The action that Amazon Redshift takes when the limit is reached. The default is log."
  type        = string
  default     = null

  validation {
    condition     = contains(["log", "emit-metric", "disable"], var.breach_action)
    error_message = "Valid values for breach action are log, emit-metric and disable."
  }
}

variable "validate_feature_limit" {
  description = "The type of limit. Depending on the feature type, this can be based on a time duration or data size. If FeatureType is spectrum, then LimitType must be data-scanned. If FeatureType is concurrency-scaling, then LimitType must be time. If FeatureType is cross-region-datasharing, then LimitType must be data-scanned. Valid values are data-scanned, and time."
  type = object({
    feature_type = string
    limit_type   = string
  })

  validation {
    condition     = contains(["spectrum", "concurrency-scaling", "cross-region-datasharing"], var.validate_feature_limit.feature_type)
    error_message = "Valid values for feature type are spectrum, concurrency-scaling, and cross-region-datasharing."
  }

  validation {
    condition     = contains(["data-scanned", "time"], var.validate_feature_limit.limit_type)
    error_message = "Valid values for limit types are data-scanned and time."
  }

  validation {
    condition     = var.validate_feature_limit.feature_type == "spectrum" ? var.validate_feature_limit.limit_type == "data-scanned" : true
    error_message = "Enter valid feature type value. When feature type is spectrum then limit type must be data-scanned."
  }

  validation {
    condition     = var.validate_feature_limit.feature_type == "cross-region-datasharing" ? var.validate_feature_limit.limit_type == "data-scanned" : true
    error_message = "Enter valid feature type value. When feature type is cross-region-datasharing then limit type must be data-scanned."
  }

  validation {
    condition     = var.validate_feature_limit.feature_type == "concurrency-scaling" ? var.validate_feature_limit.limit_type == "time" : true
    error_message = "Enter valid feature type value. When feature type is concurrency-scaling then limit type must be time."
  }

}

variable "amount" {
  description = "The limit amount. If time-based, this amount is in minutes. If data-based, this amount is in terabytes (TB)."
  type        = number
  validation {
    condition     = signum(var.amount) == 1
    error_message = "The value must be a positive number."
  }
}

variable "period" {
  description = "The time period that the amount applies to. A weekly period begins on Sunday. The default is monthly."
  type        = string
  validation {
    condition     = contains(["daily", "monthly", "weekly"], var.period)
    error_message = "Valid values for period are daily, weekly, and monthly."
  }
}