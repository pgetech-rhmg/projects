/*
 * # AWS DocumentDB Subnet Group
 * Terraform module which creates SAF2.0 DocumentDB Subnet Group in AWS
*/

#
#  Filename    : aws/modules/documentdb/modules/subnet_group/main.tf
#  Date        : 04 August 2022
#  Author      : TCS
#  Description : Terraform module for creation of subnet_group
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

# Workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



# Provides an DocumentDB subnet group resource.
resource "aws_docdb_subnet_group" "subnet_group" {

  name        = var.subnet_group_name
  description = coalesce(var.subnet_group_description, format("%s subnet group - Managed by Terraform", var.subnet_group_name))
  subnet_ids  = var.subnet_group_subnet_ids
  tags        = local.module_tags
}