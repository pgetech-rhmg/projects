# Variables for nfs_file_share
variable "client_list" {
  description = "The list of clients that are allowed to access the file gateway. The list must contain either valid IP addresses or valid CIDR blocks. Set to ['0.0.0.0/0'] to not limit access. Minimum 1 item. Maximum 100 items."
  type        = list(any)
  validation {
    condition     = length(var.client_list) > 0 && length(var.client_list) <= 100
    error_message = "Error! client_list ranges is minimum of 1 and maximum of 100."
  }
}

variable "gateway_arn" {
  description = "Amazon Resource Name (ARN) of the file gateway."
  type        = string
}

variable "location_arn" {
  description = "The ARN of the backed storage used for storing file data."
  type        = string
}

variable "vpc_endpoint_bucket" {
  description = "Object varaibles to check The region of the S3 bucket used by the file share. Required when specifying vpc_endpoint_dns_name."
  type = object({
    vpc_endpoint_dns_name = string
    bucket_region         = string
  })
  default = {
    bucket_region         = ""
    vpc_endpoint_dns_name = ""
  }
  validation {
    condition     = var.vpc_endpoint_bucket.vpc_endpoint_dns_name != null || var.vpc_endpoint_bucket.vpc_endpoint_dns_name == null ? var.vpc_endpoint_bucket.bucket_region != null || var.vpc_endpoint_bucket.bucket_region == null : false
    error_message = "Error! bucket_region is required when specifying vpc_endpoint_dns_name."
  }
}

variable "role_arn" {
  description = "The ARN of the AWS Identity and Access Management (IAM) role that a file gateway assumes when it accesses the underlying storage."
  type        = string
  validation {
    condition = anytrue([
      can(regex("^arn:aws:iam::[[:digit:]]{12}:role/([a-zA-Z0-9])+(.*)$", var.role_arn))
    ])
    error_message = "Role_arn is required and the allowed format of 'role_arn' is arn:aws:iam::<account-id>:role/<aws-service-role-name>."
  }
}

variable "audit_destination_arn" {
  description = "The Amazon Resource Name (ARN) of the storage used for audit logs."
  type        = string
  validation {
    condition     = can(regex("arn:aws:logs:[a-z][a-z]-[a-z]+-[1-9]+:[0-9]{12}:log-group:*", var.audit_destination_arn))
    error_message = "Error! Enter a valid audit_destination_arn and log group name should begin with /aws/vendedlogs/."
  }
}

variable "default_storage_class" {
  description = "he default storage class for objects put into an Amazon S3 bucket by the file gateway. Defaults to S3_STANDARD."
  type        = string
  default     = "S3_STANDARD"
  validation {
    condition     = contains(["S3_STANDARD", "S3_INTELLIGENT_TIERING", "S3_STANDARD_IA", "S3_ONEZONE_IA"], var.default_storage_class)
    error_message = "Error! valid values for default_storage_class are S3_STANDARD, S3_INTELLIGENT_TIERING, S3_STANDARD_IA and S3_ONEZONE_IA."
  }
}

variable "guess_mime_type_enabled" {
  description = "Boolean value that enables guessing of the MIME type for uploaded objects based on file extensions. Defaults to true."
  type        = bool
  default     = true
}

variable "kms_encrypted" {
  description = "True to use AWS S3 server side encryption with PGE managed KMS key. False to use KMS key managed by AWS. Defaults to false."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Amazon Resource Name (ARN) for KMS key used for Amazon S3 server side encryption. This value can only be set when kms_encrypted is true."
  type        = string
}

variable "read_only" {
  description = " Boolean to indicate write status of file share. File share does not accept writes if true. Defaults to false."
  type        = bool
  default     = false
}

variable "requester_pays" {
  description = "Boolean who pays the cost of the request and the data download from the Amazon S3 bucket. Set this value to true if you want the requester to pay instead of the bucket owner. Defaults to false."
  type        = bool
  default     = false
}

variable "squash" {
  description = "Maps a user to anonymous user. Defaults to RootSquash. Valid values: RootSquash (only root is mapped to anonymous user), NoSquash (no one is mapped to anonymous user), AllSquash (everyone is mapped to anonymous user)"
  type        = string
  default     = "RootSquash"
  validation {
    condition     = contains(["RootSquash", "NoSquash", "AllSquash"], var.squash)
    error_message = "Error! valid values for squash are RootSquash, NoSquash and AllSquash."
  }
}

variable "file_share_name" {
  description = "The name of the file share. Must be set if an S3 prefix name is set in location_arn."
  type        = string
  default     = null
}

variable "notification_policy" {
  description = "The notification policy of the file share."
  type        = string
  default     = null
}

variable "nfs_file_share_defaults" {
  description = <<-_EOT
    {
    nfs_file_share_defaults : "Nested argument with file share default values."
    directory_mode : (Optional) The Unix directory mode in the string form "nnnn". Defaults to "0777".
    file_mode      : (Optional) The Unix file mode in the string form "nnnn". Defaults to "0666".
    group_id       : (Optional) The default group ID for the file share (unless the files have another group ID specified). Defaults to 65534 (nfsnobody). Valid values: 0 through 4294967294.
    owner_id       : (Optional) The default owner ID for the file share (unless the files have another owner ID specified). Defaults to 65534 (nfsnobody). Valid values: 0 through 4294967294.
    }
    _EOT

  type = object({
    directory_mode = optional(string)
    file_mode      = optional(string)
    group_id       = optional(number)
    owner_id       = optional(number)
  })

  default = ({
    directory_mode = null
    file_mode      = null
    group_id       = null
    owner_id       = null
  })

  validation {
    condition     = var.nfs_file_share_defaults.group_id != null ? var.nfs_file_share_defaults.group_id >= 0 && var.nfs_file_share_defaults.group_id <= 4294967294 : true
    error_message = "Error! group_id accpets only values between 0 to 4294967294 seconds.!"
  }
  validation {
    condition     = var.nfs_file_share_defaults.owner_id != null ? var.nfs_file_share_defaults.owner_id >= 0 && var.nfs_file_share_defaults.owner_id <= 4294967294 : true
    error_message = "Error! owner_id accpets only values between 0 to 4294967294 seconds.!"
  }
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

# variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}