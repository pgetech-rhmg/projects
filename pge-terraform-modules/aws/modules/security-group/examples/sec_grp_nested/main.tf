/*
 * # AWS IAM Security Group module
 * Terraform module which creates SAF2.0 Security Group in AWS
*/
#
# Filename    : modules/security-group/examples/sec_grp_nested/main.tf
# Date        : 09 December 2021
# Author      : PGE
# Description : security group creation
#
locals {
  nested_name        = var.nested_name
  nested_description = var.description
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
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
  Compliance         = local.Compliance
  Order              = local.Order
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

#########################################
# Create Nested Security Group
#########################################

module "nested_security_group" {
  source                       = "../../"
  name                         = local.nested_name
  description                  = local.nested_description
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules           = var.cidr_ingress_rules
  cidr_egress_rules            = var.cidr_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  tags                         = module.tags.tags
}
