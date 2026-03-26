#aws_cloudfront_public_key
variable "cf_public_key" {
  description = "A list of string to provide values for the resource public key."
  type        = any
  default     = []
}

#aws_cloudfront_key_group
variable "cf_key_group" {
  description = "A list of string to provide values for the resource key group."
  type        = any
  default     = []
}
