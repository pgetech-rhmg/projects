# aws_cloudfront_cache_policy
variable "cache_policy" {
  description = "A list of string to provide values for the resource cache policy"
  type        = any
  default     = []
}

# aws_cloudfront_response_headers_policy
variable "response_headers_policy" {
  description = "A list of string to provide values for the resource response headers policy"
  type        = any
  default     = []
}

#cloudfront_origin_request_policy
variable "origin_request_policy" {
  description = "A list of string to provide values for the resource request policy."
  type        = any
  default     = []
}
