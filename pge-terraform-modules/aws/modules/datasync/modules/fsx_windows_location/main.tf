/*
 * # AWS DataSync module
 * Terraform module which creates SAF2.0 DataSync FSx for Windows location resources in AWS.
*/
#
#  Filename    : modules/datasync/fsx_windows_location/main.tf
#  Date        : 09 May 2024
#  Author      : Eric Barnard (e6bo@pge.com)
#  Description : The module will create an FSx for Windows location for DataSync
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

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_datasync_location_fsx_windows_file_system" "this" {
  fsx_filesystem_arn  = var.filesystem_arn
  domain              = var.domain
  user                = var.user
  password            = var.password
  security_group_arns = var.security_group_arns
  subdirectory        = var.subdirectory

  tags = local.module_tags
}