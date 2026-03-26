/*
* # AWS API Gateway Resource
* Terraform module which creates SAF2.0 API Gateway Rest Api in AWS
*/

#  Filename    : aws/modules/api-gateway/modules/rest_api_resource/main.tf
#  Date        : 9 Febraury 2022
#  Author      : TCS
#  Description : api-gateway terraform module creates a api-gateway resource
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

resource "aws_api_gateway_resource" "api_gateway_resource" {

  rest_api_id = var.api_gateway_rest_api_id
  parent_id   = var.api_gateway_parent_id
  path_part   = var.api_gateway_path_part
}