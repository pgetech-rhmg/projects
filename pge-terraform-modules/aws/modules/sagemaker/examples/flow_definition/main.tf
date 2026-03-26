/*
 * # AWS Sagemaker flow definition example
*/
#
#  Filename    : aws/modules/sagemaker/examples/flow_definition/main.tf
#  Date        : 20 September 2022
#  Author      : TCS
#  Description : The terraform usage example creates flow definition

locals {
  name                  = "${var.name}-${random_string.name.result}"
  human_task_ui_content = file("${path.module}/${var.content}")
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

#The resource random_string generates a random permutation of alphanumeric characters and optionally speci
resource "random_string" "name" {
  length  = 4
  upper   = false
  special = false
}

module "flow_definition" {
  source = "../../modules/flow_definition"

  flow_definition_name                  = local.name
  iam_role_arn                          = module.flow_definition_role.arn
  human_task_ui_arn                     = module.human_task_ui.arn
  task_availability_lifetime_in_seconds = var.task_availability_lifetime_in_seconds
  task_count                            = var.task_count
  task_keywords                         = var.task_keywords
  task_time_limit_in_seconds            = var.task_time_limit_in_seconds
  task_title                            = var.task_title
  workteam_arn                          = var.workteam_arn
  human_loop_activation_config          = var.human_loop_activation_config
  human_loop_request_source             = var.human_loop_request_source
  s3_output_path                        = module.s3.s3.bucket
  kms_key_id                            = null # replace with module.kms_key.key_arn, after key creation 
  tags                                  = merge(module.tags.tags, var.optional_tags)
}

# This will pull the human task ui module
module "human_task_ui" {
  source = "../../modules/human_task_ui"

  human_task_ui_name = local.name
  content            = local.human_task_ui_content
  tags               = merge(module.tags.tags, var.optional_tags)
}

#An IAM role, used by sagemaker flow_definition
module "flow_definition_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  policy_arns = var.policy_arns
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, var.optional_tags)
}

#s3 bucket 
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name   = local.name
  force_destroy = true
  kms_key_arn   = module.kms_key.key_arn
  tags          = merge(module.tags.tags, var.optional_tags)
}

module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.2"

  name     = local.name
  aws_role = var.aws_role
  kms_role = var.kms_role
  policy   = file("${path.module}/kms_policy.json")
  tags     = merge(module.tags.tags, var.optional_tags)
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "kms_key" {
# source  = "app.terraform.io/pgetech/kms/aws"
# version = "0.1."

#  name     = "cmk-${local.name}"
# policy   = file("${path.module}/kms_policy.json")
#  kms_role = var.kms_role
#  aws_role = var.aws_role
#  tags     = merge(module.tags.tags, var.optional_tags)
#}