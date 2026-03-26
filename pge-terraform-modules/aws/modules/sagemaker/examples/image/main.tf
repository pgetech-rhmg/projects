/*
 * # AWS Sagemaker image example
*/
#
#  Filename    : aws/modules/sagemaker/examples/image/main.tf
#  Date        : 01 Sep 2022
#  Author      : TCS
#  Description : The terraform module creates image

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

# This will pull the image module
module "image" {
  source = "../../modules/image"

  image_name = local.name
  role_arn   = module.image_iam_role.arn
  tags       = merge(module.tags.tags, var.optional_tags)
}

module "image_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  aws_service = var.role_service
  tags        = merge(module.tags.tags, var.optional_tags)
  #inline_policy for the 'Assume Role'
  inline_policy = [file("${path.module}/image_policy.json")]
}