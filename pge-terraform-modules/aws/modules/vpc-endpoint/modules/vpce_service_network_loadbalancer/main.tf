/*
 * # AWS VPC-Endpoint-Gatewayloadbalancer module
 * Terraform module which creates SAF2.0 VPC-Endpoint service of type 'Gatewayloadbalancer' in AWS.
*/
#
#  Filename    : aws/modules/vpc-endpoint/modules/vpc_network_load_balancer/main.tf
#  Date        : 03 March 2022
#  Author      : TCS
#  Description : This terraform module creates Vpc-endpoint service of type 'gatewayloadbalancer' for network loadbalancers.


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# This terraform module creates vpc-endpoint service of type 'GatewayLoadBalancer' for network load balancers.

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



################################################################
# Create VPC Endpoint Service for Network Load Balancer
################################################################

resource "aws_vpc_endpoint_service" "network_load_balancer" {

  network_load_balancer_arns = var.network_load_balancer_arns
  acceptance_required        = var.acceptance_required
  allowed_principals         = var.allowed_principals
  private_dns_name           = var.private_dns_name
  tags                       = local.module_tags

}
