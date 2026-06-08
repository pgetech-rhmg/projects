variable "api_name" {
  description = "REST API name."
  type        = string
}

variable "description" {
  description = "REST API description."
  type        = string
  default     = ""
}

variable "endpoint_type" {
  description = "Endpoint type (REGIONAL, EDGE, or PRIVATE)."
  type        = string
  default     = "PRIVATE"

  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "Valid values: REGIONAL, EDGE, PRIVATE."
  }
}

variable "vpc_endpoint_ids" {
  description = "VPC endpoint IDs for PRIVATE endpoint type."
  type        = list(string)
  default     = []
}

variable "stage_name" {
  description = "Deployment stage name."
  type        = string
}

variable "enable_authorizer" {
  description = "Whether to create the Lambda authorizer resources. Use this instead of relying on ARN nullability to avoid unknown-value issues with count."
  type        = bool
  default     = false
}

variable "authorizer_function_arn" {
  description = "Lambda authorizer function ARN."
  type        = string
  default     = null
}

variable "authorizer_function_invoke_arn" {
  description = "Lambda authorizer invoke ARN."
  type        = string
  default     = null
}

variable "authorizer_identity_source" {
  description = "Authorizer identity source header."
  type        = string
  default     = "method.request.header.Authorization"
}

variable "authorizer_result_ttl" {
  description = "Authorizer result cache TTL in seconds."
  type        = number
  default     = 300
}

variable "cors_allow_origins" {
  description = "CORS allowed origins."
  type        = string
  default     = "'*'"
}

variable "cors_allow_methods" {
  description = "CORS allowed methods."
  type        = string
  default     = "'GET,POST,PUT,PATCH,DELETE,OPTIONS'"
}

variable "cors_allow_headers" {
  description = "CORS allowed headers."
  type        = string
  default     = "'Content-Type,Authorization'"
}

variable "gateway_responses" {
  description = "Map of gateway response types to configure with CORS headers."
  type        = list(string)
  default     = ["UNAUTHORIZED", "ACCESS_DENIED", "DEFAULT_5XX", "DEFAULT_4XX"]
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
