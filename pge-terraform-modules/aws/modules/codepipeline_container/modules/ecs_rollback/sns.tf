#
# Filename    : modules/codepipeline/modules/container_codepipeline_rollback/sns.tf
# Date        : 12-19-2022
# Author      : Tekyantra
# Description : SNS creation for Container codepipeline 
#
###########################################################
# Create SNS  for code pipeline build failures and manaula approvals
###########################################################

locals {
  principal_orgid = "o-7vgpdbu22o"
}

module "codepipeline_internal_codestar_notifications" {
  source                            = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/codestar_notifications"
  version                           = "0.1.0"
  codepipeline_name                 = var.codepipeline_name
  codestar_sns_kms_key_arn          = var.encryption_key_id
  tags                              = var.tags
  endpoint_email                    = var.endpoint_email
  subnet_ids                        = var.subnet_ids
  codestar_lambda_encryption_key_id = var.encryption_key_id
  sg_description_codestar           = "${var.codepipeline_name} security group"
  vpc_id                            = var.vpc_id
  cidr_egress_rules_SNS_codestar    = var.cidr_egress_rules_SNS_codestar
  codepipeline_arn                  = aws_codepipeline.codepipeline.arn
  codestar_environment              = data.aws_ssm_parameter.environment.value

}

#SNS for manual approval
module "sns_topic_manual_approval" {
  source                = "app.terraform.io/pgetech/sns/aws"
  version               = "0.0.15"
  snstopic_name         = "manual-approval-notification-${var.codepipeline_name}"
  snstopic_display_name = "manual-approval-notification-${var.codepipeline_name}"
  kms_key_id            = var.encryption_key_id
  policy = templatefile(
    "${path.module}/../internal/codebuild_iam_policies/sns_policy.json",
    {
      snstopic_name   = "manual-approval-notification-${var.codepipeline_name}"
      account_num     = data.aws_caller_identity.current.account_id
      aws_region      = data.aws_region.current.name
      principal_orgid = local.principal_orgid
  })
  tags = merge(var.tags, { pge_team = local.namespace })
}

module "sns_topic_subscription" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.0"

  count     = length(var.endpoint_email)
  endpoint  = var.endpoint_email
  protocol  = "email"
  topic_arn = module.sns_topic_manual_approval.sns_topic_arn
}
