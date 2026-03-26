/*
 * # AWS EC2 module example
*/
#  Filename    : aws/modules/ec2web/examples/http_https_app/main.tf
#  Date        : 02 July 2024
#  Author      : Eric Barnard (e6bo@pge.com)
#  Description : Creates an ASG with LT using a custom IAM role, behind an ALB, and security groups

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
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
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
  version = "0.1.0"

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

module "ec2-asg-alb" {
  source = "../../"

  tags = merge(module.tags.tags, local.optional_tags)

  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  allow_overwrite         = var.allow_overwrite
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
  block_device_mappings = [{
    device_name = "/dev/xvda"

    ebs = {
      volume_size = 8
    }
  }]
  custom_domain_name        = var.custom_domain_name
  subject_alternative_names = var.subject_alternative_names
  ec2_security_groups       = [module.ec2_security_group.sg_id]
  alb_security_groups       = [module.alb_security_group.sg_id]
  alb_log_bucket_name       = var.alb_log_bucket_name

  lb_listener_http = [
    {
      port     = 80
      protocol = "HTTP"
      type     = "redirect"
      redirect = {
        protocol    = "HTTPS"
        status_code = "HTTP_301"
        port        = 443
      }
    }
  ]
  lb_listener_https = [
    {
      port              = 443
      protocol          = "HTTPS"
      ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      certificate_arn   = module.ec2-asg-alb.acm_arn
      target_group_name = var.alb_target_group_name
      type              = "forward"
    }
  ]

  user_data = local.user_data
  lb_target_group = [
    {
      name        = var.alb_target_group_name
      target_type = "instance"
      port        = 80
      protocol    = "HTTP"
      health_check = [{
        enabled             = true
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 10
        unhealthy_threshold = 5
        healthy_threshold   = 4
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }]
    }
  ]
}

module "alb_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  tags = module.tags.tags

  name               = var.alb_security_groups_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.alb_cidr_ingress_rules
  cidr_egress_rules  = var.alb_cidr_egress_rules
}

module "ec2_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  tags = module.tags.tags

  name               = var.ec2_security_groups_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.ec2_cidr_ingress_rules
  cidr_egress_rules  = var.ec2_cidr_egress_rules
}
