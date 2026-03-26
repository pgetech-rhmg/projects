#
# Filename    : modules/efs/examples/efs_custom_policy/main.tf
# Date        : 2 february 2022
# Author      : TCS
# Description : Efs usage with custom policy

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags            = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

#########################################
# Create efs file system
#########################################
module "efs" {
  source          = "../../"
  kms_key_id      = null # replace with module.kms_key.key_arn, after key creation
  subnet_id       = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  security_groups = [module.security_group.sg_id]
  policy          = templatefile("${path.module}/${var.custom_policy}", { efs_arn = module.efs.efs_arn, account_num = data.aws_caller_identity.current.account_id, aws_role = var.aws_role })
  tags            = merge(module.tags.tags, local.optional_tags)

  root_directory = [{
    path = "/test"
    creation_info = {
      owner_gid   = 1001
      owner_uid   = 5000
      permissions = "0755"
    }
  }]
}

data "aws_caller_identity" "current" {}


module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}