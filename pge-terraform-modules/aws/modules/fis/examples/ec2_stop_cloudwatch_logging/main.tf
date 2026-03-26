/*
 * # AWS FIS experiment template module example - CloudWatch Logging.
 * Terraform usage example which creates FIS experimental_template in AWS with CloudWatch logging
 * When using this module, AWS FIS (Fault Injection Simulator) is a fully managed service 
 * that enables you to perform fault injection experiments on your AWS workloads 
*/
# Filename     : aws/modules/fis/examples/ec2_stop_cloudwatch_logging/main.tf
#  Date        : 06 Aug 2025
#  Author      : pge
#  Description : The terraform module creates fis experimental_template with CloudWatch logging.


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

# CloudWatch log group for FIS logs (always created for CloudWatch logging example)
resource "aws_cloudwatch_log_group" "this" {
  name = var.cloudwatch_log_group_name
  tags = merge(module.tags.tags, local.optional_tags)
}

# Define the FIS Experiment Template
module "fis_experimental_template" {
  source              = "../.."
  fis_experiment_name = var.fis_experiment_name
  description         = var.description
  tags                = merge(module.tags.tags, local.optional_tags)
  stop_condition      = var.stop_condition
  experiment_options  = var.experiment_options
  target              = var.target
  action              = var.action
  fis_role_name       = var.fis_role_name # Empty to create new role default is "default-fis-role" used in main.tf of root module, or specify existing role name
  inline_policy       = var.inline_policy # User can pass custom policy or leave empty for default
  log_type            = "cloudwatch"
  log_schema_version  = var.log_schema_version
  s3_bucket_name      = ""
  validate_s3_bucket  = false # Not using S3 in this example
  s3_logging = {
    prefix = ""
  }
  cloudwatch_log_group_arn  = aws_cloudwatch_log_group.this.arn
  cloudwatch_log_group_name = "" # Empty since we're using ARN
}