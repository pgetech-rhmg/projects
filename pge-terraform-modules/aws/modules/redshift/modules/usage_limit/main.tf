/*
 * # AWS Redshift
 * Terraform module which creates SAF2.0 Redshift usage limits in AWS
*/
#
# Filename    : aws/modules/redshift/modules/usage_limit/main.tf
# Description : This terraform module creates redshift usage_limit
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



resource "aws_redshift_usage_limit" "usage-one" {
  cluster_identifier = var.cluster_identifier
  breach_action      = var.breach_action
  feature_type       = var.validate_feature_limit.feature_type
  limit_type         = var.validate_feature_limit.limit_type
  amount             = var.amount
  period             = var.period
  tags               = local.module_tags
}