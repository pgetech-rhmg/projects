/*
 * # PG&E Mrad ECS Module
 *  MRAD specific composite Terraform ECS module to provision SAF compliant resources
*/
#
# Filename    : modules/mrad-codepipeline/main.tf
# Date        : 2 May 2023
# Author      : MRAD (mrad@pge.com)
# Description : This terraform module example provisions MRAD compatible ECR, ECS, CodePipeline
#

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

data "aws_secretsmanager_secret_version" "sumo_keys" {
  secret_id = "sumo_keys"
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = local.role_arn
  }
}

provider "aws" {
  alias  = "r53"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num_r53}:role/${var.aws_r53_role}"
  }
}

provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.0.3"

  AppID              = 1795
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Medium"
  Notify             = ["MRAD@pge.com"]
  Owner              = ["A1P2", "S2RB", "JVCW"]
  Compliance         = ["None"]
}

module "ecs" {
  source = "../../../mrad-ecs"
  providers = {
    aws          = aws
    aws.r53      = aws.r53
    aws.ccoe_dns = aws.r53
    sumologic    = sumologic
  }

  tags = module.tags.tags

  project_name = var.project_name
  branch       = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  aws_region   = var.aws_region
  aws_account  = var.aws_account
  aws_role     = var.aws_role
  lb           = true
}

resource "aws_lb_listener_certificate" "all_alb_certs" {
  listener_arn    = module.ecs.listener_https_arn[443]
  certificate_arn = var.swap_cert_arns[var.aws_account]
}
