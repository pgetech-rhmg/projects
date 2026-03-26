#
# Filename    : modules/vpc-endpoint/examples/vpc_endpoint_custom_policy/main.tf
# Date        : 20 January 2021
# Author      : TCS
# Description : The Terraform Module creates VPC Endpoints

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
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

#########################################
# Create vpcendpoint
#########################################

module "vpc_endpoint" {
  source             = "../../"
  service_name       = var.service_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  policy             = file("${path.module}/${var.policy_file_name}")
  security_group_ids = [module.security_group.sg_id]
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = var.sg_name
  description        = "Security group for example usage with VPC Endpoint"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}