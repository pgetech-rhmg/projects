/*
 * # AWS Lambda layer version using Amazon S3
 * Terraform module which creates SAF2.0 Lambda layer version in AWS
*/
#
#  Filename    : aws/modules/lambda/modules/lambda_layer_version_s3/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : LAMBDA terraform module creates a Lambda layer version
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  organization_id = "o-7vgpdbu22o"
}

resource "aws_lambda_layer_version" "layer_version" {

  layer_name               = var.layer_version_layer_name
  compatible_architectures = [var.layer_version_compatible_architectures]
  compatible_runtimes      = var.layer_version_compatible_runtimes
  description              = var.layer_version_description
  license_info             = var.layer_version_license_info

  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  skip_destroy = var.layer_skip_destroy
}

resource "aws_lambda_layer_version_permission" "layer_version_permission" {
  count = var.layer_version_permission_action != null ? 1 : 0

  action          = var.layer_version_permission_action
  layer_name      = aws_lambda_layer_version.layer_version.layer_name
  organization_id = var.layer_version_permission_principal == "*" ? local.organization_id : null
  principal       = var.layer_version_permission_principal
  statement_id    = var.layer_version_permission_statement_id
  version_number  = aws_lambda_layer_version.layer_version.version
}
