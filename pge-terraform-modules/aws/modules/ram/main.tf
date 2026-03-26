/*
 * # AWS RAM module
 * Terraform module which creates SAF2.0 RAM resources  in AWS
*/
#
# Filename    : modules/ram/main.tf
# Date        : 25 Mar 2025
# Author      : Sethu Lakshmi (sul3@pge.com)
# Description : The modules creates AWS RAM resources
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
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_ram_resource_share" "default" {
  name                      = var.share_name
  allow_external_principals = var.allow_external_principals
  permission_arns           = var.permission_arns

  tags = local.module_tags

}