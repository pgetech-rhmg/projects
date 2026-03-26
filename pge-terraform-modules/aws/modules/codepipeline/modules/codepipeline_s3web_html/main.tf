/*
 * # AWS codepipeline Html module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    : aws/modules/codepipeline/modules/codepipeline_s3web_html/main.tf
#  Date        : 09 Sep 2022
#  Author      : pge
#  Description : creation of html codepipeline module for s3 web
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
  namespace           = "ccoe-tf-developers"
  owner               = "pgetech"
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


module "s3" {
  source        = "app.terraform.io/pgetech/s3/aws"
  version       = "0.1.0"
  bucket_name   = "${var.codepipeline_name}-codepipeline-bucket"
  kms_key_arn   = var.kms_key_arn
  force_destroy = true
  policy        = data.aws_iam_policy_document.allow_access.json
  tags          = local.module_tags
}

######################################################################################
#IAM role for codepipeline - Inline policy is required to create role so it is configured as template_fle
module "codepipeline_iam_role" {
  source        = "app.terraform.io/pgetech/iam/aws"
  version       = "0.1.0"
  name          = "codepipeline_${var.codepipeline_name}_iam_role"
  aws_service   = var.codepipeline_role_service
  tags          = local.module_tags
  inline_policy = [templatefile("${path.module}/codebuild_iam_policies/codepipeline_iam_policy.json", { codepipeline_bucket_arn = module.s3.arn })]
}

resource "aws_codepipeline" "codepipeline" {
  lifecycle {
    create_before_destroy = true
  }
  name     = var.codepipeline_name
  role_arn = module.codepipeline_iam_role.arn
  # Artifact_store: Storing artifacts of codepipeline stages in S3.
  artifact_store {
    location = module.s3.id
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
  # Source stage connecting to GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]
      region           = var.region

      configuration = {
        OAuthToken           = local.github_token
        Repo                 = var.repo_name
        Branch               = var.github_branch
        PollForSourceChanges = var.pollchanges
        Owner                = local.owner
      }
    }
  }

  # Stage 2
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
      input_artifacts  = ["code"]
      region           = var.region
      #Note: module of codescan is passed in configuration so that it picks up the dedicated project for the stage.
      configuration = {
        ProjectName = module.codebuild_codescan.codebuild_project_id
      }
    }
  }

  # Stage 3 Publish artifact to s3
  stage {
    name = "Publish"

    action {
      name             = "Publish-to-s3"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["publish"]
      input_artifacts  = ["code"]
      region           = var.region
      #Note: module of codepublish is passed in configuration so that it picks up the dedicated project for the stage.
      configuration = {
        ProjectName = module.codebuild_codepublish.codebuild_project_id
      }
    }
  }

  # Stage 4 Dynamic stage.
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