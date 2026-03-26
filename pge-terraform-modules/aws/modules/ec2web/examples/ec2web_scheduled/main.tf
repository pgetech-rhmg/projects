/*
 * # AWS EC2 module example
*/
#  Filename    : aws/modules/ec2web/examples/http_https_app/main.tf
#  Date        : 01 August 2024
#  Author      : Pallavi Das (p4dn@pge.com)
#  Description : Creates an ASG with Automatic Scaling Schedules, with LT using a custom IAM role, behind an ALB, and security groups

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
  user_data          = <<-EOT
    #!/bin/bash
    yum update -y
    nohup python3 -m http.server 80 > /var/log/http_server.log 2>&1 &
  EOT
}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/2/privatesubnet1/id"
}

data "aws_ssm_parameter" "subnet_id2" {
  name = "/vpc/2/privatesubnet2/id"
}

data "aws_ssm_parameter" "golden_ami" {
  name = "/ami/linux/golden"
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.0"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = module.tags.tags
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

module "iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.iam_name
  aws_service = var.iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns   = var.iam_policy_arns
  inline_policy = [file("${path.module}/ec2_iam_policy.json")]
}

resource "aws_iam_instance_profile" "ec2_instance_role" {
  role = module.iam_role.name
  tags = merge(module.tags.tags, local.optional_tags)
}

module "alb_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  tags = module.tags.tags

  name               = var.alb_security_groups_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.alb_cidr_ingress_rules
  cidr_egress_rules  = var.alb_cidr_egress_rules
}

module "ec2_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  tags = module.tags.tags

  name               = var.ec2_security_groups_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.ec2_cidr_ingress_rules
  cidr_egress_rules  = var.ec2_cidr_egress_rules
}

module "ec2-asg-alb" {
  source = "../../"

  tags = merge(module.tags.tags, local.optional_tags)

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }

  vpc_id                  = data.aws_ssm_parameter.vpc_id.value
  alb_name                = var.alb_name
  alb_subnets             = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  asg_name                = var.asg_name
  asg_vpc_zone_identifier = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  autoscaling_policy_name = var.autoscaling_policy_name
  scaling_adjustment      = var.scaling_adjustment
  adjustment_type         = var.adjustment_type
  iam_instance_profile    = resource.aws_iam_instance_profile.ec2_instance_role.name
  launch_template_name    = var.launch_template_name
  image_id                = data.aws_ssm_parameter.golden_ami.value
  instance_type           = var.instance_type
  disable_api_termination = "true"
  disable_api_stop        = "false"
  block_device_mappings   = var.block_device_mappings
  custom_domain_name      = var.custom_domain_name
  ec2_security_groups     = [module.ec2_security_group.sg_id]
  alb_security_groups     = [module.alb_security_group.sg_id]
  alb_log_bucket_name     = var.alb_log_bucket_name

  lb_listener_http = var.lb_listener_http

  lb_listener_https = [
    {
      port              = var.https_port
      protocol          = var.https_protocol
      ssl_policy        = var.https_ssl_policy
      certificate_arn   = module.ec2-asg-alb.acm_arn
      target_group_name = var.alb_target_group_name
      type              = var.https_type
    }
  ]

  user_data = local.user_data
  lb_target_group = [
    {
      name         = var.alb_target_group_name
      target_type  = var.target_type
      port         = var.target_port
      protocol     = var.target_protocol
      health_check = var.lb_health_check
      stickiness   = var.lb_stickiness
    }
  ]
}

# Schedule start and stop times MUST be unique
module "scheduler" {
  source = "../../modules/ec2web_scheduled"

  asg_name  = module.ec2-asg-alb.asg_name # Must be taken from existing ASG
  schedules = var.schedules
}
