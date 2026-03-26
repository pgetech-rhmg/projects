/*
 * # AWS FIS experiment template module example - S3 Logging.
 * Terraform usage example which creates FIS experimental_template in AWS with S3 logging
 * When using this module, AWS FIS (Fault Injection Simulator) is a fully managed service 
 * that enables you to perform fault injection experiments on your AWS workloads 
*/
# Filename     : aws/modules/fis/examples/ec2_stop_s3_logging/main.tf
#  Date        : 06 Aug 2025
#  Author      : pge
#  Description : The terraform module creates fis experimental_template with S3 logging.


locals {
  name               = var.name
  aws_service        = var.aws_service
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  LogGroupNamePrefix = var.LogGroupNamePrefix
  optional_tags      = var.optional_tags
  Order              = var.Order
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

# S3 bucket for FIS logs (always created for S3 logging example)
module "s3_fis_log_bucket" {
  source        = "app.terraform.io/pgetech/s3/aws"
  version       = "0.1.0"
  bucket_name   = "${var.s3_bucket_name}-${random_string.suffix.result}"
  kms_key_arn   = null
  force_destroy = true
  tags          = merge(module.tags.tags, local.optional_tags)

  # Pass the FIS logging policy using the policy parameter
  policy = templatefile("${path.module}/fis_s3_bucket_policy.json", {
    bucket_name = "${var.s3_bucket_name}-${random_string.suffix.result}"
  })
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Define the FIS Experiment Template
module "fis_experimental_template" {
  source                    = "../.."
  fis_experiment_name       = var.fis_experiment_name
  description               = var.description
  tags                      = merge(module.tags.tags, local.optional_tags)
  stop_condition            = var.stop_condition
  experiment_options        = var.experiment_options
  target                    = var.target
  action                    = var.action
  fis_role_name             = var.fis_role_name # Empty to create new role, or specify existing role name
  inline_policy             = var.inline_policy # Optional: Add custom policies in addition to the default FIS policy
  log_type                  = "s3"
  s3_bucket_name            = module.s3_fis_log_bucket.id
  validate_s3_bucket        = false # Bucket is created in this example
  s3_logging                = var.s3_logging
  cloudwatch_log_group_name = ""
}