/*
 * # AWS Amplify Branch module.
 * Terraform module which creates SAF2.0 Amplify Branch in AWS.
*/

#
#  Filename    : aws/modules/amplify/modules/amplify_branch/main.tf
#  Date        : 3 October 2022
#  Author      : TCS
#  Description : Amplify Branch Creation
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

# Module      : Creation of Amplify Branch
# Description : This terraform module creates an Amplify Branch.

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_amplify_branch" "amplify_branch" {

  app_id      = var.app_id
  branch_name = var.branch_name

  backend_environment_arn       = var.backend_environment_arn
  basic_auth_credentials        = var.basic_auth_credentials
  description                   = var.description
  display_name                  = var.display_name
  enable_auto_build             = var.enable_auto_build
  enable_basic_auth             = var.enable_basic_auth
  enable_notification           = var.enable_notification
  enable_performance_mode       = var.enable_performance_mode
  enable_pull_request_preview   = var.enable_pull_request_preview
  environment_variables         = var.environment_variables
  framework                     = var.framework
  pull_request_environment_name = var.pull_request_environment_name
  stage                         = var.stage
  ttl                           = var.ttl

  tags = local.module_tags

}