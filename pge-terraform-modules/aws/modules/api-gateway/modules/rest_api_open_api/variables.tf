#Variables for api_gateway_rest_api
variable "rest_api_name" {
  description = "The Name of the REST API"
  type        = string
}

variable "openapi_config" {
  description = "The OpenAPI specification that defines the set of routes and integrations to create as part of the REST API"
  type        = any
  validation {
    condition     = can(jsondecode(var.openapi_config))
    error_message = "Error! Invalid JSON for body. Provide a valid JSON."
  }
}

variable "rest_api_parameters" {
  description = "The Map of customizations for importing the specification in the body argument"
  type        = map(string)
  default     = null
}

variable "endpoint_configuration_types" {
  description = "A list of endpoint types"
  type        = string
  default     = "PRIVATE"
  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_configuration_types)
    error_message = "Valid values for api_key_source are EDGE, REGIONAL and PRIVATE."
  }
}

variable "endpoint_configuration_vpc_endpoint_ids" {
  description = "Set of VPC Endpoint identifiers"
  type        = list(string)
  default     = null
}

variable "policy" {
  description = "The JSON formatted policy document that controls access to the API Gateway"
  type        = string
  default     = "{}"
  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "Error! Invalid JSON for policy. Provide a valid JSON."
  }
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
