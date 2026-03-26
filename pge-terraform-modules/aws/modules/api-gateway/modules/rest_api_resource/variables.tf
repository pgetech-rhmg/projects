# Variables for api_gateway_resource
variable "api_gateway_path_part" {
  description = "The last path segment of this API resource"
  type        = string
}

variable "api_gateway_rest_api_id" {
  description = "The ID of the associated REST API"
  type        = string
}

variable "api_gateway_parent_id" {
  description = "The ID of the parent API resource"
  type        = string
}