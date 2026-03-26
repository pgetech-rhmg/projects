/*
 * # AWS CodeDeploy Application module
 * Terraform module which creates SAF2.0 CodeDeploy Application in AWS
*/

#
#  Filename    : aws/modules/codedeploy/main.tf
#  Date        : 4 July 2022
#  Author      : TCS
#  Description : CodeDeploy module creates the CodeDeploy application
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



#Provides a CodeDeploy application to be used as a basis for deployments.
resource "aws_codedeploy_app" "codedeploy_app" {

  name             = var.codedeploy_app_name
  compute_platform = var.codedeploy_app_compute_platform
  tags             = local.module_tags
}
