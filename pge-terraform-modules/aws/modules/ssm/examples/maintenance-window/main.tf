/*
 * # AWS SSM module
 * Terraform module which creates SAF2.0 SSM Maintenance Window resource in AWS
*/

# Filename    : aws/modules/ssm/examples/patch-manager/main.tf
# Date        : 13 April 2023
# Author      : PGE
# Description : Provides an SSM Maintenance Window resource that helps define a schedule. Different types of tasks are shown in the example. Comment out the code as needed. 
#

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


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_key
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = var.kms_role
# }



####################################################
# Creating Maintenance-Window and optional targets
####################################################

module "maintenance-window" {
  source = "../../modules/maintenance-window"

  maintenance_window_name     = var.scan_maintenance_window_name
  maintenance_window_schedule = var.scan_maintenance_window_schedule
  maintenance_window_duration = var.scan_maintenance_window_duration
  maintenance_window_cutoff   = var.scan_maintenance_window_cutoff

  maintenance_window_target_resource_type = var.scan_maintenance_window_target_resource_type
  maintenance_windows_targets             = var.scan_maintenance_windows_targets

  tags = merge(module.tags.tags, local.optional_tags)
}

############################################
# Maintenance-Window Task - Run Command 
############################################

module "maintenance-window-tasks-run-command" {
  source = "../../modules/maintenance-window-tasks-run-command"

  maintenance_window_task_name            = var.scan_maintenance_window_task_name
  maintenance_window_id                   = module.maintenance-window.window_id
  maintenance_window_task_type            = var.scan_maintenance_window_task_type
  maintenance_window_task_arn             = var.scan_maintenance_window_task_arn
  maintenance_window_task_max_concurrency = var.scan_maintenance_window_task_max_concurrency
  maintenance_window_task_max_errors      = var.scan_maintenance_window_task_max_errors

  maintenance_windows_targets = [
    {
      key    = var.scan_task_target_key
      values = module.maintenance-window.window_target_id
    }
  ]

  maintenance_windows_run_command = [
    {
      output_s3_bucket     = module.s3.id
      output_s3_key_prefix = var.output_s3_key_prefix

      ## Comment out the below 2 fields if SNS notification is not required.
      sns_notification_role_arn = module.aws_sns_iam_role.arn
      task_run_command_notification = [
        {
          notification_arn    = module.sns_topic.sns_topic_arn
          notification_events = ["All"]
          notification_type   = "Command"
        }
      ]

      task_run_command_parameters = var.scan_task_run_command_parameters

      task_cloudwatch_config = [
        {
          cloudwatch_output_enabled = var.cloudwatch_output_enabled
        }
      ]
    }
  ]
}

############################################
# Maintenance-Window Task - Automation 
############################################

module "maintenance-window-tasks-automation" {
  source = "../../modules/maintenance-window-tasks-automation"

  maintenance_window_task_name            = var.automation_maintenance_window_task_name
  maintenance_window_id                   = module.maintenance-window.window_id
  maintenance_window_task_type            = var.automation_maintenance_window_task_type
  maintenance_window_task_arn             = var.automation_maintenance_window_task_arn
  maintenance_window_task_priority        = var.automation_maintenance_window_task_priority
  maintenance_window_task_max_concurrency = var.automation_maintenance_window_task_max_concurrency
  maintenance_window_task_max_errors      = var.automation_maintenance_window_task_max_errors

  maintenance_windows_targets = [
    {
      key    = var.automation_task_target_key
      values = module.maintenance-window.window_target_id
    }
  ]

  ### Automation Task Params ####
  task_invocation_automation_parameters = var.automation_task_invocation_automation_parameters
}

############################################
# Maintenance-Window Task - Lambda 
############################################

module "maintenance-window-tasks-lambda" {
  source = "../../modules/maintenance-window-tasks-lambda"

  maintenance_window_task_name     = var.lambda_maintenance_window_task_name
  maintenance_window_id            = module.maintenance-window.window_id
  maintenance_window_task_type     = var.lambda_maintenance_window_task_type
  maintenance_window_task_arn      = var.lambda_maintenance_window_task_arn
  maintenance_window_task_priority = var.lambda_maintenance_window_task_priority
}


#########################################
# KMS encrypted S3 bucket 
#########################################
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = var.bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = templatefile("${path.module}/s3_bucket_user_policy.json", { aws_role = local.aws_role, account_num = var.account_num, bucket_name = var.bucket_name })
  tags        = module.tags.tags
}

resource "aws_s3_object" "object" {
  bucket = module.s3.id
  key    = var.output_s3_key_prefix
  tags   = merge(module.tags.tags, local.optional_tags)
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

######################################################
