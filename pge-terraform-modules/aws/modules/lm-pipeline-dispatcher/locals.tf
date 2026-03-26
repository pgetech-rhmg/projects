##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/locals.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
locals {
  environment = {
    "265171113329" = "Dev"
    "207567762899" = "QA"
    "944747578688" = "Prod"
  }[data.aws_caller_identity.current.account_id]

  branch = {
    "Dev"  = "dev"
    "QA"   = "qa"
    "Prod" = "main"
  }[local.environment]
}
