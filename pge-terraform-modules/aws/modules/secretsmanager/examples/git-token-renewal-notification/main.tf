/*
 * #### A Reference to rotate GitHub Personal Access Token/PAT 
 *
 * **What this code does:** 
 * - Updates provided GitHub PAT value to Secrets Manager. 
 * - Monitor's last updated date of token in secrets manager.
 * - Sends an email notification to regenerate new PAT before 90 days as per complaince requirements.
 *
 * **PreRequisites:** 
 * - Create GitHub token manually by following instructions here - [GitHub - Create Personal Access Token](https://wiki.comp.pge.com/display/CCE/GitHub+-+Create+Personal+Access+Token)
 * - Onboard to terraform Workspace if not already - [OnBoarding Terraform Cloud](https://wiki.comp.pge.com/display/CCE/OnBoarding+Terraform+Cloud)
 * 
 * **High Level Steps Included on this Automation:**
 * - Creation of Secrets manager credentials with provided secrets manager name and GitHub PAT by following PG&E standards such as encrypting credentials with custom KMS key and adding required tags.
 * - Creation of AWS Lambda function to check last update date of SecretManager value and sending notification email if value hasn't been updated in last 83 days. This function has been written in Python3 language.  
 * - Creation of CloudWatch Event which runs on a cron expression (for every 2 days) and runs above lambda function to check last update date of secrets manager and notify if secret hasn't been updated in last 83 days.
 * - Creation of KMS key and IAM polices as required to encrypt and access lambda & secrets manager.
 * - This automation supports storing credentials as either in PlainText or Key/Value pair.
 *
 * For Detailed instrcutions, refer following [wiki](https://wiki.comp.pge.com/display/CCE/GitHub+PAT+upload+to+secrets+manager+and+automatic+notification+of+renewal+reminder)
*/
#
#  Filename    : git-token-renewal-notification/main.tf
#  Date        : 10 Jan 2024
#  Author      : Mounika Kota
#  Description : AWS Lambda function with Environment Variables to notify user to renew github token for every 90 days


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  secret_string      = var.store_as_key_value ? jsonencode(var.key_value_secret) : var.plaintext_secret
}

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

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc_id_name
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.subnet_id1_name
}

data "aws_caller_identity" "current" {}

#Creates new secrets manager credential and uplaods secret with automatic rotation enabled
module "secretsmanager" {
  source                     = "../../"
  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  # kms_key_id                 = module.kms_key.key_arn
  recovery_window_in_days = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string           = local.secret_string         #jsonencode(var.secret_string) for key value, var.secret_string for plaintext
  secret_version_enabled  = var.secret_version_enabled
  rotation_enabled        = false #default to false as we cannot update git token automatically.
  custom_policy           = templatefile("${path.module}/custom_policy_sm.json", { lambda_iam_role = module.aws_lambda_iam_role.arn, aws_region = var.aws_region, account_num = data.aws_caller_identity.current.account_id, secretsmanager_name = var.secretsmanager_name })

  tags = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create Lambda Function
#########################################
#lambda function which calls Secrets manager api to check last modified date and send notification if token hasn't been modified in last 83 days
module "lambda_function" {
  source                      = "app.terraform.io/pgetech/lambda/aws"
  version                     = "0.1.3"
  function_name               = var.function_name
  role                        = module.aws_lambda_iam_role.arn
  description                 = var.description
  runtime                     = var.runtime
  lambda_permission_action    = "lambda:InvokeFunction"
  lambda_permission_principal = "secretsmanager.amazonaws.com"
  timeout                     = var.lambda_timeout
  publish                     = var.publish
  source_code = {
    source_dir = "${path.module}/${var.source_dir}"
  }
  tags                          = merge(module.tags.tags, local.optional_tags)
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  handler                       = var.handler
  # Provide a valid value for kms_key_arn.Invalid value gives validation error.
  environment_variables = {
    variables = {
      git_secretsmanager_name = var.secretsmanager_name,
      sns_topic_arn           = module.sns_topic.sns_topic_arn
    }
    # kms_key_arn = module.kms_key.key_arn
    kms_key_arn = null
  }
}

#cloud watch event rule to monitor secrets manager last updated date
resource "aws_cloudwatch_event_rule" "git_lambda_cron_rule" {
  name                = var.cloudwatch_event_rule_name
  description         = var.cloudwatch_event_rule_description
  tags                = merge(module.tags.tags, local.optional_tags)
  schedule_expression = var.cron_schedule_expression
  # schedule_expression = "cron(00 22 * * ? *)"

}

resource "aws_cloudwatch_event_target" "git_lambda_target" {
  rule      = aws_cloudwatch_event_rule.git_lambda_cron_rule.name
  target_id = "git_lambda_target"
  arn       = module.lambda_function.lambda_arn

}

resource "aws_lambda_permission" "git_cloudwatch" {
  statement_id  = "AllowExcecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.git_lambda_cron_rule.arn
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"

#   name        = var.kms_name
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
#   policy      = templatefile("${path.module}/custom_policy_kms.json", { lambda_iam_role = module.aws_lambda_iam_role.arn })
# }


module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.lambda_sg_name
  description = var.lambda_sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  # cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules = var.lambda_cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid = "1"
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]
    resources = [
      "*"
    ]
  }
}

module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.1"

  name        = "kms-policy-git-token-notification"
  path        = "/"
  description = "Kms encrypt decrypt policy for git token renewal lambda"
  policy      = [data.aws_iam_policy_document.kms_policy.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)
  policy_arns = concat(var.iam_policy_arns, [module.iam_policy.arn])
}

#########################################
# Create SNS topic
#########################################
module "sns_topic" {
  source                = "app.terraform.io/pgetech/sns/aws"
  version               = "0.1.1"
  snstopic_name         = var.snstopic_name
  snstopic_display_name = var.snstopic_display_name
  # kms_master_key_id     = module.kms_key.key_arn
  tags = merge(module.tags.tags, local.optional_tags)
}

module "sns_topic_subscription" {
  source    = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version   = "0.1.1"
  endpoint  = var.endpoint
  protocol  = var.protocol
  topic_arn = module.sns_topic.sns_topic_arn
}
