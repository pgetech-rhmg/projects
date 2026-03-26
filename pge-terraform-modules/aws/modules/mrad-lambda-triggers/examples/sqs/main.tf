terraform {
  required_version = ">= 1.1.0"
}

module "mrad-common" {
  source      = "app.terraform.io/pgetech/mrad-ecs/aws"
  version     = "~> 1.0" 
  # only required for local dev since both values are predefined in TFC
  account_num = var.account_num
  aws_role    = var.aws_role
}

module "sqs_trigger" {
  source = "../../modules/sqs"

  lambda_name   = "LAMDBA-TRIGGER-SQS-EXAMPLE-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  sns_topic_arn = ""

  tags = module.mrad-common.tags
}

module "lambda" {
  source  = "app.terraform.io/pgetech/mrad-lambda/aws"
  version = "~> 1.0"

  lambda_name                          = "LAMDBA-TRIGGER-SQS-EXAMPLE"
  aws_region                           = var.aws_region
  aws_account                          = var.aws_account
  kms_role                             = var.aws_role
  aws_role                             = var.aws_role
  account_num                          = var.account_num
  service                              = ["lambda.amazonaws.com"]
  archive_path                         = "src"
  partner                              = "MRAD"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  tags                                 = module.mrad-common.tags
}