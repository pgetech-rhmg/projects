/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM State Manager Association in AWS
*/

# Filename    : aws/modules/ssm/examples/state-manager-association/main.tf
# Date        : 01 August 2023
# Author      : PGE
# Description : Provides an SSM State manager association that helps manage the asscoation of traget accounts instances. 

locals {
  optional_tags = var.optional_tags
  aws_role      = var.aws_role
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

#########################################
# KMS key for the S3 bucket
#########################################

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = var.kms_key
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = module.lambda_iam_role.name
# }

#####################################################
# Creating SSM state-assocition 
#####################################################

#####################################################
# Creating SSM state-assocition 
#####################################################

module "ssm_association" {
  source                            = "../../modules/state-manager-association"
  name                              = var.ssm_association_name
  ssm_document_name                 = module.ssm-document.id
  approved_patches_compliance_level = "CRITICAL"
  s3_bucket_name                    = module.statemanager-s3.id
  s3_key_prefix                     = var.output_s3_key_prefix
  schedule_expression               = var.schedule_expression

  automation_target_parameter_name = "InstanceId"
  document_parameters = {
    AutomationAssumeRole = module.aws_document_iam_role.arn
  }

  association_targets = [{
    key    = "InstanceIds"
    values = ["*"]
  }]

  max_concurrency             = var.max_concurrency
  apply_only_at_cron_interval = var.apply_only_at_cron_interval

  tags = merge(module.tags.tags, local.optional_tags)

}

#####################################################
# Creating SSM-Document in JSON Format 
#####################################################

module "ssm-document" {
  source = "../../modules/ssm-document"

  ssm_document_name   = var.ssm_document_name
  ssm_document_type   = var.ssm_document_type
  ssm_document_format = var.ssm_document_format
  ssm_document_content = templatefile("${path.module}/ssm-document.json",
    {
      account_num              = var.account_num,
      lambda_iam_role_arn      = var.document_iam_name,
      document_s3_bucket       = var.document_bucket_name,
      document_lambda_function = module.lambda_function.lambda_arn

    }

  )

  depends_on = [
    module.aws_document_iam_role,
    module.document_s3,
    module.lambda_function
  ]
  tags = merge(module.tags.tags, local.optional_tags)
}

#########################################
# KMS encrypted S3 bucket 
#########################################
module "document_s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.document_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy = templatefile("${path.module}/s3_bucket_document_policy.json",
    {

      aws_role    = local.aws_role,
      account_num = var.account_num,
      bucket_name = var.document_bucket_name,
      aws_org_id  = var.aws_org_id
  })
  tags = module.tags.tags
}

resource "aws_s3_object" "object" {
  bucket = module.document_s3.id
  key    = "baseline_overrides.json"
  tags   = merge(module.tags.tags, local.optional_tags)
}


#########################################
# S3 bucket for 
#########################################
module "statemanager-s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.statemanager_s3_bucket
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy = templatefile("${path.module}/s3_bucket_statemanger_policy.json",
    { aws_role    = local.aws_role,
      account_num = var.account_num,
  bucket_name = var.statemanager_s3_bucket })
  tags = module.tags.tags
}


#########################################
# IAM role for SSM document
#########################################

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:*"]
    resources = ["*"]
  }
}


module "aws_document_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = var.document_iam_name
  aws_service   = var.document_iam_aws_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [data.aws_iam_policy_document.iam_policy_document.json]
}

#########################################
# IAM role for SNS
#########################################

data "aws_iam_policy_document" "inline_policy_sns" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

module "aws_sns_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = var.sns_iam_name
  aws_service   = var.sns_iam_aws_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [data.aws_iam_policy_document.inline_policy_sns.json]
}

module "sns_topic" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.1"

  snstopic_name         = var.snstopic_name
  snstopic_display_name = var.snstopic_display_name
  kms_key_id            = null # replace with module.kms_key.key_arn, after key creation
  tags                  = merge(module.tags.tags, local.optional_tags)
}

module "sns_topic_subscription" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.1"

  endpoint  = var.endpoint
  protocol  = var.protocol
  topic_arn = module.sns_topic.sns_topic_arn
}


