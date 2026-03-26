/*
 * # RDS db_cluster_endpoint module
 * Terraform module which creates SAF2.0 db_cluster_endpoint module
*/
#
#  Filename    : modules/rds/modules/internal/db_cluster_endpoint/main.tf
#  Date        : 5/9/2022
#  Author      : PGE
#  Description : AWS db_cluster_endpoint main file.
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

  create_static   = length(var.excluded_members) == 0 && length(var.static_members) > 0 ? 1 : 0
  create_excluded = local.create_static == 0 ? 1 : 0
  namespace       = "ccoe-tf-developers"

}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags_static   = merge(var.tags, { pge_team = local.namespace, Name = "static cluster endpoint - ${var.custom_endpoint_type}", tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  module_tags_excluded = merge(var.tags, { Name = "excluded cluster endpoint - ${var.custom_endpoint_type}", tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_rds_cluster_endpoint" "static" {
  count = local.create_static

  cluster_identifier          = var.cluster_identifier
  cluster_endpoint_identifier = var.cluster_endpoint_identifier
  custom_endpoint_type        = var.custom_endpoint_type
  static_members              = var.static_members
  tags                        = local.module_tags_static
}

resource "aws_rds_cluster_endpoint" "excluded" {
  count = local.create_excluded

  cluster_identifier          = var.cluster_identifier
  cluster_endpoint_identifier = var.cluster_endpoint_identifier
  custom_endpoint_type        = var.custom_endpoint_type
  excluded_members            = var.excluded_members
  tags                        = local.module_tags_excluded
}

