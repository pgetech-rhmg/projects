/*
 * # AWS VPC-Endpoint-Interface module
 * Terraform module which creates SAF2.0 VPC-Endpoint of type 'Interface' in AWS.
*/
#
#  Filename    : aws/modules/vpc-endpoint/main.tf
#  Date        : 02 March 2022
#  Author      : TCS
#  Description : This terraform module creates a vpc-endpoint of type 'interface'.

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : vpc-interface
# Description : This terraform module creates a vpc-interface

locals {
  namespace       = "ccoe-tf-developers"
  principal_orgid = "o-7vgpdbu22o"
}

data "aws_vpc_endpoint_service" "vpce" {
  service_name = var.service_name
  service_type = "Interface"
}

locals {
  is_supported = data.aws_vpc_endpoint_service.vpce.vpc_endpoint_policy_supported
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

  vpc_endpoint_type   = "Interface"
  service_name        = var.service_name
  vpc_id              = var.vpc_id
  auto_accept         = var.auto_accept
  policy              = local.is_supported ? data.aws_iam_policy_document.combined.json : null
  private_dns_enabled = var.private_dns_enabled
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids

  tags = local.module_tags
}

#Combines the user_defined_policy with the pge_compliance

data "aws_iam_policy_document" "combined" {
  override_policy_documents = [
    templatefile("${path.module}/vpce_pge_compliance_policy.json", { principal_orgid = local.principal_orgid }),
    var.policy
  ]
}