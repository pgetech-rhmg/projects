/*
 * # AWS EBS module
 * Terraform module which creates SAF2.0 EBS in AWS
*/
#
#  Filename    : modules/ebs/main.tf
#  Date        : 6 Jan 2022
#  Author      : TCS
#  Description : The module will create EBS volume
# 

terraform {
  required_version = ">= 0.1.0"
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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_ebs_volume" "ebs" {
  availability_zone    = var.availability_zone
  encrypted            = true
  iops                 = var.iops
  multi_attach_enabled = var.multi_attach_enabled
  size                 = var.size
  type                 = var.type
  kms_key_id           = var.kms_key_id
  tags                 = local.module_tags
  throughput           = var.throughput
}

resource "aws_volume_attachment" "volume_attachment" {
  count       = length(var.instance_id)
  device_name = var.device_name
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = element(var.instance_id, (count.index))
}
