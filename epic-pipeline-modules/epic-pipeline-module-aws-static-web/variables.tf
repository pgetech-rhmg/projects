# Required variables (injected by EPIC)
variable "principal_orgid" {
  description = "Organiztion id."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account used for this resource."
  type        = string
}

variable "app_name" {
  description = "Application name used for naming CloudFront resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}


# Required
variable "appid" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."

  validation {
    condition = alltrue([
      for aliases in var.notify : can(regex("^\\w+([\\.!-/:[-`{-~]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", aliases))
    ])
    error_message = "Invalid Email Address for Notify tag."
  }
}

variable "owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  
  validation {
    condition     = length(var.owner) == 3
    error_message = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg."
  }
}

variable "order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"
  
  validation {
    condition     = var.order >= 1000000 && var.order <= 999999999
    error_message = "Order must be a number between 7 and 9 digits"
  }
}


# Optional variables (defaulted)
variable "dataclassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI (only one)"
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Privileged", "Confidential-BCSI", "Restricted-BCSI"], var.dataclassification)
    error_message = "Valid values for DataClassification are (Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI). Please select on these as DataClassification parameter."
  }
}

variable "compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, CCPA, BCSI or None) Note: BCSI Workloads require specific considerations"
  default     = ["None"]

  validation {
    condition = alltrue([
      for alias in var.compliance : contains(["SOX", "HIPAA", "CCPA", "BCSI", "None"], alias)
    ])
    error_message = "Valid values for DataClassification are SOX, HIPAA, CCPA, BCSI or None. Please select on these as Compliance parameter."
  }
}

variable "cris" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  default     = "Low"
  
  validation {
    condition     = contains(["High", "Medium", "Low"], var.cris)
    error_message = "Valid values for Cyber Risk Impact Score are High, Medium, Low (only one). Please select one these CRIS values."
  }
}

variable "custom_bucket_name" {
  description = "Globally-unique S3 custom bucket name."
  type        = string
  default     = null
  nullable    = true
}

variable "force_destroy" {
  description = "If true, allows Terraform to delete the bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "S3 object ownership setting. Recommended: BucketOwnerEnforced."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be one of: BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter."
  }
}

variable "enable_public_access_block" {
  description = "If true, blocks all public access settings at the bucket level (recommended)."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm. Use AES256 (SSE-S3) or aws:kms (SSE-KMS)."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_arn" {
  description = "KMS Key ARN for SSE-KMS. Required when sse_algorithm is aws:kms."
  type        = string
  default     = null
}

variable "enable_access_logging" {
  description = "Enable S3 server access logging."
  type        = bool
  default     = false
}

variable "access_log_bucket" {
  description = "Target bucket name for access logs (required if enable_access_logging is true)."
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access logs (optional)."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = <<EOT
Lifecycle rules for the bucket.

Each rule object supports:
- id (string, required)
- enabled (bool, required)
- prefix (string, optional) [deprecated by AWS, but still accepted]
- filter (object, optional) - passed through to aws_s3_bucket_lifecycle_configuration
- transitions (list(object), optional): [{ days = number, storage_class = string }]
- expiration (object, optional): { days = number }
- noncurrent_version_expiration (object, optional): { noncurrent_days = number }
EOT

  type    = any
  default = []
}

variable "bucket_policy_json" {
  description = "Optional raw JSON bucket policy to attach."
  type        = string
  default     = null
  nullable    = true
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_100", "PriceClass_200"], var.price_class)
    error_message = "Valid values for type are PriceClass_All, PriceClass_100, PriceClass_200."
  }
}

variable "custom_domain_aliases" {
  description = "Optional list of custom domain aliases for CloudFront."
  type        = list(string)
  default     = []
}

variable "custom_acm_certificate_arn" {
  description = "Optional ACM certificate ARN (must be in us-east-1)."
  type        = string
  default     = null
  nullable    = true
}

variable "app_path" {
  description = "Relative path under the app folder containing static site files"
  type        = string
  default     = "/"
}

variable "cache_control" {
  description = "Optional Cache-Control header for uploaded objects"
  type        = string
  default     = null
  nullable    = true
}

variable "content_type_overrides" {
  description = "Optional override map for file extensions to MIME types"
  type        = map(string)
  default     = {}
}
