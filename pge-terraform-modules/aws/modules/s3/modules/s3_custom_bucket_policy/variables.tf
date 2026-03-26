variable "bucket_name" {
  description = "S3 bucket name. A unique identifier."
  default     = null
  type        = string
}

variable "policy" {
  description = "The user-defined policy to be combined with the compliance policy."
  type        = any
  default     = {}
}
variable "bucket_id" {
  description = "The ID of the S3 bucket to which the policy will be applied."
  type        = string
  default     = null
}