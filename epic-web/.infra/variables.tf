###############################################################################
# Organization & Account
###############################################################################

variable "principal_orgid" {
  description = "Organization ID."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account used for this resource."
  type        = string
}

variable "aws_region" {
  description = "Deployment region."
  type        = string
}


###############################################################################
# Application
###############################################################################

variable "app_name" {
  description = "Application name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}


###############################################################################
# Tagging & Compliance
###############################################################################

variable "appid" {
  description = "AMPS application ID. Format = APP-####"
  type        = number
}

variable "notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."

  validation {
    condition = alltrue([
      for alias in var.notify : can(regex("^\\w+([\\.!-/:[-`{-~]?\\w+)*@([\\.-]?\\w+)*(\\.\\w{2,3})+$", alias))
    ])
    error_message = "Invalid email address in notify tag."
  }
}

variable "owner" {
  type        = list(string)
  description = "List of three owners (AMPS Director, Client Owner, IT Lead) as LANID values."

  validation {
    condition     = length(var.owner) == 3
    error_message = "Exactly three owners must be provided."
  }
}

variable "order" {
  type        = number
  description = "Order number tag associated with this AWS resource."

  validation {
    condition     = var.order >= 1000000 && var.order <= 999999999
    error_message = "Order must be between 7 and 9 digits."
  }
}

variable "dataclassification" {
  type        = string
  description = "Data classification level for this resource."
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Privileged", "Confidential-BCSI", "Restricted-BCSI"], var.dataclassification)
    error_message = "Valid values: Public, Internal, Confidential, Restricted, Privileged, Confidential-BCSI, Restricted-BCSI."
  }
}

variable "compliance" {
  type        = list(string)
  description = "Compliance requirements for this resource (SOX, HIPAA, CCPA, BCSI, or None)."
  default     = ["None"]

  validation {
    condition = alltrue([
      for alias in var.compliance : contains(["SOX", "HIPAA", "CCPA", "BCSI", "None"], alias)
    ])
    error_message = "Valid values: SOX, HIPAA, CCPA, BCSI, None."
  }
}

variable "cris" {
  type        = string
  description = "Cyber Risk Impact Score (High, Medium, or Low)."
  default     = "Low"

  validation {
    condition     = contains(["High", "Medium", "Low"], var.cris)
    error_message = "Valid values: High, Medium, Low."
  }
}


###############################################################################
# Networking
###############################################################################

variable "domain_name" {
  description = "Domain name for the ACM certificate and Route53 record."
  type        = string
}

variable "private_hosted_zone_id" {
  description = "Route53 private hosted zone ID."
  type        = string
}

variable "public_hosted_zone_id" {
  description = "Route53 public hosted zone ID (used by ACM DNS validation only)."
  type        = string
}


###############################################################################
# WAF
###############################################################################

variable "allowed_cidrs" {
  description = <<EOT
Source IP CIDRs allowed to reach the CloudFront distribution. Must be PG&E's
PUBLIC egress IP ranges — CloudFront sees the corporate NAT egress IP, not
the user's RFC1918 internal address. Anything not in this list is blocked
by the WAF at the edge with a 403.
EOT
  type        = list(string)
  default = [
    "131.89.0.0/16",   # PG&E corporate egress
    "131.90.0.0/16",   # PG&E corporate egress
    "192.80.218.0/24", # Opsera tunnel
  ]
}


###############################################################################
# S3
###############################################################################

variable "custom_bucket_name" {
  description = "Globally-unique S3 custom bucket name."
  type        = string
  default     = null
  nullable    = true
}

variable "force_s3_destroy" {
  description = "If true, allows Terraform to delete the bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "S3 object ownership setting."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "Valid values: BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter."
  }
}

variable "enable_public_access_block" {
  description = "If true, blocks all public access at the bucket level (recommended)."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "Valid values: AES256, aws:kms."
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
  description = "Prefix for access logs."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the S3 bucket."
  type        = any
  default     = []
}

variable "bucket_policy_json" {
  description = "Optional raw JSON bucket policy to attach."
  type        = string
  default     = null
  nullable    = true
}


###############################################################################
# CloudFront
###############################################################################

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_100", "PriceClass_200"], var.price_class)
    error_message = "Valid values: PriceClass_All, PriceClass_100, PriceClass_200."
  }
}

variable "custom_domain_aliases" {
  description = "Optional list of custom domain aliases for CloudFront."
  type        = list(string)
  default     = []
}

variable "cors_allowed_origins" {
  description = "List of allowed CORS origins for the CloudFront response headers policy."
  type        = list(string)
  default     = ["https://epic-dev.nonprod.pge.com"]
}
