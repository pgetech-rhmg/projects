/*
 * # AWS codepipeline webhook module which creates codepipeline webhook and wires into GitHub repository, make sure to add Github provider with token and owner. 
 ex: 
 provider "github" {
  token = local.github_token
  owner = local.owner
}
 * Terraform module which creates SAF2.0 Github repository webhook.
*/
#
# Filename    : aws/modules/codepipeline/modules/github_webhook/main.tf
# Date        : 03/07/2023
# Author      : Mounika Kota
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

locals {
  namespace      = "ccoe-tf-developers"
  webhook_secret = random_password.webhook_secret.result
}

resource "random_password" "webhook_secret" {

  length  = 16
  special = false
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  name            = "webhook-github-${var.codepipeline_name}"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = var.codepipeline_name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
  tags = local.module_tags
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "github_webhook" {
  repository = var.repo_name
  active     = true

  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhook.url
    content_type = var.github_webhook_content_type
    insecure_ssl = false
    secret       = local.webhook_secret
  }

  events = var.github_webhook_events
}
