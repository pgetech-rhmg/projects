/*
 * # AWS AppConfig module
 * Terraform module which creates SAF2.0 AppConfig extension in AWS
*/
#
#  Filename    : aws/modules/appconfig/modules/extension/main.tf
#  Date        : 29 January 2024
#  Author      : Eric Barnard @e6bo 
#  Description : AppConfig TF module that creates an AppConfig extension
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

resource "aws_appconfig_extension" "pge_extension" {
  name        = var.name
  description = var.description
  tags        = null

  parameter {
    name        = var.parameter_name
    description = var.parameter_description
    required    = var.parameter_required
  }

  action_point {
    point = var.action_point
    action {
      name        = var.action_name
      role_arn    = var.action_role
      uri         = var.action_uri
      description = var.action_description
    }
  }
}

resource "aws_appconfig_extension_association" "extension_association" {
  count         = var.enable_extension_association ? 1 : 0
  extension_arn = aws_appconfig_extension.pge_extension.arn
  resource_arn  = var.resource_arn_to_associate_with_extension
}