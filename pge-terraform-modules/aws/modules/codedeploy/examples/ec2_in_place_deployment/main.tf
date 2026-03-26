/*
 * # AWS CodeDeploy Ec2 In_place Deployment User module example
*/
#
#  Filename    : aws/modules/codedeploy/examples/ec2_in_place_deployment/main.tf
#  Date        : 5 July 2022
#  Author      : TCS
#  Description : The terraform module example creates a Ec2 In-place deployment

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
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

#########################################
# Supporting Resources
#########################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "golden_ami" {
  name = var.ssm_parameter_golden_ami
}

# The resource random_string generates a random permutation of alphanumeric characters.
resource "random_string" "random" {
  length  = 5
  special = false
}

#########################################
# Create codedeploy_app_ec2
#########################################

module "codedeploy_app_ec2" {
  source = "../.."

  codedeploy_app_name = "${var.codedeploy_app_name}-${random_string.random.result}"
  tags                = merge(module.tags.tags, local.optional_tags)
}

#########################################
# Create deployment_config_ec2
#########################################

module "deployment_config_ec2" {
  source = "../../modules/codedeploy_deployment_config"

  deployment_config_name = "${var.deployment_config_name}-${random_string.random.result}"
  minimum_healthy_hosts  = var.minimum_healthy_hosts
}

#########################################
# Create deployment_group_ec2
#########################################

module "deployment_group" {
  source = "../../modules/deployment_group"

  deployment_group_app_name         = module.codedeploy_app_ec2.codedeploy_app_name
  deployment_group_name             = "${var.deployment_group_name}-${random_string.random.result}"
  deployment_group_service_role_arn = module.deployment_group_role.arn
  deployment_config_name            = module.deployment_config_ec2.deployment_group_config_name
  tags                              = merge(module.tags.tags, local.optional_tags)

  deployment_style = [{
    deployment_option = var.deployment_option
  }]

  load_balancer_info = [{
    target_group_info = [{
      name = var.lb_target_group_name
    }]
  }]

  ec2_tag_filter = [{
    key   = var.ec2_tag_filter_key
    type  = var.ec2_tag_filter_type
    value = var.ec2_tag_filter_value
  }]
}

#########################################
# Create Application Load Balancer
#########################################

module "alb" {
  source  = "app.terraform.io/pgetech/alb/aws"
  version = "0.1.2"

  alb_name        = "${var.alb_name}-${random_string.random.result}"
  bucket_name     = var.alb_s3_bucket_name
  security_groups = [module.alb_security_group.sg_id]
  subnets         = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  tags            = merge(module.tags.tags, local.optional_tags)

  ############### listener ###################

  lb_listener_http       = var.lb_listener_http
  lb_listener_https      = var.lb_listener_https
  lb_listener_rule_http  = var.lb_listener_rule_http
  lb_listener_rule_https = var.lb_listener_rule_https
  certificate_arn        = var.certificate_arn

  ############### target #####################

  lb_target_group = [
    {
      name        = var.lb_target_group_name
      target_type = var.lb_target_group_target_type
      port        = var.lb_target_group_port
      protocol    = var.lb_target_group_protocol
      health_check = [{
        enabled             = var.health_check_enabled
        interval            = var.health_check_interval
        matcher             = var.health_check_matcher
        path                = var.health_check_path
        port                = var.health_check_port
        protocol            = var.health_check_protocol
        timeout             = var.health_check_timeout
        unhealthy_threshold = var.health_check_unhealthy_threshold
      }]
      stickiness = [{
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }]
      targets = {
        ec2 = {
          target_id = module.ec2.id
          port      = var.targets_ec2_port
        }
      }
    }
  ]
}

module "alb_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = "${var.alb_sg_name}-${random_string.random.result}"
  description        = var.alb_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.alb_cidr_ingress_rules
  cidr_egress_rules  = var.alb_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "ec2_security_group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "${var.ec2_sg_name}-${random_string.random.result}"
  description = var.ec2_sg_description
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
  cidr_egress_rules = var.ec2_cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.2"

  name                   = "${var.ec2_name}-${random_string.random.result}"
  availability_zone      = var.ec2_az
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_ssm_parameter.subnet_id1.value
  vpc_security_group_ids = [module.ec2_security_group.sg_id]
  user_data_base64       = base64encode(local.user_data)
  tags                   = merge(module.tags.tags, local.optional_tags)
}

module "deployment_group_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.role_name}-${random_string.random.result}"
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.policy_arns
}

module "vpc_endpoint_code_deploy_api" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  private_dns_enabled = true
  service_name        = var.api_service_name
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnet_ids          = [data.aws_ssm_parameter.subnet_id1.value]
  security_group_ids  = [module.security_group_vpc_endpoint.sg_id]
  tags                = merge(module.tags.tags, local.optional_tags)
}

module "vpc_endpoint_code_deploy_agent" {
  source  = "app.terraform.io/pgetech/vpc-endpoint/aws"
  version = "0.1.1"

  #private_dns_enabled = true
  service_name       = var.agent_service_name
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  security_group_ids = [module.security_group_vpc_endpoint.sg_id]
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "security_group_vpc_endpoint" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name               = var.vpc_endpoint_sg_name
  description        = var.vpc_endpoint_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.vpc_endpoint_cidr_ingress_rules
  cidr_egress_rules  = var.vpc_endpoint_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}
