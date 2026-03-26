/*
 * # AWS Sagemaker
*/
#
#  Filename    : aws/modules/sagemaker/examples/human_task_ui/main.tf
#  Date        : 25 Aug 2022
#  Author      : TCS
#  Description : The terraform module creates human_task_ui

locals {
  optional_tags = var.optional_tags
  name          = "${var.name}-${random_string.name.result}"
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
  Order              = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

# This will pull the human task ui module
module "human_task_ui" {
  source = "../../modules/human_task_ui"

  human_task_ui_name = local.name
  content            = file("${path.module}/${var.content}")
  tags               = merge(module.tags.tags, local.optional_tags)
}