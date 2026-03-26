#
#  Filename    : aws/modules/lm-lambda-pipeline/data.tf
#  Date        : 15 April 2025
#  Author      : Sean Fairchild (s3ff@pge.com)
#  Description : LAMBDA terraform module creates a Lambda Function
#
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_secretsmanager_secret" "github_token" {
  name = var.github_secret
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

data "aws_ssm_parameter" "archive_bucket" {
  name = "/lm/s3_artifact_store_bucket"
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.vpc
}

data "aws_ssm_parameter" "subnets" {
  for_each = toset(var.subnets)
  name     = each.value
}
