#Variables for api_gateway_rest_api
variable "rest_api_name" {
  description = "The Name of the REST API"
  type        = string
}

variable "rest_api_description" {
  description = "The Description of the REST API"
  type        = string
  default     = null
}

variable "rest_api_binary_media_types" {
  description = "The list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads."
  type        = list(any)
  default     = null
}

variable "rest_api_minimum_compression_size" {
  description = "The Minimum response size to compress for the REST API"
  type        = number
  default     = -1
  validation {
    condition = (
      var.rest_api_minimum_compression_size >= -1 &&
      var.rest_api_minimum_compression_size <= 10485760
    )
    error_message = "Set a value between -1 and 10485760 (10MB)."
  }
}

variable "rest_api_api_key_source" {
  description = "The Source of the API key for requests"
  type        = string
  default     = "HEADER"
  validation {
    condition     = contains(["HEADER", "AUTHORIZER"], var.rest_api_api_key_source)
    error_message = "Valid values for api_key_source are HEADER and AUTHORIZER."
  }
}

variable "rest_api_disable_execute_api_endpoint" {
  type        = string
  description = "Specifies whether clients can invoke your API by using the default execute-api endpoint"
  default     = false
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

variable "endpoint_configuration_types" {
  description = "A list of endpoint types"
  type        = string
  default     = "PRIVATE"
  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_configuration_types)
    error_message = "Valid values for endpoint_configuration_types are EDGE, REGIONAL and PRIVATE."
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

# variables for api_gateway_model
variable "model_name" {
  description = "The name of the model."
  type        = string
  default     = null
}

variable "model_description" {
  description = "The description of the model."
  type        = string
  default     = null
}

variable "model_content_type" {
  description = "The content type of the model."
  type        = string
  default     = null
}

variable "model_schema" {
  description = "The schema of the model in a JSON form."
  type        = string
  default     = null
}

#api_gateway_gateway_response
variable "gateway_response_type" {
  description = "The response type of the associated GatewayResponse."
  type        = string
  default     = null
}

variable "gateway_status_code" {
  description = "The HTTP status code of the Gateway Response."
  type        = string
  default     = null
}

variable "gateway_response_templates" {
  description = "A map specifying the parameters (paths, query strings and headers) of the Gateway Response."
  type        = map(string)
  default     = null
}

variable "gateway_response_parameters" {
  description = "A map specifying the templates used to transform the response body."
  type        = map(string)
  default     = null
}

#variables for api_gateway_client_certificate
variable "api_gateway_client_certificate_create" {
  description = "Whether to create API Gateway Client Certificate."
  type        = bool
  default     = false
}

variable "client_certificate_description" {
  description = "The description of the client certificate."
  type        = string
  default     = null
}

#variables for api_gateway_vpc_link
variable "vpc_link_name" {
  description = "The name used to label and identify the VPC link."
  type        = string
  default     = null
}

variable "vpc_link_description" {
  description = "The description of the VPC link."
  type        = string
  default     = null
}

variable "vpc_link_target_arns" {
  description = "The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target."
  type        = list(string)
  default     = null
}

#variables aws_api_gateway_documentation_part
variable "documentation_part_properties" {
  description = "A content map of API specific keyvalue pairs describing the targeted API entity. The map must be encoded as a JSON string. Only Swaggercompliant keyvalue pairs can be exported and, hence, published."
  type        = string
  default     = null
}

variable "location_method" {
  description = " The HTTP verb of a method. The default value is * for any method."
  type        = string
  default     = null
}

variable "location_name" {
  description = " The name of the targeted API entity."
  type        = string
  default     = null
}

variable "location_path" {
  description = " The URL path of the target. The default value is / for the root resource."
  type        = string
  default     = null
}

variable "location_status_code" {
  description = " The HTTP status code of a response. The default value is * for any status code."
  type        = string
  default     = null
}

variable "location_type" {
  description = " The type of API entity to which the documentation content appliesE.g., API, METHOD or REQUEST_BODY"
  type        = string
  default     = null
}

#aws_api_gateway_documentation_version
variable "documentation_version" {
  description = " The version identifier of the API documentation snapshot."
  type        = string
  default     = null
}

variable "documentation_description" {
  description = " The description of the API documentation version."
  type        = string
  default     = null
}

# variables for api_gateway_account
variable "api_gateway_account_create" {
  description = "Whether to create API Gateway gateway response."
  type        = bool
  default     = false
}

variable "account_cloudwatch_role_arn" {
  description = "The ARN of an IAM role for CloudWatch (to allow logging & monitoring)."
  type        = string
  default     = null
}
