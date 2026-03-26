/*
 * # AWS IAM Security Group module
 * Terraform module which creates SAF2.0 Security Group in AWS
*/

# Filename    : modules/security-group/main.tf
# Date        : 27 December 2021
# Author      : Renuka Uppalapati (rxuu@pge.com)
# Description : security group module main
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_security_group" "default" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = local.module_tags
}

resource "aws_security_group_rule" "cidr_ingress" {
  type              = "ingress"
  security_group_id = resource.aws_security_group.default.id
  for_each = {
  for ingress in var.cidr_ingress_rules : "${ingress.description} ${ingress.from} ${ingress.to} ${ingress.protocol}}" => ingress }

  from_port        = each.value.from
  to_port          = each.value.to
  protocol         = each.value.protocol
  cidr_blocks      = each.value.cidr_blocks
  ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
  prefix_list_ids  = each.value.prefix_list_ids
  description      = each.value.description
}

resource "aws_security_group_rule" "cidr_egress" {
  type              = "egress"
  security_group_id = resource.aws_security_group.default.id
  for_each = {
  for egress in var.cidr_egress_rules : "${egress.description} ${egress.from} ${egress.to} ${egress.protocol}}" => egress }

  from_port        = each.value.from
  to_port          = each.value.to
  protocol         = each.value.protocol
  cidr_blocks      = each.value.cidr_blocks
  ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
  prefix_list_ids  = each.value.prefix_list_ids
  description      = each.value.description
}


resource "aws_security_group_rule" "security_group_ingress" {
  type              = "ingress"
  security_group_id = resource.aws_security_group.default.id
  for_each = {
  for ingress in var.security_group_ingress_rules : "${ingress.description} ${ingress.from} ${ingress.to} ${ingress.protocol} }" => ingress }
  from_port                = each.value.from
  to_port                  = each.value.to
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id == "" ? aws_security_group.default.id : each.value.source_security_group_id
}

resource "aws_security_group_rule" "security_group_egress" {
  type              = "egress"
  security_group_id = resource.aws_security_group.default.id
  for_each = {
  for egress in var.security_group_egress_rules : "${egress.description} ${egress.from} ${egress.to} ${egress.protocol}" => egress }

  from_port                = each.value.from
  to_port                  = each.value.to
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id == "" ? aws_security_group.default.id : each.value.source_security_group_id
}

