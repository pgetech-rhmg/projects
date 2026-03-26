/*
* # AWS ASG with launch template usage example
* Terraform module which creates SAF2.0 ASG with launch template in AWS.
*/
#
# Filename    : modules/asg/examples/asg_with_launch_template/main.tf
# Date        : 7 March 2022
# Author      : TCS
# Description : The Terraform usage example creates aws asg with launch_template


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
  user_data          = <<-EOT
    #!/bin/bash
    yum update -y
    amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
    yum install -y httpd mariadb-server
    systemctl start httpd
    systemctl enable httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user:apache /var/www
    chmod 2775 /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod 0664 {} \;
    echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
  EOT
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"

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

module "asg_with_launch_template" {
  source               = "../../"
  asg_name             = var.asg_name
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
  asg_desired_capacity = var.asg_desired_capacity
  asg_force_delete     = var.asg_force_delete

  asg_vpc_zone_identifier = [data.aws_ssm_parameter.subnet_id1.value]
  autoscaling_policy_name = var.autoscaling_policy_name
  policy_type             = var.policy_type
  scaling_adjustment      = var.scaling_adjustment
  adjustment_type         = var.adjustment_type
  cooldown                = var.cooldown

  tags = merge(module.tags.tags, local.optional_tags)

  # Launch template
  create_launch_template  = var.create_launch_template
  launch_template_name    = var.launch_template_name
  image_id                = data.aws_ssm_parameter.golden_ami.value
  instance_type           = var.instance_type
  launch_template_version = var.launch_template_version # change it to default/latest version as needed
  user_data               = base64encode(local.user_data)
  instance_name           = var.instance_name
  security_groups         = [module.security_group.sg_id]
  block_device_mappings   = var.block_device_mappings

}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/2/privatesubnet1/id"
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "golden_ami" {
  name = var.parameter_golden_ami_name
}

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
  protocol  = var.protocol
  topic_arn = module.sns_topic.sns_topic_arn
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


resource "aws_autoscaling_schedule" "asg_schedule" {
  scheduled_action_name  = var.scheduled_action_name
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  start_time             = var.start_time
  end_time               = var.end_time
  autoscaling_group_name = module.asg_with_launch_template.name
}

resource "aws_autoscaling_lifecycle_hook" "asg_lifecycle_hook" {
  name                    = var.lifecycle_hook_name
  autoscaling_group_name  = module.asg_with_launch_template.name
  default_result          = var.default_result
  heartbeat_timeout       = var.heartbeat_timeout
  lifecycle_transition    = var.lifecycle_transition
  notification_metadata   = var.notification_metadata
  notification_target_arn = module.sns_topic.sns_topic_arn
  role_arn                = module.iam_role.arn
}


module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
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