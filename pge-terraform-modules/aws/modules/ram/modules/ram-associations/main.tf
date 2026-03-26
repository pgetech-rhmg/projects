/*
 * # AWS RAM module
 * Terraform module which creates SAF2.0 AWS RAM Associations resources
*/

# Filename    : modules/associations/main.tf
# Date        : 25 Mar 2025
# Author      : Sethu Lakshmi (sul3@pge.com)
# Description : Provides an AWS RAM Association resource
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
  #module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_ram_resource_association" "ram_association" {
  for_each           = { for idx, arns in var.resource_arns : idx => arns }
  resource_arn       = each.value
  resource_share_arn = var.resource_share_arn
  
}

resource "aws_ram_principal_association" "account_sharing" {
  for_each           = toset(var.principal_ids)
  principal          = each.value
  resource_share_arn = var.resource_share_arn
  lifecycle {
    create_before_destroy = true
  }
}