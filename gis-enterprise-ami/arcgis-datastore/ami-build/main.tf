locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  name               = var.name
  Order              = var.Order

}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Order              = local.Order
  Compliance         = local.Compliance
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

data "aws_ssm_parameter" "gas_kms" {
  name = "/gas/kms/keyarn"
}

data "aws_ssm_parameter" "rhellinux_golden_ami" {
  name = "/ami/rhellinux/golden"
}

# Data source for current AWS region
data "aws_region" "current" {}
