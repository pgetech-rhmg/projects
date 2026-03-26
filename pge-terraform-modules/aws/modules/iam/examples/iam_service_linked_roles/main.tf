/*
 * # AWS IAM SLR module
 * Terraform module which creates SAF2.0 IAM Service Linked Roles in AWS
*/
#
#  Filename    : modules/iam/iam_service_linked_roles/main.tf
#  Date        : 11 Feb 2021
#  Author      : Sara Ahmad (s7aw@pge.com)
#  Description : IAM SLR creation module
#

locals {
  aws_service_names  = var.aws_service_names
  description        = var.description
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

module "aws_iam_service_linked_roles" {
  source            = "../../modules/iam_service_linked_roles"
  aws_service_names = local.aws_service_names
  description       = local.description
  tags              = merge(module.tags.tags, local.optional_tags)
}

