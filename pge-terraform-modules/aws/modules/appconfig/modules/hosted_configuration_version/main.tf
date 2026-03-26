/*
 * # AWS AppConfig module
 * Terraform module which creates SAF2.0 Lambda function in AWS
*/
#
#  Filename    : aws/modules/appconfig/modules/appconfig/main.tf
#  Date        : 29 January 2024
#  Author      : Eric Barnard @e6bo 
#  Description : AppConfig TF module that creates an AppConfig deployment
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

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_appconfig_hosted_configuration_version" "pge_hosted_config" {
  application_id           = var.application_id
  configuration_profile_id = var.configuration_profile_id
  description              = var.description
  content                  = var.content
  content_type             = var.content_type
}
