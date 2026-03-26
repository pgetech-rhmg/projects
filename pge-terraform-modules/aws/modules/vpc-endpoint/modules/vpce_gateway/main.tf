/*
 * # AWS VPC-Endpoint-Gateway module
 * Terraform module which creates SAF2.0 VPC-Endpoint of type 'Gateway' in AWS.
*/
#
#  Filename    : aws/modules/vpc-endpoint/modules/vpc_gateway/main.tf
#  Date        : 03 March 2022
#  Author      : TCS
#  Description : This terraform module creates a vpc-endpoint of type 'gateway'.


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : vpc-endpoint of type gateway

locals {
  namespace       = "ccoe-tf-developers"
  principal_orgid = "o-7vgpdbu22o"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}




resource "aws_vpc_endpoint" "vpc_endpoint" {

  vpc_endpoint_type = "Gateway"
  service_name      = var.service_name
  vpc_id            = var.vpc_id
  auto_accept       = var.auto_accept
  policy            = data.aws_iam_policy_document.combined.json
  route_table_ids   = var.route_table_ids
  tags              = local.module_tags
}

#Combines the user_defined_policy with the pge_compliance

data "aws_iam_policy_document" "combined" {
  override_policy_documents = [
    templatefile("${path.module}/vpce_pge_compliance_policy.json", { principal_orgid = local.principal_orgid }),
    var.policy
  ]
}