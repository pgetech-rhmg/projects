/*
* # AWS SQS module
* # Module: This module creates SQS fifo queue
*/

#  Filename    : aws/modules/sqs/example/create_fifo_queue/main.tf
#  Date        : 02 Febraury 2022
#  Author      : TCS
#  Description : This module creates SQS fifo queue
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.Optional_tags
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
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
  Order              = local.Order
}

module "sqs_deadletter_queue" {
  source = "../../"

  sqs_name   = var.sqs_deadletter_name
  kms_key_id = null # replace with module.kms_key.key_arn, after key creation

  tags = merge(module.tags.tags, local.optional_tags)

}

module "sqs" {
  source = "../../"

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
  tags = merge(module.tags.tags, local.optional_tags)
}

