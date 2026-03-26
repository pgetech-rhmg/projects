/*
 * # AWS Step Functions Create Activity example
*/
#
#  Filename    : aws/modules/step-functions/examples/create_activity/main.tf
#  Date        : 13 Oct 2022
#  Author      : TCS
#  Description : The terraform example creates a step-functions create activity


locals {
  name = "${var.name}-${random_string.name.result}"
  Order = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
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

#Provides a Step Functions Activity
module "activity" {
  source = "../../modules/sfn_activity"

  sfn_activity_name = local.name
  tags              = merge(module.tags.tags, var.optional_tags)
}
