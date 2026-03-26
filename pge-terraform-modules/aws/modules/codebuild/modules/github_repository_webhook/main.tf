/*
 * # AWS Codebuild module creating Codebuild webhook and Github repository webhook
 * Terraform module which creates SAF2.0 Codebuild webhook and Github repository webhook.
*/
#
# Filename    : aws/modules/codebuild/modules/github_repository_webhook/main.tf
# Date        : 20/04/2022
# Author      : TCS
#

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  owner            = "pgetech"
  github_token_arn = var.github_token
  auth_type        = "PERSONAL_ACCESS_TOKEN"
  server_type      = "GITHUB"
  Token            = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).Token
}

data "aws_secretsmanager_secret" "github_token" {
  arn = var.github_token
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = var.github_token
}

provider "github" {
  token    = local.Token
  base_url = var.github_base_url
  owner    = local.owner
}

resource "github_repository_webhook" "repository_webhook" {

  repository = var.github_repository
  events     = var.github_events
  active     = var.github_active
  name       = var.github_name

  configuration {
    url          = aws_codebuild_webhook.codebuild_webhook.payload_url
    content_type = var.github_content_type
    insecure_ssl = var.github_insecure_ssl
    secret       = aws_codebuild_webhook.codebuild_webhook.secret
  }
}

resource "aws_codebuild_webhook" "codebuild_webhook" {
  project_name  = var.codebuild_webhook_project_name
  build_type    = var.codebuild_webhook_build_type
  branch_filter = var.codebuild_webhook_branch_filter

  dynamic "filter_group" {
    for_each = var.filter != [] ? var.filter : []
    content {
      #We can pass the values for all the fields in the filter through the variable 'filter'.
      dynamic "filter" {
        for_each = var.filter
        content {
          type                    = filter.value.type
          pattern                 = filter.value.pattern
          exclude_matched_pattern = lookup(filter.value, "exclude_matched_pattern", false)
        }
      }
    }
  }
}