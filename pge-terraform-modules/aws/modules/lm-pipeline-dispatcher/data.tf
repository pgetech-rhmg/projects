##################################################################
#
#  Filename    : aws/modules/lm-pipeline-dispatch/data.tf
#  Date        : 15 May 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : Terraform module creates a Codebuild dispatcher instance that can manage deployments of multiple services in the same repository
#
##################################################################
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "github_token" {
  name = var.github_secret
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc
}

data "aws_ssm_parameter" "subnets" {
  for_each = toset(var.subnets)
  name     = each.value
}
