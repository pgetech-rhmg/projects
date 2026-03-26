/*
 * # MRAD Example Lambda function with S3 Bucket
*/
#
#  Filename    : aws/modules/mrad-lambda/examples/First-Example-Lambda/main.tf
#  Date        : 18 April 2023
#  Author      : MRAD (mrad@pge.com)
#  Description : The example creates a Lambda function

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.1.2"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = var.aws_role == "MRAD_Ops" ? null : "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}

provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}

data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

resource "random_bytes" "suffix" {
  length = 2
}

module "first_lambda" {
  providers = {
    sumologic = sumologic
  }

  source                               = "../../modules/lambda-sumo"
  lambda_name                          = "First-Example-Lambda-TFC-${random_bytes.suffix.hex}"
  aws_region                           = var.aws_region
  aws_account                          = var.aws_account
  kms_role                             = var.kms_role
  aws_role                             = var.aws_role
  service                              = var.service
  archive_path                         = var.archive_path
  partner                              = var.partner
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  tags                                 = merge(module.mrad-common.tags, var.optional_tags)
  dead_letter_queue_arn                = module.sqs-test_dlq.arn
}

module "sqs-test_dlq" {
  source                     = "../../../sqs/modules/sqs_standard_queue"
  sqs_name                   = "test-queue-tfc-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  tags                       = module.mrad-common.tags
  visibility_timeout_seconds = 60
  message_retention_seconds  = 1209600 // 14 days
  kms_key_id                 = "alias/s3-sns-sqs"
}

module "second_lambda" {
  providers = {
    sumologic = sumologic
  }

  source  = "../../modules/lambda-sumo"

  lambda_name                          = "Second-Example-Lambda-TFC-${random_bytes.suffix.hex}"
  aws_account                          = var.aws_account
  aws_role                             = var.aws_role
  aws_region                           = var.aws_region
  archive_path                         = var.archive_path
  service                              = var.service
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  tags                                 = merge(module.mrad-common.tags, var.optional_tags)
}

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-common/aws"
  version     = "~> 1.0"  
  account_num = var.account_num
  aws_role    = var.aws_role
}