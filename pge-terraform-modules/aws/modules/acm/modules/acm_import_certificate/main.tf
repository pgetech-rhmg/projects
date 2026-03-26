/*
 * # AWS ACM module Importing an existing certificate
 * Terraform module which creates SAF2.0 ACM in AWS
*/
#
# Filename    : aws/modules/acm/modules/acm_import_certificate/main.tf
# Date        : 28/03/2022
# Author      : TCS
# Description : AWS Certificate Manager module main
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



resource "aws_acm_certificate" "acm_certificate" {

  private_key       = var.acm_private_key
  certificate_body  = var.acm_certificate_body
  certificate_chain = var.acm_certificate_chain
  tags              = local.module_tags

  lifecycle {
    create_before_destroy = true
  }
}
