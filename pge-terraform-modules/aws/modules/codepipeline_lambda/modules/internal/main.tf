/*
 * # AWS codepipeline module for Lambda
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#  Filename    : aws/modules/codepipeline_lambda/modules/internal/main.tf
#  Date        : 06 June 2024
#  Author      : PGE
#  Description : The internal terraform module creates a codepipeline in AWS

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace           = "ccoe-tf-developers"
  owner               = var.github_org
  github_sm_list      = split(":", var.secretsmanager_github_token_secret_name)
  github_sm_name      = local.github_sm_list[0]
  github_sm_key_name  = length(local.github_sm_list) == 2 ? local.github_sm_list[1] : null
  github_sm_key_value = local.github_sm_key_name != null ? jsondecode(data.aws_secretsmanager_secret_version.github_token_id.secret_string)[local.github_sm_key_name] : null
  github_token        = local.github_sm_key_value != null ? local.github_sm_key_value : data.aws_secretsmanager_secret_version.github_token_id.secret_string
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.encryption_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "aws_secretsmanager_secret" "github_token" {
  name = local.github_sm_name
}

data "aws_secretsmanager_secret_version" "github_token_id" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



# Module : Codepipeline
# Description : This terraform module creates codepipeline

resource "aws_codepipeline" "codepipeline" {

  name     = var.codepipeline_name
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_store_location_bucket
    type     = "S3"
    region   = var.artifact_store_region
    dynamic "encryption_key" {
      for_each = var.encryption_key_id != null ? [true] : []
      content {
        id   = var.encryption_key_id
        type = "KMS"
      }
    }
  }

  # Stage 1
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.source_type == "GitHub" ? "ThirdParty" : "AWS"
      provider         = var.source_type
      version          = "1"
      output_artifacts = ["code"]
      region           = var.region

      configuration = var.source_type == "GitHub" ? {
        OAuthToken           = local.github_token
        Repo                 = var.repo_name
        Branch               = var.branch
        PollForSourceChanges = var.pollchanges
        Owner                = local.owner
        } : {
        S3Bucket             = var.s3_bucket
        S3ObjectKey          = var.s3_object_key
        PollForSourceChanges = "false"
      }
    }
  }

  # Stage 2
  # Application build stage
  stage {
    name = "Build"

    action {
      name             = "build-project"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["build"]
      input_artifacts  = ["code"]
      region           = var.region

      configuration = {
        ProjectName = module.codebuild_project.codebuild_project_id
      }
    }
  }

  # Stage 3
  # Static Code Analysis with SonarQube
  stage {
    name = "Codescan"

    action {
      name             = "sonarqube-code-analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["scan"]
      input_artifacts  = ["build"]
      region           = var.region

      configuration = {
        ProjectName = module.codebuild_codescan.codebuild_project_id
      }
    }
  }

  # Stage 4 Publish artifact to jfrog
  stage {
    name = "Publish"

    action {
      name             = "Publish-to-jfrog-and-update-Lambda-code"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["publish"]
      input_artifacts  = ["scan"]
      region           = var.region

      configuration = {
        ProjectName = module.codebuild_codepublish.codebuild_project_id
      }
    }
  }

  # Stage 5 Dynamic stage.
  # This stage dynamic, more number of stages can be added here by passing values in tfvars.
  # for_each iterates the name and action inside the content block, stg.name indicates stage and it is iterated in the dynamic block similar iteration is done in action.
  # In Examples main.tf , dynamic stages can be added inside stages = [] block. Similarly upcoming stages can be added inside the same block.
  dynamic "stage" {
    for_each = [for stg in var.stages : {
      name   = stg.name
      action = stg.action
    }]
    content {
      name = stage.value.name
      dynamic "action" {
        for_each = stage.value.action
        content {
          name             = action.value["name"]
          owner            = action.value["owner"]
          version          = action.value["version"]
          category         = action.value["category"]
          provider         = action.value["provider"]
          input_artifacts  = lookup(action.value, "input_artifacts", [])
          output_artifacts = lookup(action.value, "output_artifacts", [])
          configuration    = lookup(action.value, "configuration", {})
          role_arn         = lookup(action.value, "role_arn", null)
          run_order        = lookup(action.value, "run_order", null)
          region           = var.region
        }
      }
    }
  }
  tags = local.module_tags
}