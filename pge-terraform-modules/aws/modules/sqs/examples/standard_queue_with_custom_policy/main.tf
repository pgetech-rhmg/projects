/*
* # AWS SQS module
* # Module: This module creates custom policy for SQS standard queue
*/

#  Filename    : aws/modules/sqs/example/custom_policy/main.tf
#  Date        : 02 Febraury 2022
#  Author      : TCS
#  Description : This module creates custom policy for SQS standard queue 

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.Optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
#}

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
  Order              = var.Order
}

module "sqs_deadletter_queue" {
  source = "../../modules/sqs_standard_queue"

  sqs_name   = var.sqs_deadletter_name
  kms_key_id = null # replace with module.kms_key.key_arn, after key creation
  tags       = merge(module.tags.tags, local.optional_tags)
}

module "sqs" {
  source = "../../modules/sqs_standard_queue"

  sqs_name   = var.sqs_name
  kms_key_id = null # replace with module.kms_key.key_arn, after key creation
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [module.sqs_deadletter_queue.arn]
  })
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.sqs_deadletter_queue.arn
    maxReceiveCount     = 5
  })
  policy = file("${path.module}/${var.custom_policy}")
  tags   = merge(module.tags.tags, local.optional_tags)
}

