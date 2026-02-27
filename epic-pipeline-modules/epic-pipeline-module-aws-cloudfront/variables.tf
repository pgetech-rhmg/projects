variable "app_name" {
  description = "Application name used for naming CloudFront resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, qa, prod)."
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket backing CloudFront."
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket backing CloudFront."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket (not the website endpoint)."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
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

variable "cors_allowed_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = [ "*" ]
}