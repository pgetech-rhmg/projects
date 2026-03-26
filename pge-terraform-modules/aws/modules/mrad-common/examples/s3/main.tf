/*
* # mrad-common usage example.
* Terraform module which creates SAF2.0 common MRAD related resources in AWS.
*/
#
# Filename    : modules/mrad-common/examples/main.tf
# Date        : 04 Apr 2025
# Author      : PGE
# Description : This Terraform usage example creates common MRAD related resources in AWS.

terraform {
  required_version = ">= 1.1.0"
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

locals {
    role_arn = var.aws_role == "MRAD_Ops" ? null : "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = local.role_arn
  }
}

provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}

provider "github" {
  owner = "PGEDigitalCatalyst"
  token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).github
}

module "mrad-common" {
    source      = "../../"
    # only required for local dev since both values are predefined in TFC
    account_num = var.account_num
    aws_role    = var.aws_role
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

data "aws_secretsmanager_secret" "github_token" {
  name = var.github_secret
}
resource "aws_s3_bucket" "mrad-common" {
  bucket = "mrad-common"
  
  tags = module.mrad-common.tags
}

