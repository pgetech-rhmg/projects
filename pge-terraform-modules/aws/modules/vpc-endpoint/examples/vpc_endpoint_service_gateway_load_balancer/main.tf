#
# Filename    : modules/vpc-endpoint/examples/vpc_endpoint_service_gateway_load_balancer/main.tf
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
# Create VPC Endpoint Service for Gateway Load Balancer
################################################################

module "vpc_endpoint_service_gateway_load_balancer" {

  source                     = "../../modules/vpce_service_gateway_loadbalancer"
  acceptance_required        = var.acceptance_required
  gateway_load_balancer_arns = [aws_lb.glb1.arn, aws_lb.glb2.arn]
  tags                       = merge(module.tags.tags, local.optional_tags)

}

# resource 'glb1' and 'glb2' to be replaced with gateway loadbalancer arns.
# Using the resource as terraform public module supports only ALB/NLB.

resource "aws_lb" "glb1" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  subnets            = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  internal           = false
  tags               = merge(module.tags.tags, local.optional_tags)
}

resource "aws_lb" "glb2" {
  name               = var.name
  load_balancer_type = var.load_balancer_type
  subnets            = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  internal           = false
  tags               = merge(module.tags.tags, local.optional_tags)
}


