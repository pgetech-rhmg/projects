/*
* # AWS API Gateway Method
* Terraform module which creates SAF2.0 API Gateway Rest Api in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api_method/main.tf
#  Date        : 9 Febraury 2022
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway method
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_api_gateway_method" "api_gateway_method" {

  rest_api_id          = var.rest_api_id
  resource_id          = var.resource_id
  http_method          = var.authorization.cors_enabled == true ? "OPTIONS" : var.method_http_method
  authorization        = var.authorization.cors_enabled == true ? "NONE" : var.authorization.method_authorization
  authorizer_id        = var.authorization.method_authorization_id
  authorization_scopes = var.method_authorization_scopes
  api_key_required     = var.authorization.api_key_required
  operation_name       = var.method_operation_name
  request_models       = var.method_request_models
  request_validator_id = var.method_request_validator_id
  request_parameters   = var.method_request_parameters
}

resource "aws_api_gateway_method_response" "api_gateway_method_response" {

  count = var.method_response_status_code != null ? 1 : 0

  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.api_gateway_method.http_method
  status_code         = var.method_response_status_code
  response_models     = var.method_response_models
  response_parameters = var.method_response_parameters

  depends_on = [aws_api_gateway_method.api_gateway_method]
}

resource "aws_api_gateway_integration" "api_gateway_integration" {

  count = var.integration_type != null ? 1 : 0

  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.api_gateway_method.http_method
  integration_http_method = var.authorization.cors_enabled == true ? null : var.integration_http_method
  type                    = var.authorization.cors_enabled == true ? "MOCK" : var.integration_type
  connection_type         = var.integration_connection_type
  connection_id           = var.integration_connection_id
  uri                     = var.integration_uri
  credentials             = var.integration_credentials
  request_templates       = var.integration_request_templates
  request_parameters      = var.integration_request_parameters
  passthrough_behavior    = var.integration_passthrough_behavior
  cache_key_parameters    = var.integration_cache_key_parameters
  cache_namespace         = var.integration_cache_namespace
  content_handling        = var.integration_content_handling
  timeout_milliseconds    = var.integration_timeout_milliseconds

  tls_config {
    insecure_skip_verification = var.tls_config_insecure_skip_verification
  }
  depends_on = [aws_api_gateway_method.api_gateway_method]
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response" {

  count = var.api_gateway_integration_response_create ? 1 : 0

  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = aws_api_gateway_method.api_gateway_method.http_method
  status_code         = aws_api_gateway_method_response.api_gateway_method_response[0].status_code
  selection_pattern   = var.integration_response_selection_pattern
  response_templates  = var.integration_response_templates
  response_parameters = var.integration_response_parameters
  content_handling    = var.integration_response_content_handling

  depends_on = [
    aws_api_gateway_method_response.api_gateway_method_response,
    aws_api_gateway_integration.api_gateway_integration,
  ]
}