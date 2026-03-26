/*
 * # AWS Redshift
 * Terraform module which creates SAF2.0 Redshift usage limits in AWS
*/
#  Filename    : aws/modules/redshift/modules/snapshot_copy_grant_snapshot/main.tf
#  Description : The terraform module creates a snapshot_copy_grant for redshift cluster

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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}

resource "aws_redshift_snapshot_copy_grant" "test_tf" {
  snapshot_copy_grant_name = var.snapshot_copy_grant_name
  kms_key_id               = var.kms_key_id

  tags = local.module_tags
}
