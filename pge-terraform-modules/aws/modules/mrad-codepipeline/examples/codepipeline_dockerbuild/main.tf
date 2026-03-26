/*
* # MRAD Example CodePipline
* Terraform module which creates SAF2.0 ECS with EC2 in AWS.
*/
#
# Filename    : modules/ecs/mrad-codepipeline/examples/codepipeline_dockerbuild/main.tf
# Date        : 2 May 2023
# Author      : MRAD (mrad@pge.com)
# Description : The Terraform usage example creates AWS CodePipeline

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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
    role_arn = local.role_arn
  }
}

provider "aws" {
  alias  = "r53"
  region = "us-east-1"
  assume_role {
    role_arn = local.r53_role_arn
  }
}

locals {
  role_arn = var.aws_role == "MRAD_Ops" ? null : "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  r53_role_arn = "arn:aws:iam::${var.account_num_r53}:role/${var.aws_r53_role}"
}

data "aws_secretsmanager_secret" "github_token" {
  name = var.github_secret
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}
provider "github" {
  owner = "PGEDigitalCatalyst"
  token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).github
}

provider "sumologic" {
  access_id   = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_id"]
  access_key  = jsondecode(data.aws_secretsmanager_secret_version.sumo_keys.secret_string)["access_key"]
  environment = "us2"
}

resource "random_id" "id" {
  byte_length = 4
}

module "mrad-common" {

  source      = "app.terraform.io/pgetech/mrad-common/aws"
  version     = "~> 1.0"  
  # only required for local dev since both values are predefined in TFC
  account_num = var.account_num
  aws_role    = var.aws_role
}

module "pipeline" {
  source           = "../../"
  project_name     = "${var.project_name}-${random_id.id.hex}" // Don't collide with other example deployments
  repo_name        = var.project_name
  branch           = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  aws_account      = var.aws_account
  github_secret    = var.github_secret
  aws_role         = var.aws_role
  codebuild_image  = var.codebuild_image
  enable_tfc_check = true
  buildspec_deploy = "LAMBDA"
  account_num      = var.account_num
  account_num_r53  = var.account_num_r53
  aws_r53_role     = var.aws_r53_role

  tags = module.mrad-common.tags
}
