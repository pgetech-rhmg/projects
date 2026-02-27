# Required variables (injected by EPIC)
variable "app_name" {
  description = "Application name used for naming CloudFront resources."
  type        = string
}

variable "bucket_name" {
  description = "Target S3 bucket name for static website assets"
  type        = string
}


# Optional variables (defaulted)
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
