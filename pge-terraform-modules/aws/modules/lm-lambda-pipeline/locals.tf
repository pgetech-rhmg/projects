#
#  Filename    : aws/modules/lm-lambda-pipeline/locals.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
locals {
  environment = {
    "265171113329" = "Dev"
    "207567762899" = "QA"
    "944747578688" = "Prod"
  }[data.aws_caller_identity.current.account_id]
  # prod = contains(["Prod", "QA"], local.environment)

  branch = {
    Dev  = "dev"
    QA   = "qa"
    Prod = "main"
  }[local.environment]
}
