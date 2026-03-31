locals {
  app_id              = var.app_id
  environment         = var.environment
  data_classification = var.data_classification
  cris                = var.cris
  notify              = var.notify
  owner               = var.owner
  compliance          = var.compliance
  name                = var.name
  order               = var.order

}

# combine the standard PGE tags with any optional tags provided via variable
locals {
  merged_tags = merge(module.tags.tags, var.optional_tags)
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.app_id
  Environment        = local.environment
  DataClassification = local.data_classification
  CRIS               = local.cris
  Notify             = local.notify
  Owner              = local.owner
  Order              = local.order
  Compliance         = local.compliance
}


################################################################################
# Supporting Resources
################################################################################
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/privatesubnet1/id"
}

data "aws_ssm_parameter" "subnet_id2" {
  name = "/vpc/privatesubnet2/id"
}

data "aws_ssm_parameter" "subnet_id3" {
  name = "/vpc/privatesubnet3/id"
}

data "aws_ssm_parameter" "enterprise_kms" {
  name = "/enterprise/kms/keyarn"
}

data "aws_ssm_parameter" "rhellinux_golden_ami" {
  name = "/ami/rhellinux/golden"
}

# Data source for current AWS region
data "aws_region" "current" {}

# Data source for current AWS Account
data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  id = data.aws_ssm_parameter.vpc_id.value
}

data "aws_organizations_organization" "current" {}

