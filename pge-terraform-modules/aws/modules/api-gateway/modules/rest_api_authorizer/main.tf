/*
* # AWS API Gateway Authorizer
* Terraform module which creates SAF2.0 API Gateway Rest Api in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api_authorizer/main.tf
#  Date        : 17 August 2022                                                              
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway authorizer
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

resource "aws_api_gateway_authorizer" "api_gateway_authorizer" {

  rest_api_id                      = var.rest_api_id
  name                             = var.authorizer_name
  authorizer_uri                   = var.authorizer_uri
  identity_source                  = var.authorizer_identity_source
  type                             = var.authorizer_type
  authorizer_credentials           = var.authorizer_credentials
  authorizer_result_ttl_in_seconds = var.authorizer_result_ttl_in_seconds
  identity_validation_expression   = var.authorizer_identity_validation_expression
  provider_arns                    = var.authorizer_provider_arns
}