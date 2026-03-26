provider "aws" {
    region  =  var.aws_region
}

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.Optional_tags
}
 
module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.0"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
}

module "ec2-ami-upgrade" {
  source = "../../"
  tags            = merge(module.tags.tags, local.optional_tags)
  role_name = var.role_name
  aws_region = var.aws_region
  account_id = var.account_id
  excluded_instances = var.excluded_instances
  excluded_asgs = var.excluded_asgs
  asg_configurations = var.asg_configurations
  vpc_config_security_group_ids = var.vpc_config_security_group_ids
  vpc_config_subnet_ids = var.vpc_config_subnet_ids
  kms_key_arn = var.kms_key_arn
  aws_service           = var.aws_service
  trusted_aws_principals = var.trusted_aws_principals
  description = var.description
  path = var.path
  policy_arns           = var.policy_arns

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
}