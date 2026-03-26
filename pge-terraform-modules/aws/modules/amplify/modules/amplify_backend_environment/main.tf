/*
 * # AWS Amplify Backend Environment module.
 * Terraform module which creates SAF2.0 Amplify Backend Environment in AWS.
*/

#
#  Filename    : aws/modules/amplify/modules/amplify_backend_environment/main.tf
#  Date        : 4 October 2022
#  Author      : TCS
#  Description : Amplify Backend Environment Creation
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

# Module      : Creation of Amplify Backend Environment
# Description : This terraform module creates an Amplify Backend Environment.

resource "aws_amplify_backend_environment" "amplify_backend_environment" {

  app_id           = var.app_id
  environment_name = var.environment_name

  deployment_artifacts = var.deployment_artifacts
  stack_name           = var.stack_name
}