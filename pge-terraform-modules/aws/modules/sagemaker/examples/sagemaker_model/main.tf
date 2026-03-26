/*
 * # AWS Sagemaker Model example
 * # Terraform module which creates Sagemaker Model
*/
#  Filename    : aws/modules/sagemaker/examples/sagemaker_model/main.tf
#  Date        : 13 Sep 2022
#  Author      : TCS
#  Description : The Terraform usage example creates Sagemaker model

# This will pull the sagemaker_model module
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

module "sagemaker_model" {
  source = "../../modules/sagemaker_model"

  name               = local.name
  execution_role_arn = module.sagemaker_iam_role.arn
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  containers = {
    primary_container = {
      image              = var.image
      model_data_url     = var.model_data_url
      container_hostname = var.container_hostname
      environment        = var.environment
      mode               = var.mode
    }
    container = []
  }
  tags = merge(module.tags.tags, var.optional_tags)
}

module "sagemaker_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = local.name
  aws_service = var.role_service
  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
  tags        = merge(module.tags.tags, var.optional_tags)
}