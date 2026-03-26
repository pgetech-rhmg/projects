#cloudfront origin access control variables
variable "cloudfront_oac_name" {
  description = "A name that identifies the Origin Access Control."
  type        = string

}

variable "cloudfront_oac_description" {
  description = "The description of the Origin Access Control."
  type        = string
  default     = "Managed by Terraform"
}

variable "cloudfront_oac_origin_type" {
  description = "The type of origin for this Origin Access Control. Valid values: lambda, mediapackagev2, mediastore, s3."
  type        = string
  default     = "s3"
}

variable "cloudfront_oac_signing_behavior" {
  description = "Specifies which requests CloudFront signs. Allowed values: always, never, no-override."
  type        = string
  default     = "always"
}

variable "cloudfront_oac_signing_protocol" {
  description = "Determines how CloudFront signs requests. The only valid value is sigv4."
  type        = string
  default     = "sigv4"
}

variable "function_association" {
  description = "A config block that triggers a cloudfront function with specific actions"
  type        = any
  default     = []
}