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

module "mrad-common" {
  source  = "app.terraform.io/pgetech/mrad-common/aws"
  version = "~> 1.0"
  
  account_num = var.account_num
  aws_role    = var.aws_role
}

module "api_gateway_trigger" {
  source = "../../modules/api-gw"

  providers = {
    aws        = aws
    aws.r53    = aws.r53
      aws.ccoe_dns = aws.r53
      sumologic = sumologic
  }

  aws_account            = var.aws_account
  name                   = join("-", ["example", var.TFC_CONFIGURATION_VERSION_GIT_BRANCH])
  lambda_name            = "LAMBDA-TRIGGER-EXAMPLE-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  branch                 = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  aws_role               = var.aws_role
  api_gw_resource_policy = file("policy.json")
  project_name           = "MRAD-API-GW-TRIGGER-EXAMPLE"
  account_num            = var.account_num

  tags = module.mrad-common.tags
}

module "lambda" {
  source  = "app.terraform.io/pgetech/mrad-lambda/aws//modules/lambda-sumo"
  version = "~> 1.0"

  lambda_name                          = "LAMBDA-TRIGGER-EXAMPLE"
  aws_region                           = var.aws_region
  aws_account                          = var.aws_account
  kms_role                             = var.aws_role
  aws_role                             = var.aws_role
  service                              = ["lambda.amazonaws.com"]
  archive_path                         = "src"
  partner                              = "MRAD"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  tags                                 = module.mrad-common.tags
}
