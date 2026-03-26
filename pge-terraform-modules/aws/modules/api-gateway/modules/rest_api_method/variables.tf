# Variables for api_gateway_method
variable "rest_api_id" {
  description = "The ID of the associated REST API"
  type        = string
}

variable "resource_id" {
  description = "The API resource ID"
  type        = string
}

variable "method_request_validator_id" {
  description = "The ID of a aws_api_gateway_request_validator"
  type        = string
  default     = null
}

variable "method_http_method" {
  description = "The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.method_http_method == null,
      var.method_http_method == "GET",
      var.method_http_method == "POST",
      var.method_http_method == "PUT",
      var.method_http_method == "DELETE",
      var.method_http_method == "HEAD",
      var.method_http_method == "OPTIONS",
    var.method_http_method == "ANY"])
    error_message = "Valid values for Authorization are GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY."
  }
}

variable "authorization" {
  description = <<-DOC
    method_authorization:
       The type of authorization used for the method (NONE, CUSTOM, AWS_IAM).
    method_authorization_id:
      The authorizer id to be used when the authorization is CUSTOM
    api_key_required:
      "Specify if the method requires an API key"
    cors_enabled:
       "Specify if CORS is enabled"

  DOC
  type = object({
    method_authorization    = string
    method_authorization_id = string
    api_key_required        = bool
    cors_enabled            = bool
  })
  default = {
    method_authorization    = "NONE"
    method_authorization_id = null
    api_key_required        = true
    cors_enabled            = false
  }
  validation {
    condition = anytrue([
      var.authorization.method_authorization == "NONE",
      var.authorization.method_authorization == "AWS_IAM",
    var.authorization.method_authorization == "CUSTOM"])
    error_message = "Valid values for Authorization are NONE, CUSTOM. COGNITO_USER_POOLS is not supported in PG&E."
  }

  validation {
    condition = anytrue([var.authorization.api_key_required == true && var.authorization.method_authorization == "CUSTOM" ||
      var.authorization.api_key_required == false && var.authorization.method_authorization == "CUSTOM" ||
      var.authorization.api_key_required == false && var.authorization.method_authorization == "AWS_IAM" ||
      var.authorization.api_key_required == true && var.authorization.method_authorization == "NONE" ||
    var.authorization.cors_enabled == true && var.authorization.method_authorization == "NONE"])
    error_message = "Error! API-key or Method authorization is required or should be CORS enabled."
  }

}

variable "method_authorization_scopes" {
  description = "The authorization scopes used when the authorization is COGNITO_USER_POOLS."
  type        = list(string)
  default     = null
}

variable "method_operation_name" {
  description = "The function name that will be given to the method when generating an SDK through API Gateway."
  type        = string
  default     = null
}

variable "method_request_models" {
  description = "A map of the API models used for the request's content type where key is the content type (e.g. application/json) and value is either Error, Empty (built-in models) or aws_api_gateway_model's name."
  type        = map(string)
  default     = null
}

variable "method_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
  type        = map(string)
  default     = null
}

# variables for api_gateway_method_response
variable "method_response_status_code" {
  description = "The HTTP status code."
  type        = string
  default     = null
}

variable "method_response_models" {
  description = "A map of the API models used for the response's content type."
  type        = map(string)
  default     = null
}

variable "method_response_parameters" {
  description = "A map of response parameters that can be sent to the caller. For example: response_parameters = { \"method.response.header.X-Some-Header\" = true } would define that the header X-Some-Header can be provided on the response."
  type        = map(string)
  default     = null
}

# Variables for api_gateway_integration
variable "integration_http_method" {
  description = "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.integration_http_method == null,
      var.integration_http_method == "GET",
      var.integration_http_method == "POST",
      var.integration_http_method == "PUT",
      var.integration_http_method == "DELETE",
      var.integration_http_method == "HEAD",
      var.integration_http_method == "OPTIONS",
      var.integration_http_method == "ANY",
    var.integration_http_method == "PATCH"])
    error_message = "Valid values for Authorization are GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY, PATCH."
  }
}

variable "integration_type" {
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.integration_type == null,
      var.integration_type == "HTTP",
      var.integration_type == "MOCK",
      var.integration_type == "AWS",
      var.integration_type == "AWS_PROXY",
    var.integration_type == "HTTP_PROXY"])
    error_message = "Valid values for integration type are HTTP, MOCK, AWS, AWS_PROXY, HTTP_PROXY."
  }
}

variable "integration_connection_type" {
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.integration_connection_type == null,
      var.integration_connection_type == "INTERNET",
    var.integration_connection_type == "VPC_LINK"])
    error_message = "Valid values for connection types are INTERNET and VPC_LINK."
  }
}

variable "integration_connection_id" {
  description = "The id of the VpcLink used for the integration. Required if connection_type is VPC_LINK"
  type        = string
  default     = null
}
variable "integration_uri" {
  description = "The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations."
  type        = string
  default     = null
}

variable "integration_credentials" {
  description = "The credentials required for the integration. For AWS integrations, 2 options are available. To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::*:user/*."
  type        = string
  default     = null
}

variable "integration_request_templates" {
  description = "A map of the integration's request templates."
  type        = map(string)
  default     = null
}

variable "integration_request_parameters" {
  description = "A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { \"integration.request.header.X-Some-Other-Header\" = \"method.request.header.X-Some-Header\" }."
  type        = map(string)
  default     = null
}

variable "integration_passthrough_behavior" {
  description = "The integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.integration_passthrough_behavior == null,
      var.integration_passthrough_behavior == "WHEN_NO_MATCH",
      var.integration_passthrough_behavior == "WHEN_NO_MATCH",
    var.integration_passthrough_behavior == "NEVER"])
    error_message = "Valid values for passthrough_behavior are WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER."
  }
}

variable "integration_cache_key_parameters" {
  description = "A list of cache key parameters for the integration."
  type        = list(string)
  default     = null
}

variable "integration_cache_namespace" {
  description = "The integration's cache namespace."
  type        = string
  default     = null
}

variable "integration_content_handling" {
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.integration_content_handling == null,
      var.integration_content_handling == "CONVERT_TO_BINARY",
    var.integration_content_handling == "CONVERT_TO_TEXT"])
    error_message = "Valid values for content_handling are CONVERT_TO_BINARY, CONVERT_TO_TEXT."
  }
}

variable "integration_timeout_milliseconds" {
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
  type        = number
  default     = 29000
  validation {
    condition = (
      var.integration_timeout_milliseconds >= 50 &&
      var.integration_timeout_milliseconds <= 29000
    )
    error_message = "Set a value between 50 and 29000 milliseconds."
  }
}

variable "tls_config_insecure_skip_verification" {
  description = "Specifies whether or not API Gateway skips verification that the certificate for an integration endpoint is issued by a supported certificate authority. Not recommended."
  type        = string
  default     = null
}

# variables for api_gateway_integration_response
variable "api_gateway_integration_response_create" {
  description = "Whether to create API Gateway Integration Response."
  type        = bool
  default     = false
}

variable "integration_response_selection_pattern" {
  description = "Specifies the regular expression pattern used to choose an integration response based on the response from the backend."
  type        = string
  default     = null
}

variable "integration_response_templates" {
  description = "A map specifying the templates used to transform the integration response body."
  type        = map(string)
  default     = null
}

variable "integration_response_parameters" {
  description = "A map of response parameters that can be read from the backend response. For example: response_parameters = { \"method.response.header.X-Some-Header\" = \"integration.response.header.X-Some-Other-Header\" }."
  type        = map(string)
  default     = null
}

variable "integration_response_content_handling" {
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the response payload will be passed through from the integration response to the method response without modification."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.integration_response_content_handling == null,
      var.integration_response_content_handling == "CONVERT_TO_BINARY",
    var.integration_response_content_handling == "CONVERT_TO_TEXT"])
    error_message = "Valid values for content_handling are CONVERT_TO_BINARY, CONVERT_TO_TEXT."
  }
}
