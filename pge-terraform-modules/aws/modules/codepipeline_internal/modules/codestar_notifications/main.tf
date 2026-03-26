# Filename    : modules/codepipeline/modules/codestar_notifications/main.tf
# Date        : 1-13-2023
# Author      : Tekyantra
# Description : SNS creation for Container codepipeline 
# Codestar notification has been added to all the existing codepipeine modules
###########################################################
# Create SNS  for code pipeline build failures 
###########################################################

#########################################
# Create SNS topics for code pipeline
#########################################

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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.codestar_sns_kms_key_arn == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#SNS FOR CODEPIPELINE TRIGGER LAMBDA
resource "aws_sns_topic" "sns-topic-trigger-lambda" {
  name              = "codestar-notifications-codepipeline-${var.codepipeline_name}" #name can be shinrk
  display_name      = "codestar-notifications-codepipeline-${var.codepipeline_name}"
  kms_master_key_id = var.codestar_sns_kms_key_arn
  tags              = local.module_tags
}

resource "aws_sns_topic_policy" "sns_trigger_lambda" {
  arn = resource.aws_sns_topic.sns-topic-trigger-lambda.arn
  policy = templatefile(
    "${path.module}/codestar_iam_policies/sns_access_policy.json",
    {
      snstopic_name   = "codestar-notifications-codepipeline-${var.codepipeline_name}"
      account_num     = data.aws_caller_identity.current.account_id
      aws_region      = data.aws_region.current.name
      principal_orgid = local.principal_orgid
  })
}

resource "aws_sns_topic_subscription" "sns_topic_subscription_trigger_lambda" {
  endpoint               = module.lambda_function.lambda_arn
  protocol               = "lambda"
  topic_arn              = resource.aws_sns_topic.sns-topic-trigger-lambda.arn
  endpoint_auto_confirms = true
}

#SNS FOR LAMBDA TRIGGER EMAIL
resource "aws_sns_topic" "sns-topic-trigger-email" {
  name              = "${var.codepipeline_name}-codestar_notifications"
  display_name      = "${var.codepipeline_name}-codestar_notifications"
  kms_master_key_id = var.codestar_sns_kms_key_arn
  tags              = local.module_tags
}

resource "aws_sns_topic_policy" "sns_trigger_email" {
  arn = resource.aws_sns_topic.sns-topic-trigger-email.arn
  policy = templatefile(
    "${path.module}/codestar_iam_policies/sns_lambda_policy.json",
    {
      snstopic_name   = "${var.codepipeline_name}-codestar_notifications"
      account_num     = data.aws_caller_identity.current.account_id
      aws_region      = data.aws_region.current.name
      principal_orgid = local.principal_orgid
  })
}

resource "aws_sns_topic_subscription" "sns_topic_subscription_trigger_email" {
  for_each               = toset(var.endpoint_email)
  endpoint               = each.value
  protocol               = "email"
  topic_arn              = resource.aws_sns_topic.sns-topic-trigger-email.arn
  endpoint_auto_confirms = true
}

#Codepipeline SNS TRIGGER NOTIFICATION
resource "aws_codestarnotifications_notification_rule" "build_notify" {
  depends_on = [
    module.lambda_function
  ]
  detail_type    = "FULL"
  event_type_ids = ["codepipeline-pipeline-pipeline-execution-failed", "codepipeline-pipeline-pipeline-execution-succeeded"]
  name           = "codepipeline-sns-trigger-lambda-${var.codepipeline_name}"
  resource       = var.codepipeline_arn
  target {
    address = resource.aws_sns_topic.sns-topic-trigger-lambda.arn
  }
  tags = local.module_tags
}
