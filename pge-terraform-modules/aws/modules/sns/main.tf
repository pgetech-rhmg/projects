/*
 * # AWS SNS module
 * Terraform module which creates SAF2.0 SNS in AWS
*/

#
#  Filename    : modules/sns/main.tf
#  Date        : 28 December 2021
#  Author      : TCS
#  Description : SNS terraform module creates a sns topic
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
  }
}



locals {
  principal_orgid = "o-7vgpdbu22o"
  namespace       = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_sns_topic" "sns-topic" {

  name        = var.snstopic_name
  name_prefix = var.snstopic_name_prefix

  display_name    = var.snstopic_display_name
  delivery_policy = var.snstopic_delivery_policy

  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn

  http_success_feedback_role_arn    = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn    = var.http_failure_feedback_role_arn

  lambda_success_feedback_role_arn    = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn    = var.lambda_failure_feedback_role_arn

  sqs_success_feedback_role_arn    = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn    = var.sqs_failure_feedback_role_arn

  firehose_success_feedback_role_arn    = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn    = var.firehose_failure_feedback_role_arn

  kms_master_key_id           = var.kms_key_id
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication

  tags = local.module_tags

}

data "aws_caller_identity" "current" {}


data "aws_region" "current" {}


#Combines the user_defined_policy with the pge_compliance
data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    templatefile("${path.module}/sns_policy.json",
      {
        snstopic_name   = var.snstopic_name
        account_num     = data.aws_caller_identity.current.account_id
        aws_region      = data.aws_region.current.name
        principal_orgid = local.principal_orgid
    }, ),
    var.policy
  ]
}

resource "aws_sns_topic_policy" "sns" {
  arn    = aws_sns_topic.sns-topic.arn
  policy = data.aws_iam_policy_document.combined.json
}