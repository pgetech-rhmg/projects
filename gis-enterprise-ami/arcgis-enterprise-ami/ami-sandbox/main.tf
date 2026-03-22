
locals {
  AppID              = var.appid
  Environment        = var.environment
  DataClassification = var.dataclassification
  CRIS               = var.cris
  Notify             = var.notify
  Owner              = var.owner
  Compliance         = var.compliance
  optional_tags      = var.optional_tags
  Order              = var.order
  AvailabilityZoneA  = var.availabilityzonea
  AvailabilityZoneB  = var.availabilityzoneb
  AvailabilityZoneC  = var.availabilityzonec
  user_data          = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  EOT
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2" #"Check Terraform Registry for latest module version"

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
  name = "/vpc/privatesubnet1/id"
}

data "aws_ssm_parameter" "subnet_id2" {
  name = "/vpc/privatesubnet2/id"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "subnet_id3" {
  name = "/vpc/privatesubnet3/id"
}

data "aws_ssm_parameter" "windows_ad_golden" {
  name = "/ec2/windows/security_group_id/ad"
}

data "aws_ssm_parameter" "windows_bmc_proxy_golden" {
  name = "/ec2/windows/security_group_id/bmc_proxy"
}

data "aws_ssm_parameter" "windows_bmc_scanner_golden" {
  name = "/ec2/windows/security_group_id/bmc_scanner"
}

data "aws_ssm_parameter" "windows_encase_golden" {
  name = "/ec2/windows/security_group_id/encase"
}

data "aws_ssm_parameter" "windows_rdp_golden" {
  name = "/ec2/windows/security_group_id/rdp"
}

data "aws_ssm_parameter" "windows_sccm_golden" {
  name = "/ec2/windows/security_group_id/sccm"
}

data "aws_ssm_parameter" "windows_scom_golden" {
  name = "/ec2/windows/security_group_id/scom"
}

data "aws_ssm_parameter" "electric_kms" {
  name = "/enterprise/kms/keyarn"
}

#########################################
# Create Standalone Security Group
#########################################
module "security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2" #"Check Terraform Registry for latest module version"

  name               = var.securitygroupname
  description        = "Security group for terraform example usage with EC2 instance"
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create public certificate
#########################################
module "alb_certificate" {
  source  = "app.terraform.io/pgetech/acm/aws"
  version = "0.1.2"
  providers = {
    aws     = aws
    aws.r53 = aws.r53
  }
  acm_domain_name = var.domain_name
  tags            = merge(module.tags.tags, var.optional_tags)

}

#########################################
# Create Route 53 
#########################################
module "route53" {
  source  = "app.terraform.io/pgetech/route53/aws"
  version = "0.1.1"
  # insert required variables here
  zone_id = var.zone_id
  providers = {
    aws = aws.r53
  }

  records = [
    {
      name    = var.domain_name
      type    = "CNAME"
      ttl     = "300"
      records = [module.sor_enterprise_alb.lb_dns_name]
    }
  ]

}

#########################################
# Create ALB
#########################################

module "sor_enterprise_alb" {
  source  = "app.terraform.io/pgetech/alb/aws"
  version = "0.1.3"

  alb_name     = var.alb_name
  bucket_name  = var.alb_bucket_name
  idle_timeout = 600

  security_groups = [module.security_group.sg_id]
  subnets         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  tags            = merge(module.tags.tags, local.optional_tags)
  vpc_id          = data.aws_ssm_parameter.vpc_id.value

  ###############listener###################
  certificate_arn = [
    {
      lb_listener_https_port = 443
      certificate_arn        = module.alb_certificate.acm_certificate_arn
    }
  ]
  lb_listener_https = [
    {
      port              = 443
      protocol          = "HTTPS"
      certificate_arn   = module.alb_certificate.acm_certificate_arn
      type              = "forward"
      target_group_name = var.targetgroup_name
    }
  ]

  lb_target_group = [
    {
      name                          = var.targetgroup_name
      target_type                   = "instance"
      port                          = 443
      protocol                      = "HTTPS"
      deregistration_delay          = 300
      slow_start                    = 0
      load_balancing_algorithm_type = "round_robin"
      health_check = [{
        enabled             = true
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTPS"
        timeout             = 5
        unhealthy_threshold = 2
        healthy_threshold   = 5
      }]
      stickiness = [{
        enabled = false
        type    = "lb_cookie"
      }]
      targets = {
        ec2 = {
          target_id = module.webadaptor-ec2.id
          port      = 443
        }
      }
    }
  ]

}