/*
 * #Rolling EC2 Deployment Module
 * Terraform module which creates rolling EC2 AMI Automation in AWS
*/
# Filename    : modules/rolling_ec2/examples/main.tf
# Date        : 20 January 2026
# Author      : PGE
# Description : Non bluegreen Rolling EC2 AMI Automation
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
  optional_tags      = var.optional_tags
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

module "rolling_ec2" {
  source = "../../"
  tags   = merge(module.tags.tags, local.optional_tags)

  account_num = var.account_num
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  security_group_name          = var.security_group_name
  cidr_ingress_rules           = var.cidr_ingress_rules
  cidr_egress_rules            = var.cidr_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  alb_name                     = var.alb_name
  lb_listener_https            = var.lb_listener_https
  lb_target_group              = var.lb_target_group
  lambda_bucket_name           = var.lambda_bucket_name
  lambda_function_name         = var.lambda_function_name
  asg_name                     = var.asg_name
  instance_type                = var.instance_type
  min_size                     = var.min_size
  max_size                     = var.max_size
  desired_capacity             = var.desired_capacity
  release_version              = var.release_version

  latest_ami_param_name  = var.latest_ami_param_name
  ami_catalog_param_name = var.ami_catalog_param_name

  enable_ami_automation  = var.enable_ami_automation
  auto_apply_ami_updates = var.auto_apply_ami_updates

}