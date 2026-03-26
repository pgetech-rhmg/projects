/*
 * # AWS WAF IP Set Regional module example
*/
#
# Filename    : aws/modules/waf-v2/examples/waf_v2_ipset_regional/main.tf
# Date        : 7 March 2022
# Author      : TCS
# Description : WAF Ip set regional usage creation main.
#

locals {
  name  = "${var.name}-${random_string.name.result}"
  Order = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

#########################################
# Create WAF Ipset
#########################################

module "wafv2_ip_set" {
  source = "../../modules/wafv2_ip_set_regional"

  wafv2_ip_set_name               = local.name
  wafv2_ip_set_description        = var.wafv2_ip_set_description
  wafv2_ip_set_ip_address_version = var.wafv2_ip_set_ip_address_version
  wafv2_ip_set_addresses          = var.wafv2_ip_set_addresses
  tags                            = merge(module.tags.tags, var.optional_tags)
}