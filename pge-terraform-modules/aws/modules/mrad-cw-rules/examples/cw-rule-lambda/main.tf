terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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

module "cloudwatch_event_rule" {
  source = "../../../mrad-cw-rules"

  name        = "CW-LAMBDA-EXAMPLE"
  input       = null
  description = "Example cw rule with lambda"
  arn         = module.lambda.lambda_arn
  schedule    = "cron(0 9 * * ? *)"

  branch      = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  aws_account = var.aws_account
  tags        = module.tags.tags
}

module "lambda" {
  source  = "app.terraform.io/pgetech/mrad-lambda/aws"
  version = "~> 1.0"

  lambda_name                          = "CW-LAMBDA-EXAMPLE"
  aws_region                           = var.aws_region
  aws_account                          = var.aws_account
  kms_role                             = var.aws_role
  aws_role                             = var.aws_role
  account_num                          = var.account_num
  service                              = ["lambda.amazonaws.com"]
  archive_path                         = "src"
  partner                              = "MRAD"
  TFC_CONFIGURATION_VERSION_GIT_BRANCH = var.TFC_CONFIGURATION_VERSION_GIT_BRANCH
  tags                                 = module.tags.tags
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "CW-LAMBDA-EXAMPLE-${var.TFC_CONFIGURATION_VERSION_GIT_BRANCH}"
  principal     = "events.amazonaws.com"
  source_arn    = module.cloudwatch_event_rule.arn
}