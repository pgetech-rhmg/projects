/*
 * # AWS Lambda layer version with S3 Bucket User module example
*/
#
#  Filename    : aws/modules/lambda/examples/lambda_layer_version_s3/main.tf
#  Date        : 03 March 2022
#  Author      : TCS
#  Description : The terraform module creates a Lambda function


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
  aws_role           = var.aws_role
  kms_role           = var.kms_role
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

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

#########################################
# Create Lambda layer version
#########################################

module "lambda_layer_version" {
  source = "../../modules/lambda_layer_version_s3"

  layer_version_layer_name               = "${var.layer_version_layer_name}_${random_string.name.result}"
  layer_version_compatible_architectures = var.layer_version_compatible_architectures
  layer_version_description              = var.layer_version_description
  layer_version_compatible_runtimes      = var.layer_version_compatible_runtimes

  s3_bucket         = module.s3.id
  s3_key            = aws_s3_object.lambda_object.key
  s3_object_version = aws_s3_object.lambda_object.version_id

  #layer_version_permission
  layer_version_permission_action       = var.layer_version_permission_action
  layer_version_permission_statement_id = var.layer_version_permission_statement_id
  layer_version_permission_principal    = var.layer_version_permission_principal
}

module "s3" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.1"
  bucket_name = "${var.s3_bucket_name}-${random_string.name.result}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, local.optional_tags)
}

resource "aws_s3_object" "lambda_object" {
  bucket = module.s3.id
  key    = var.bucket_object_key
  source = "${path.module}/${var.bucket_object_source}"
  etag   = filemd5("${path.module}/${var.bucket_object_source}")
}



