#
# Filename    : modules/vpc-endpoint/examples/vpc_endpoint_gateway/main.tf
# Date        : 6 January 2022
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

#########################################
# Create VPC Endpoint
#########################################
module "vpc_endpoint" {
  source          = "../../modules/vpce_gateway"
  service_name    = var.service_name
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  route_table_ids = var.route_table_ids
  tags            = merge(module.tags.tags, local.optional_tags)
}

