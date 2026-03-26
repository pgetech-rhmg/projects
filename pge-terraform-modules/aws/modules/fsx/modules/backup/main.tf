/*
 * # AWS Fsx windows and lustre backup
 * Terraform module which creates SAF2.0 fsx windows and lustre backup in AWS.
*/

#
#  Filename    : aws/modules/fsx/modules/backup/main.tf
#  Date        : 19 september 2022
#  Author      : TCS
#  Description : Terraform module creates a fsx windows and lustre backup
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


# Provides a FSx Backup resource.
resource "aws_fsx_backup" "fsx_backup" {

  file_system_id = var.file_system_id
  tags           = local.module_tags

  timeouts {
    create = try(var.timeouts.create, "10m")
    delete = try(var.timeouts.delete, "10m")
  }
}