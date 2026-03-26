/*
* # AWS Pinpoint usage example.
* Terraform module which creates SAF2.0 Pinpoint resources in AWS.
*/
#
# Filename    : modules/mrad-pinpoiint/examples/main.tf
# Date        : 20 Feb 2025
# Author      : PGE
# Description : The Terraform usage example creates AWS Pinpoint resources

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-common/aws"
  version     = "~> 1.0" 
  # only required for local dev since both values are predefined in TFC
  account_num = var.account_num
  aws_role    = var.aws_role
}

################################################################################

module "pinpoint" {
  source       = "../"
  app_name     = var.app_name
  enable_sms   = var.enable_sms
  enable_email = var.enable_email
  enable_push  = var.enable_push
  account_num  = var.account_num
  aws_role     = var.aws_role
}
