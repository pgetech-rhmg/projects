/*
 * # AWS codepipeline Internal module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    : aws/modules/codepipeline_s3web/modules/internal/main.tf
#  Date        : 02 April 2024
#  Author      : pge
#  Description : creation of codepipeline module for s3 web
#

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
  namespace   = "ccoe-tf-developers"
  kms_key_arn = var.kms_key_arn
  owner       = regex("https:\\/\\/github.com\\/(\\w+)\\/([\\w-_]+)(.git$|$)", var.github_repo_url)[0]
  repo_name   = regex("https:\\/\\/github.com\\/(\\w+)\\/([\\w-_]+)(.git$|$)", var.github_repo_url)[1]
  #   github_repo_url     = "https://github.com/${local.owner}/${local.repo_name}.git"
  github_sm_list      = split(":", var.secretsmanager_github_token_secret_name)
  github_sm_name      = local.github_sm_list[0]
  github_sm_key_name  = length(local.github_sm_list) == 2 ? local.github_sm_list[1] : null
  github_sm_key_value = local.github_sm_key_name != null ? jsondecode(data.aws_secretsmanager_secret_version.github_token_id.secret_string)[local.github_sm_key_name] : null
  github_token        = local.github_sm_key_value != null ? local.github_sm_key_value : data.aws_secretsmanager_secret_version.github_token_id.secret_string
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_arn == null) ? 1 : 0
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

# Module : S3
# Description : This terraform module creates S3 bucket to store codepipeline artifacts. Not creating the bucket for custom type. 

module "s3" {
  count         = var.codepipeline_type != "custom" ? 1 : 0
  source        = "app.terraform.io/pgetech/s3/aws"
  version       = "0.1.0"
  bucket_name   = "${var.codepipeline_name}-codepipeline-bucket"
  kms_key_arn   = local.kms_key_arn
  force_destroy = true
  policy        = data.aws_iam_policy_document.allow_access.json
  tags          = local.module_tags
}

######################################################################################
#IAM role for codepipeline - Inline policy is required to create role so it is configured as template_fle
module "codepipeline_iam_role" {
  count   = var.codepipeline_type != "custom" ? 1 : 0
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name          = "codepipeline_${var.codepipeline_name}_iam_role"
  aws_service   = var.codepipeline_role_service
  tags          = local.module_tags
  inline_policy = [templatefile("${path.module}/codebuild_iam_policies/codepipeline_iam_policy.json", { codepipeline_bucket_arn = module.s3[0].arn })]
}

# Module : Codepipeline
# Description : This terraform module creates codepipeline


resource "aws_codepipeline" "codepipeline" {
  #   count = var.codepipeline_type != "html" ? 1 : 0 ## This resource won't be executed for HTML app, since HTML app doesn't have a build stage

  lifecycle {
    create_before_destroy = true
  }
  name     = var.codepipeline_name
  role_arn = var.codepipeline_type != "custom" ? module.codepipeline_iam_role[0].arn : var.codepipeline_role_arn
  # Artifact_store: Storing artifacts of codepipeline stages in S3.
  artifact_store {
    location = var.codepipeline_type != "custom" ? module.s3[0].id : var.artifact_store_location_bucket
    type     = "S3"
    region   = var.artifact_store_region
    dynamic "encryption_key" {
      for_each = local.kms_key_arn != null ? [true] : []
      content {
        id   = local.kms_key_arn
        type = "KMS"
      }
    }
  }

  # Stage 1
  # Source stage connecting to GitHub


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

  dynamic "stage" {
    for_each = var.codepipeline_type != "html" ? [1] : []
    content {
      name = "Build"
      dynamic "action" {
        for_each = var.codepipeline_type != "html" ? [1] : []
        content {
          name             = "build-project"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          output_artifacts = ["build"]
          input_artifacts  = ["code"]
          region           = var.region
          #Note: module of codebuild is passed in configuration so that it picks up the dedicated project for the stage.
          configuration = {
            ProjectName = module.codebuild_project[0].codebuild_project_id
          }
        }
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
      input_artifacts  = var.codepipeline_type != "html" ? ["build"] : ["code"]
      region           = var.region
      #Note: module of codescan is passed in configuration so that it picks up the dedicated project for the stage.
      configuration = {
        ProjectName = module.codebuild_codescan.codebuild_project_id
      }
    }
  }

  # Stage 4 Publish artifact to s3
  stage {
    name = "Publish"

    action {
      name             = "Publish-to-s3"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["publish"]
      input_artifacts  = ["scan"]
      region           = var.region
      #Note: module of codepublish is passed in configuration so that it picks up the dedicated project for the stage.
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
