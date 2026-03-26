/*
 * # AWS ACM module creating Private CA issued certificate
 * Terraform module which creates SAF2.0 ACM in AWS
*/
#
# Filename    : aws/modules/acm/modules/acm_private_ca/main.tf
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

  domain_name               = var.acm_domain_name
  certificate_authority_arn = var.acm_certificate_authority_arn
  subject_alternative_names = var.acm_subject_alternative_names
  tags                      = local.module_tags

  lifecycle {
    create_before_destroy = true
  }
}
