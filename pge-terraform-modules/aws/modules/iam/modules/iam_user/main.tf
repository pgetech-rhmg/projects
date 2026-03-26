/*
 * # AWS IAM User module
 * Terraform module which creates SAF2.0 IAM User in AWS
*/
#
# Filename    : modules/iam/iam_user/main.tf
# Date        : 22 Nov 2021
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : iam user creation module
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


resource "aws_iam_user" "default" {
  name                 = var.name
  path                 = var.path
  force_destroy        = var.force_destroy
  permissions_boundary = var.permissions_boundary
  tags                 = local.module_tags
}
