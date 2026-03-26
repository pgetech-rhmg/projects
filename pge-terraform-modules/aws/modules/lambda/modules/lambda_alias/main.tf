/*
 * # AWS Lambda alias
 * Terraform module which creates SAF2.0 Lambda alias in AWS
*/
#
#  Filename    : aws/modules/lambda/modules/lambda_alias/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda alias
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

resource "aws_lambda_alias" "lambda_alias" {

  name             = var.lambda_alias_name
  description      = var.lambda_alias_description
  function_name    = var.lambda_alias_function_name
  function_version = var.lambda_alias_function_version

  dynamic "routing_config" {
    for_each = var.routing_config_additional_version_weights != null ? [true] : []
    content {
      additional_version_weights = var.routing_config_additional_version_weights

    }
  }
}
