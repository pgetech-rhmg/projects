/*
* # AWS ASG with mixed instances policy usage example
* Terraform module which creates SAF2.0 ASG with mixed instances policy in AWS.
*/
#
# Filename    : modules/asg/examples/asg_with_mixed_instances_policy/main.tf
# Date        : 7 March 2022
# Author      : TCS
# Description : The Terraform usage example creates aws asg with mixed instances policy


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
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = var.kms_name
#   description = var.kms_description
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   policy = templatefile("${path.module}/${var.template_file_name}",
#     {
#       account_num = data.aws_caller_identity.current.account_id
#       iam_name    = var.iam_name
#   })
#   kms_role = local.kms_role
# }



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


module "aws_autoscaling_group" {
  source                                   = "../../modules/asg_with_mixed_instances_policy"
  asg_name                                 = var.asg_name
  asg_max_size                             = var.asg_max_size
  asg_min_size                             = var.asg_min_size
  asg_desired_capacity                     = var.asg_desired_capacity
  asg_force_delete                         = var.asg_force_delete
  on_demand_allocation_strategy            = var.on_demand_allocation_strategy
  on_demand_base_capacity                  = var.on_demand_base_capacity
  on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
  spot_allocation_strategy                 = var.spot_allocation_strategy
  spot_instance_pools                      = var.spot_instance_pools
  spot_max_price                           = var.spot_max_price

  launch_template_specification_id      = var.launch_template_specification_id
  launch_template_specification_version = var.launch_template_specification_version

  instance_type     = var.instance_type
  weighted_capacity = var.weighted_capacity

  autoscaling_policy_name = var.autoscaling_policy_name
  policy_type             = var.policy_type
  scaling_adjustment      = var.scaling_adjustment
  adjustment_type         = var.adjustment_type
  cooldown                = var.cooldown
  asg_vpc_zone_identifier = [data.aws_ssm_parameter.subnet_id.value]

  tags = merge(module.tags.tags, local.optional_tags)
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id" {
  name = "/vpc/2/privatesubnet1/id"
}
data "aws_caller_identity" "current" {}

module "sns_topic" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.1"

  snstopic_name         = var.snstopic_name
  snstopic_display_name = var.snstopic_display_name
  kms_key_id            = null # replace with module.kms_key.key_arn, after key creation
  policy                = data.aws_iam_policy_document.sns_custom_policy.json
  tags                  = merge(module.tags.tags, local.optional_tags)
}

module "sns_topic_subscription" {
  source  = "app.terraform.io/pgetech/sns/aws//modules/sns_subscription"
  version = "0.1.1"

  endpoint  = var.endpoint
  protocol  = var.sns_protocol
  topic_arn = module.sns_topic.sns_topic_arn
}

resource "aws_autoscaling_schedule" "asg_schedule" {
  scheduled_action_name  = var.scheduled_action_name
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  start_time             = var.start_time
  end_time               = var.end_time
  autoscaling_group_name = module.aws_autoscaling_group.name
}

resource "aws_autoscaling_lifecycle_hook" "asg_lifecycle_hook" {
  name                    = var.lifecycle_hook_name
  autoscaling_group_name  = module.aws_autoscaling_group.name
  default_result          = var.default_result
  heartbeat_timeout       = var.heartbeat_timeout
  lifecycle_transition    = var.lifecycle_transition
  notification_metadata   = var.notification_metadata
  notification_target_arn = module.sns_topic.sns_topic_arn
  role_arn                = module.iam_role.arn
}

data "aws_iam_policy_document" "sns_custom_policy" {
  source_policy_documents = [
    templatefile("${path.module}/test_policy.json",
      {
        account_num   = data.aws_caller_identity.current.account_id
        aws_region    = var.aws_region
        snstopic_name = var.snstopic_name
    }, )
  ]
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = var.target_group_name
  port     = var.port
  protocol = var.protocol
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_lb_target_group" "lb_target_group_1" {
  name     = var.lb_target_group_name
  port     = var.lb_port
  protocol = var.lb_protocol
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
}

module "iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
}


