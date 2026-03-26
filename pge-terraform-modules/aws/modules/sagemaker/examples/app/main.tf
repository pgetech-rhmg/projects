/*
 * # AWS Sagemaker app example
 * # Terraform module example usage for Sagemaker app
*/
#
#  Filename    : aws/modules/sagemaker/examples/app/main.tf
#  Date        : 07 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates aws_sagemaker_app

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

# This has been tested only with 'JupyterServer' app_type, Getting the below quota error while testing with 'KernelGateway and TensorBoard' options
# Error:ResourceLimitExceeded: The account-level service limit is 0 Apps, with current utilization of 0 Apps and a request delta of 1 Apps. Please contact AWS support to request an increase for this limit. 
module "app" {
  source = "../../"

  name              = local.name
  app_type          = var.app_type
  domain_id         = var.domain_id
  user_profile_name = var.user_profile_name
  tags              = merge(module.tags.tags, var.optional_tags)
}