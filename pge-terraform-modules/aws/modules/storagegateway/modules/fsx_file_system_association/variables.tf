variable "gateway_arn" {
  description = "Amazon Resource Name (ARN) of the file gateway."
  type        = string
  validation {
    condition     = can(regex("arn:aws:storagegateway:\\w+(?:-\\w+)+:[[:digit:]]{12}:gateway/([a-zA-Z0-9])+(.*)$", var.gateway_arn))
    error_message = "Error! Enter a valid gateway_arn."
  }
}

variable "location_arn" {
  description = "The Amazon Resource Name (ARN) of the Amazon FSx file system to associate with the FSx File Gateway."
  type        = string
  validation {
    condition     = can(regex("arn:aws:fsx:\\w+(?:-\\w+)+:[[:digit:]]{12}:file-system/([a-zA-Z0-9])+(.*)$", var.location_arn))
    error_message = "Error! Enter a valid location_arn."
  }
}

variable "username" {
  description = "The user name of the user credential that has permission to access the root share of the Amazon FSx file system. The user account must belong to the Amazon FSx delegated admin user group."
  type        = string
}

variable "password" {
  description = "The password of the user credential."
  type        = string
}

variable "audit_destination_arn" {
  description = "The Amazon Resource Name (ARN) of the storage used for the audit logs."
  type        = string

}

variable "cache_stale_timeout_in_seconds" {
  description = "Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 0 or 300 to 2592000 seconds (5 minutes to 30 days). Defaults to 0."
  type        = number
  default     = 0
  validation {
    condition     = (var.cache_stale_timeout_in_seconds == 0 || var.cache_stale_timeout_in_seconds >= 300 && var.cache_stale_timeout_in_seconds <= 2592000)
    error_message = "Error! The value for cache_stale_timeout_in_seconds must be either 0 or between 300 and 2592000."
  }
}

#Variables for tags
variable "tags" {
  description = "Key-value map of resources tags."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}