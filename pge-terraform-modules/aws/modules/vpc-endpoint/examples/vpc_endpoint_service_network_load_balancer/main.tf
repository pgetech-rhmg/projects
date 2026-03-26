#
# Filename    : modules/vpc-endpoint/examples/vpc_endpoint_service_network_load_balancer/main.tf
# Date        : 6 January 2022
# Author      : TCS
# Description : VPC Endpoint Service useage creation main.


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

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.subnet_id2_name
}

################################################################
# Create VPC Endpoint Service for Network Load Balancer
################################################################

module "vpc_endpoint_service_network_load_balancer" {
  source                     = "../../modules/vpce_service_network_loadbalancer"
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [module.nlb1.lb_arn, module.nlb2.lb_arn]
  tags                       = merge(module.tags.tags, local.optional_tags)
}


# module 'nlb1' and 'nlb2' to be replaced with network loadbalancer arns.

module "nlb1" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "8.7.0"
  name               = var.name
  subnets            = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  internal           = true
  load_balancer_type = var.load_balancer_type
}

module "nlb2" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "8.7.0"
  name               = var.name
  subnets            = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  internal           = true
  load_balancer_type = var.load_balancer_type
}