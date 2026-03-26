/*
* # AWS API Gateway Request Validator
* Terraform module which creates SAF2.0 API Gateway Rest Api in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api_request_validator/main.tf
#  Date        : 17 August 2022                                                              
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway request validator
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

resource "aws_api_gateway_request_validator" "api_gateway_request_validator" {

  rest_api_id                 = var.rest_api_id
  name                        = var.request_validator_name
  validate_request_body       = var.request_validator_validate_request_body
  validate_request_parameters = var.request_validator_validate_request_parameters
}