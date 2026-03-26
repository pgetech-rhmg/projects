/*
 * # AWS WAF Ip Set Cloudfront module
 * Terraform module which creates SAF2.0 WAF Ip Set Cloudfront in AWS
*/

#
#  Filename    : aws/modules/waf-v2/modules/wafv2_ip_set_cloudfront/main.tf
#  Date        : 3 March 2022
#  Author      : TCS
#  Description : WAF terraform module to create a waf ip set cloudfront.
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



# Module      : WAF Ip Set
# Description : This terraform module creates a waf ip set cloudfront.

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "aws_wafv2_ip_set" "wafv2_ip_set" {

  name               = var.wafv2_ip_set_name
  description        = coalesce(var.wafv2_ip_set_description, format("%s waf ip set description - Managed by Terraform", var.wafv2_ip_set_name))
  scope              = "CLOUDFRONT"
  ip_address_version = var.wafv2_ip_set_ip_address_version
  addresses          = var.wafv2_ip_set_addresses
  tags               = local.module_tags
}