/*
 * # AWS Lambda trigger module 
 * Composite module using SAF2.0 CCOE modules
*/
#
#  Filename    : aws/modules/mrad-lambda-triggers/modules/sqs/main.tf 
#  Date        : 02 June 2023
#  Author      : MRAD (mrad@pge.com)
#  Description : LAMBDA trigger terraform module creates a Lambda trigger using a SQS queue
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-ecs/aws"
  version     = "~> 1.0" 
  # only required for local dev since both values are predefined in TFC
  account_num = var.account_num
  aws_role    = var.aws_role
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/*
  --- Lambda Trigger(s) ---
*/

module "sqs_queue" {
  source  = "app.terraform.io/pgetech/sqs/aws//modules/sqs_standard_queue"
  version = "0.0.11"

  sqs_name                   = "${var.lambda_name}-Queue"
  policy                     = data.aws_iam_policy_document.sqs_policy_document.json
  message_retention_seconds  = 1209600 // 14 days
  visibility_timeout_seconds = 180

  tags = module.mrad-common.tags
}

module "lambda_event_source_mapping_sqs" {
  source  = "app.terraform.io/pgetech/lambda/aws//modules/event_source_mapping_sqs"
  version = "0.0.15"

  event_source_arn = module.sqs_queue.arn
  function_name    = var.lambda_name
  batch_size       = 1
}

module "sns_subscription" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.0.15"

  endpoint  = [module.sqs_queue.arn]
  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
}

moved {
  from = module.sns_subscription.aws_sns_topic_subscription.sns_topic_subscription
  to   = module.sns_subscription.aws_sns_topic_subscription.sns_topic_subscription[0]
}

/*
  --- SQS Policy ---
*/

data "aws_iam_policy_document" "sqs_policy_document" {
  statement {
    actions   = ["sqs:*"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.lambda_name}-Queue"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_topic_arn, "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.lambda_name}"]
    }
  }
}
