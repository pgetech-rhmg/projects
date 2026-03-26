variable "cf_function_name" {
  description = "Unique name for your CloudFront Function"
  type        = string
}

variable "cf_function_code" {
  description = "Source code of the function"
  type        = string
}

variable "cf_function_comment" {
  description = "Comment for cloudfront function"
  type        = string
  default     = null
}

variable "cf_function_publish" {
  description = "Whether to publish creation/change as Live CloudFront Function Version."
  type        = bool
  default     = true
}