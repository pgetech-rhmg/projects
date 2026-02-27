# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming CloudFront resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}


# Optional variables (defaulted)
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
  nullable    = true
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
  nullable    = true
}

variable "access_log_prefix" {
  description = "Prefix for access logs (optional)."
  type        = string
  default     = null
  nullable    = true
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

variable "upload_object" {
  description = "Optional file upload to this bucket"
  type = object({
    key    = string
    source = string
  })
  default     = null
  nullable    = true
}
