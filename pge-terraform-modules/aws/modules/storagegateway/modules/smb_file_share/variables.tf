variable "gateway_arn" {
  description = "Amazon Resource Name (ARN) of the file gateway."
  type        = string
  validation {
    condition     = can(regex("arn:aws:storagegateway:\\w+(?:-\\w+)+:[[:digit:]]{12}:gateway/([a-zA-Z0-9])+(.*)$", var.gateway_arn))
    error_message = "Error! Enter a valid gateway_arn."
  }
}

variable "location_arn" {
  description = "The ARN of the backed storage used for storing file data."
  type        = string
  validation {
    condition     = can(regex("arn:aws:s3:::([a-zA-Z0-9])+(.*)$", var.location_arn))
    error_message = "Error! Enter a valid location_arn."
  }
}

variable "vpc_endpoint_bucket" {
  description = <<-DOC
   vpc_endpoint_dns_name
       The DNS name of the VPC endpoint for S3 private link.
    bucket_region
       The region of the S3 bucket used by the file share. Required when specifying a vpc_endpoint_dns_name.
  DOC

  type = object({
    vpc_endpoint_dns_name = string
    bucket_region         = string
  })

  default = {
    bucket_region         = null
    vpc_endpoint_dns_name = null
  }
  validation {
    condition     = (var.vpc_endpoint_bucket.bucket_region == null ? true : can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.vpc_endpoint_bucket.bucket_region)))
    error_message = "Error! enter a valid bucket_region."
  }
}

variable "role_arn" {
  description = " The ARN of the AWS Identity and Access Management (IAM) role that a file gateway assumes when it accesses the underlying storage."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.role_arn))
    error_message = "Error! Role_arn is required and the allowed format of 'role_arn' is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "admin_user_list" {
  description = "A list of users in the Active Directory that have admin access to the file share."
  type        = list(string)
  default     = null
}

variable "audit_destination_arn" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch Log Group used for the audit logs."
  type        = string
  validation {
    condition     = can(regex("arn:aws:logs:\\w+(?:-\\w+)+:[[:digit:]]{12}:log-group:/([a-zA-Z0-9])+(.*)$", var.audit_destination_arn))
    error_message = "Error! Enter a valid audit_destination_arn."
  }
}

variable "default_storage_class" {
  description = "The default storage class for objects put into an Amazon S3 bucket by the file gateway. Defaults to S3_STANDARD."
  type        = string
  default     = "S3_STANDARD"
  validation {
    condition     = contains(["S3_STANDARD", "S3_INTELLIGENT_TIERING", "S3_STANDARD_IA", "S3_ONEZONE_IA"], var.default_storage_class)
    error_message = "Error! valid values for default_storage_class are S3_STANDARD, S3_INTELLIGENT_TIERING, S3_STANDARD_IA and S3_ONEZONE_IA."
  }
}

variable "file_share_name" {
  description = "The name of the file share. Must be set if an S3 prefix name is set in location_arn."
  type        = string
  default     = null
}

variable "guess_mime_type_enabled" {
  description = "Boolean value that enables guessing of the MIME type for uploaded objects based on file extensions."
  type        = bool
  default     = true
}

variable "invalid_user_list" {
  description = "A list of users in the Active Directory that are not allowed to access the file share."
  type        = list(string)
  default     = null
}

variable "kms_encrypted" {
  description = "True to use AWS S3 server side encryption with PGE managed KMS key. False to use KMS key managed by AWS. Defaults to false."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Amazon Resource Name (ARN) for KMS key used for Amazon S3 server side encryption."
  type        = string
  validation {
    condition     = var.kms_key_arn == null ? true : can(regex("arn:aws:kms:\\w+(?:-\\w+)+:[[:digit:]]{12}:key/([a-zA-Z0-9])+(.*)$", var.kms_key_arn))
    error_message = "Error! Enter a valid kms_key_arn."
  }
}

variable "object_acl" {
  description = "Access Control List permission for S3 objects."
  type        = string
  default     = "private"
}

variable "oplocks_enabled" {
  description = "Boolean to indicate Opportunistic lock (oplock) status."
  type        = bool
  default     = true
}

variable "read_only" {
  description = "Boolean to indicate write status of file share. File share does not accept writes if true."
  type        = bool
  default     = false
}

variable "requester_pays" {
  description = "Boolean who pays the cost of the request and the data download from the Amazon S3 bucket. Set this value to true if you want the requester to pay instead of the bucket owner."
  type        = bool
  default     = false
}

variable "case_sensitivity" {
  description = "The case of an object name in an Amazon S3 bucket. For ClientSpecified, the client determines the case sensitivity. For CaseSensitive, the gateway determines the case sensitivity."
  type        = string
  default     = "ClientSpecified"
}

variable "valid_user_list" {
  description = " A list of users in the Active Directory that are allowed to access the file share. If you need to specify an Active directory group, add '@' before the name of the group. It will be set on Allowed group in AWS console."
  type        = list(string)
  default     = null
}

variable "access_based_enumeration" {
  description = "The files and folders on this share will only be visible to users with read access."
  type        = bool
  default     = false
}

variable "notification_policy" {
  description = "The notification policy of the file share."
  type        = string
  default     = "{}"
}

variable "cache_stale_timeout_in_seconds" {
  description = "Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 300 to 2,592,000 seconds (5 minutes to 30 days)."
  type        = number
  default     = null
  validation {
    condition     = (var.cache_stale_timeout_in_seconds == null ? true : (var.cache_stale_timeout_in_seconds >= 300 && var.cache_stale_timeout_in_seconds <= 2592000))
    error_message = "Error! The value for cache_stale_timeout_in_seconds must be between 300 and 2592000."
  }
}

variable "timeouts" {
  description = <<-DOC
  {
    create : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"
    update : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"
    delete : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 15m"
  }
  DOC
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {
    create = "10m"
    delete = "10m"
    update = "15m"
  }

  validation {
    condition     = var.timeouts.create != null ? can(regex("^[[:digit:]]+m$", var.timeouts.create)) : true
    error_message = "Error! enter valid inputs for timeouts. The input value for create should end with m. (eg : 20m)."
  }

  validation {
    condition     = var.timeouts.update != null ? can(regex("^[[:digit:]]+m$", var.timeouts.update)) : true
    error_message = "Error! enter valid inputs for timeouts. The input value for update should end with m. (eg : 20m)."
  }

  validation {
    condition     = var.timeouts.delete != null ? can(regex("^[[:digit:]]+m$", var.timeouts.delete)) : true
    error_message = "Error! enter valid inputs for timeouts. The input value for delete should end with m. (eg : 20m)."
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