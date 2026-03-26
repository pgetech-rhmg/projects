/*
 * # AWS ACM public certificate with dns validation User module example
 * This example will handle the record creation in Route53 if acm_r53update_validate is set to true. By default, it will launch into public zone of r53 account.
*/
#
#  Filename    : aws/modules/acm/examples/acm_public_certificate/main.tf
#  Date        : 28/03/2022
# Author       : TCS
#  Description : Terraform module that creates an ACM


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

#########################################
# Create Acm
#########################################

module "acm_public_certificate" {
  source = "../../"
  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  acm_domain_name = var.acm_domain_name
  tags            = merge(module.tags.tags, local.optional_tags)
}
