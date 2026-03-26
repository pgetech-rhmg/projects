/*
 * # MRAD Example Lambda function with Sumo integration
*/
#
#  Filename    : aws/modules/mrad-sumo/examples/First-Example-Lambda/main.tf
#  Date        : 13 June 2023
#  Author      : MRAD (mrad@pge.com)
#  Description : The example creates a Lambda function along with Sumo integration

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.0.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.aws_role == "MRAD_Ops" ? null : "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}

provider "sumologic" {}

locals {
  environment = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH != null ? "main" : terraform.workspace
}

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-common/aws"
  version     = "~> 1.0"
  account_num = var.account_num
  aws_role    = var.aws_role
}

module "first_lambda" {
  source                               = "app.terraform.io/pgetech/mrad-lambda/aws//modules/lambda"
  version                              = "~> 3.0"
  # source = "../../../mrad-lambda/modules/lambda"
  lambda_name                          = var.lambda_name
  handler                              = "index.handler"
  aws_region                           = var.aws_region
  aws_account                          = var.aws_account
  kms_role                             = var.kms_role
  aws_role                             = var.aws_role
  account_num                          = var.account_num
  service                              = var.service
  archive_path                         = var.archive_path
  partner                              = var.partner
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  # tags                                 = merge(module.mrad-common.tags, var.optional_tags)
}

module "log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"
  name    = "/aws/lambda/${var.lambda_name}-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  tags    = module.mrad-common.tags
}

module "sumo_logger" {
  source  = "../../../mrad-sumo"
  providers = {
    sumologic = sumologic
  }
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = local.environment
  aws_account    = var.aws_account
  account_num    = var.account_num
  aws_role       = var.aws_role
  partner        = var.partner
  tags           = module.mrad-common.tags
  optional_tags  = var.optional_tags
  log_group_name = module.log_group.cloudwatch_log_group_name
}
