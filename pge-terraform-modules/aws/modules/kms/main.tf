/*
 * # AWS KMS  module
 * Terraform module which creates SAF2.0 CMK in AWS
*/
#
#  Filename    : modules/kms/main.tf
#  Date        : Nov 22 2021
#  Author      : Sara Ahmad (s7aw@pge.com)
#  Description : This terraform module creates a KMS Customer Master Key (CMK) and its alias.
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
  principal_orgid          = "o-7vgpdbu22o"
  namespace                = "ccoe-tf-developers"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"

}

data "aws_caller_identity" "current" {}

#Combines the user_defined_policy with the pge_compliance_kms_policy
data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    templatefile("${path.module}/kms_pge_compliance_policy.json",
      {
        account_num     = data.aws_caller_identity.current.account_id
        aws_role        = var.aws_role
        kms_role        = var.kms_role
        principal_orgid = local.principal_orgid
    }, ),
    var.policy
  ]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



# Module      : KMS KEY
# Description : Creates the KMS customer master key.
resource "aws_kms_key" "default" {
  description              = var.description
  key_usage                = var.key_usage
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = local.enable_key_rotation
  customer_master_key_spec = local.customer_master_key_spec
  multi_region             = var.multi_region
  policy                   = data.aws_iam_policy_document.combined.json
  tags                     = local.module_tags
}

# Module      : KMS ALIAS
# Description : Provides an alias for a KMS customer master key.
resource "aws_kms_alias" "default" {
  name          = "alias/${var.name}"
  target_key_id = join("", aws_kms_key.default.*.id)
}