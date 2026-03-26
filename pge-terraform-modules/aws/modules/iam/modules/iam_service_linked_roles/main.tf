/*
 * # AWS IAM SLR module
 * Terraform module which creates SAF2.0 IAM Service Linked Roles in AWS
*/
#
#  Filename    : modules/iam/iam_service_linked_roles/main.tf
#  Date        : 11 Feb 2021
#  Author      : Sara Ahmad (s7aw@pge.com)
#  Description : IAM SLR creation module
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

resource "aws_iam_service_linked_role" "default" {
  for_each         = toset(var.aws_service_names)
  aws_service_name = each.value
  custom_suffix    = var.custom_suffix
  description      = var.description
  tags             = local.module_tags
}
