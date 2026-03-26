#api_gateway_request_validator
variable "rest_api_id" {
  description = "The ID of the associated REST API"
  type        = string
}

variable "request_validator_name" {
  description = "The name of the request validator."
  type        = string
}

variable "request_validator_validate_request_body" {
  description = "Boolean whether to validate request body. Defaults to false"
  type        = bool
  default     = false
}

variable "request_validator_validate_request_parameters" {
  description = "Boolean whether to validate request parameters. Defaults to false"
  type        = bool
  default     = false
}