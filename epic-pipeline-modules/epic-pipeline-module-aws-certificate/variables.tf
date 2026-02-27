variable "domain_name" {
  description = "The domain name for the ACM certificate."
  type        = string
}

variable "public_hosted_zone_id" {
  description = "The Route53 hosted zone ID used for DNS validation records."
  type        = string
}

variable "certificate_type" {
  description = "Type of certificate. Use 'public' to issue via us-east-1 (e.g. for CloudFront). Defaults to the caller's default AWS provider region."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "public"], var.certificate_type)
    error_message = "certificate_type must be either 'default' or 'public'."
  }
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
