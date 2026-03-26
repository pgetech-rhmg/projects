/*
 * # Blue-Green EC2 Deployment Module
 * Terraform module which creates bluegreen EC2 AMI Automation in AWS
*/
# Filename    : modules/blue-green/examples/main.tf
# Date        : 2 January 2026
# Author      : PGE
# Description : bluegreen EC2 AMI Automation
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags        = var.optional_tags
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


module "bluegreen_ec2" {
  source = "../../"
  tags                 = merge(module.tags.tags, local.optional_tags)
  account_num     = var.account_num
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  instance_type   = var.instance_type
  lambda_function_name   = var.lambda_function_name
  lambda_bucket_name     = var.lambda_bucket_name
  latest_ami_param_name  = var.latest_ami_param_name
  ami_catalog_param_name = var.ami_catalog_param_name

  # Rollout controls (partners only touch these):
  green_percent          = var.green_percent
  release_version        = var.release_version
  blue_mode              = var.blue_mode
  blue_pinned_ami_id     = var.blue_pinned_ami_id
  green_asg_name         = var.green_asg_name
  blue_asg_name          = var.blue_asg_name
  blue_min_size          = var.blue_min_size
  blue_max_size          = var.blue_max_size
  blue_desired_capacity  = var.blue_desired_capacity
  green_min_size         = var.green_min_size
  green_max_size         = var.green_max_size
  green_desired_capacity = var.green_desired_capacity
  enable_ami_automation = var.enable_ami_automation
  auto_apply_ami_updates = var.auto_apply_ami_updates
  security_group_name      = var.security_group_name
  cidr_ingress_rules           = var.cidr_ingress_rules
  cidr_egress_rules            = var.cidr_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  alb_name = var.alb_name
  lb_listener_https = var.lb_listener_https
  lb_target_group = var.lb_target_group
}