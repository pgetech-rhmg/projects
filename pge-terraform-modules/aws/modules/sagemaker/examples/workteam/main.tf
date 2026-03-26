/*
 * # AWS Sagemaker Workteam example
 * # Terraform module example usage for Sagemaker Workteam
*/
#
#  Filename    : aws/modules/sagemaker/examples/workteam/main.tf
#  Date        : 14 Sep 2022
#  Author      : TCS
#  Description : The terraform usage example creates Sagemaker Workteam

locals {
  name = "${var.name}-${random_string.name.result}"
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

# This will pull the workteam module
module "workteam" {
  source = "../../modules/workteam"

  workforce_name = var.workforce_name
  workteam_name  = local.name
  #For private workforces created using Amazon Cognito use cognito_member_definition.
  member_definition = {
    cognito_member_definition = {
      client_id  = var.client_id
      user_pool  = var.user_pool
      user_group = var.user_group
    }
    oidc_member_definition = {}
  }
  notification_configuration = {
    notification_topic_arn = module.sns_workteam.sns_topic_arn
  }
  tags = merge(module.tags.tags, var.optional_tags)
}

module "sns_workteam" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.1"

  snstopic_name         = local.name
  snstopic_display_name = local.name
  policy                = file("${path.module}/policy.json")
  tags                  = merge(module.tags.tags, var.optional_tags)
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "kms_key" {
# source  = "app.terraform.io/pgetech/kms/aws"
# version = "0.1.2"

#  name     = "cmk-${local.name}"
# policy   = file("${path.module}/kms_policy.json")
#  kms_role = var.kms_role
#  aws_role = var.aws_role
#  tags     = merge(module.tags.tags, var.optional_tags)
#}