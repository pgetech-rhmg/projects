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

#Variables for parameter_group
variable "name" {
  description = "The name of the Redshift parameter group."
  type        = string
}

variable "description" {
  description = "The description of the Redshift parameter group. Defaults to Managed by Terraform"
  type        = string
  default     = null
}

variable "parameter" {
  description = "A parameter group is a group of parameter that apply to all of the databases that you create in the cluster."
  type        = map(any)
  default     = {}

  validation {
    condition     = alltrue([for ki, vi in var.parameter : contains(["true", "false"], vi) if ki == "enable_case_sensitive_identifier"])
    error_message = "Valid values for enable_case_sensitive_identifier are true and false."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : contains(["true", "false"], vi) if ki == "auto_analyze"])
    error_message = "Valid values for auto_analyze are true and false."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : can(regex("([ISO|Postgres|SQL|German], [DMY|MDY|YMD])", vi)) if ki == "datestyle"])
    error_message = "Valid values for datestyle Format specification (ISO, Postgres, SQL, or German), and year/month/day ordering (DMY, MDY, YMD). ex: ISO, MDY ."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= -15 && vi <= 2 if ki == "extra_float_digits"])
    error_message = "Parameter extra_float_digits can be given values between -15 and 2."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 0 && vi <= 10 if ki == "max_concurrency_scaling_clusters"])
    error_message = "Parameter max_concurrency_scaling_clusters can be given values between 0 and 10."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : contains(["true", "false"], vi) if ki == "use_fips_ssl"])
    error_message = "Valid values for use_fips_ssl are true and false."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : contains(["true", "false"], vi) if ki == "auto_mv"])
    error_message = "Valid values for auto_mv are true and false."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : vi >= 0 || vi >= 100 || vi <= 2147483647 if ki == "statement_timeout"])
    error_message = "Parameter statement_timeout value should be more than 0."
  }

  validation {
    condition     = alltrue([for ki, vi in var.parameter : can(regex("[$user, public, ], [a-z]", vi)) if ki == "search_path"])
    error_message = "Valid value for search_path is $user, public."
  }
}