/*
 * # AWS ALB  module
 * Terraform module which creates SAF2.0 ALB in AWS.
 * alb logs cannot be written to a kms-cmk encrypted s3 bucket.
 * So standard encryption is used for the s3 bucket.
 * https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
 *
 * For this example we are using the S3 bucket, SSL certificate arn and ingress CIDR, which already exists in this account. 
 * If the user is testing the example in a different account,  please change the S3 bucket name, SSL certificate arn
 * and ingress CIDR as per the account.
*/
#
# Filename    : aws/modules/alb/examples/alb_with_instance/main.tf
# Date        : 22 March 2022
# Author      : TCS
# Description : ALB creation main with EC2 instance.
#


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.Optional_tags
  Order              = var.Order
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

data "aws_caller_identity" "current" {}

#########################################
# Create Application Load Balancer
#########################################

module "alb" {
  source = "../../"

  alb_name    = var.alb_name
  bucket_name = var.bucket_name

  security_groups = [module.alb_security_group.sg_id]
  subnets         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  tags            = merge(module.tags.tags, local.optional_tags)

  ###############listener###################
  lb_listener_http       = var.lb_listener_http
  lb_listener_https      = var.lb_listener_https
  lb_listener_rule_http  = var.lb_listener_rule_http
  lb_listener_rule_https = var.lb_listener_rule_https
  certificate_arn        = var.certificate_arn

  ###############target###################

  lb_target_group = [
    {
      name        = "target-alb-1"
      target_type = "instance"
      port        = 80
      protocol    = "HTTP"
      health_check = [{
        enabled             = true
        interval            = 5
        matcher             = "200"
        path                = "/phpinfo.php"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 2
        unhealthy_threshold = 3
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }]
      targets = {
        ec2 = {
          target_id = module.ec2_1.id
          port      = 80
        }
      }
    },
    {
      name        = "target-alb-2"
      target_type = "instance"
      port        = 80
      protocol    = "HTTP"
      health_check = [{
        enabled             = true
        interval            = 5
        matcher             = "200"
        path                = "/phpinfo.php"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 3
        unhealthy_threshold = 3
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }]
      targets = {
        ec2 = {
          target_id = module.ec2_2.id
          port      = 80
        }
      }
    }
  ]
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

data "aws_subnet" "ec2" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

module "alb_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.alb_sg_name
  description        = var.alb_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.alb_cidr_ingress_rules
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = [data.aws_subnet.ec2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

module "ec2_security_group_1" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.sg_name_1
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  security_group_ingress_rules = [{
    from                     = 80,
    to                       = 80,
    protocol                 = "tcp",
    source_security_group_id = module.alb_security_group.sg_id,
    description              = "CCOE Ingress rules",
    },
    {
      from                     = 443,
      to                       = 443,
      protocol                 = "tcp",
      source_security_group_id = module.alb_security_group.sg_id,
      description              = "CCOE Ingress rules",
  }]
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "ec2_security_group_2" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = var.sg_name_2
  description = var.sg_description
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  security_group_ingress_rules = [{
    from                     = 80,
    to                       = 80,
    protocol                 = "tcp",
    source_security_group_id = module.alb_security_group.sg_id,
    description              = "CCOE Ingress rules",
    },
    {
      from                     = 443,
      to                       = 443,
      protocol                 = "tcp",
      source_security_group_id = module.alb_security_group.sg_id,
      description              = "CCOE Ingress rules",
  }]
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "ec2_1" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.1"

  name                   = var.ec2_name_1
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.ec2_security_group_1.sg_id]

  user_data_base64 = base64encode(local.user_data)

  tags = merge(module.tags.tags, local.optional_tags)
}

module "ec2_2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.1"

  name                   = var.ec2_name_2
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.ec2_security_group_2.sg_id]

  user_data_base64 = base64encode(local.user_data)

  tags = merge(module.tags.tags, local.optional_tags)
}

### Please comment the out the below if use are using a bucket that has already been created

module "s3" {
  source        = "app.terraform.io/pgetech/s3/aws"
  version       = "0.1.1"
  force_destroy = true
  bucket_name   = var.bucket_name
  kms_key_arn   = null
  policy = templatefile("${path.module}/${var.policy}", {
    bucket_name = var.bucket_name
    account_num = data.aws_caller_identity.current.account_id
  })
  tags = merge(module.tags.tags, local.optional_tags)

}