/*
 * # AWS Sagemaker endpoint_configuration serverless
 * # Terraform module which creates Sagemaker endpoint_configuration_serverless
*/
#
#  Filename    : aws/modules/sagemaker/examples/endpoint_config_serverless/main.tf
#  Date        : Sept 7 2022
#  Author      : TCS
#  Description : The terraform module creates a sagemaker endpoint_configuration_serverless for Sagemaker

locals {
  optional_tags = var.optional_tags
  aws_role      = var.aws_role
  kms_role      = var.kms_role
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
  length           = 8
  special          = true
  override_special = "-"
}

module "endpoint_configuration" {
  source = "../../modules/endpoint_configuration"

  name              = local.name
  kms_key_id        = null # replace with module.kms_key.key_arn, after key creation
  model_name        = var.model_name
  variant_name      = var.variant_name
  serverless_config = var.serverless_config

  tags = merge(module.tags.tags, local.optional_tags)
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