/*
 * # PG&E MRAD CodePipeline Module
 *
 * This Terraform module provisions MRAD-compatible, SAF-compliant CodePipeline instances.
 */
#
# Filename    : modules/mrad-codepipeline/main.tf
# Date        : 4 May 2023
# Author      : MRAD (mrad@pge.com)
# Description : This Terraform module provisions MRAD-compatible, SAF-compliant CodePipeline instances.
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = local.role_arn
  }
}

provider "aws" {
  alias  = "r53"
  region = "us-east-1"
  assume_role {
    role_arn = local.r53_role_arn
  }
}

data "aws_secretsmanager_secret" "github_token" {
  name = var.github_secret
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

locals {
  github_token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string).github
  repo_name    = var.repo_name == "" ? var.project_name : var.repo_name

  docker_node_base_image_branch = {
    Dev  = "development"
    QA   = "main"
    Prod = "production"
  }[var.aws_account]

  # explicitly set tfc_check, otherwise only use on env branches
  tfc_check = coalesce(
    var.enable_tfc_check,
    contains(["development", "main", "master", "production"], var.branch)
  )

  account_num = {
    Dev  = "990878119577"
    QA   = "471817339124"
    Test = "991535610078"
    Prod = "712640766496"
  }[var.aws_account]

  role_arn     = var.aws_role == "MRAD_Ops" ? null : "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  r53_role_arn = "arn:aws:iam::${var.account_num_r53}:role/${var.aws_r53_role}"

}

/*
    --- Webhook ---
*/

resource "random_password" "arbitrary_secret" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_codepipeline_webhook" "pipeline_webhook" {
  name            = "${var.project_name}-Pipeline-${var.branch}"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.codepipeline.name

  authentication_configuration {
    secret_token = random_password.arbitrary_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  tags = var.tags
}

resource "github_repository_webhook" "repo_webhook" {
  repository = local.repo_name
  configuration {
    url          = aws_codepipeline_webhook.pipeline_webhook.url
    content_type = "json"
    insecure_ssl = true
    secret       = random_password.arbitrary_secret.result
  }

  events = ["push"]
}

/*
    --- Pipeline ---
*/
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-Pipeline-${var.branch}"
  role_arn = module.codepipeline_iam_role.arn

  artifact_store {
    location = module.s3.id
    type     = "S3"
  }

  # Stage 1
  # Source stage connecting to GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        OAuthToken           = local.github_token
        Repo                 = local.repo_name
        Branch               = var.branch
        PollForSourceChanges = var.poll_for_source_changes
        Owner                = var.github_org
      }
    }
  }

  # # TODO: Secrets Scan stage need to implement access to pgetech/secret-scan repo
  # stage {
  #   name = "SecretScan"

  #   action {
  #     name             = "secrets-scan"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     version          = "1"
  #     output_artifacts = ["secret"]
  #     input_artifacts  = ["code", "secrets-code"]
  #     region           = var.region

  #     configuration = {
  #       ProjectName   = module.codesecret_project.codebuild_project_id
  #       PrimarySource = "secrets-code"
  #     }
  #   }
  # }

  # Terraform Cloud Check
  dynamic "stage" {
    for_each = local.tfc_check ? ["TFC"] : []

    content {
      name = "TFC"

      action {
        name             = "terraform-cloud-check"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        output_artifacts = ["tfc"]
        input_artifacts  = ["code"]

        configuration = {
          ProjectName = module.codebuild_tfc[0].codebuild_project_id
          EnvironmentVariables = jsonencode([
            {
              name  = "GIT_HASH"
              type  = "PLAINTEXT"
              value = "#{SourceVariables.CommitId}"
            }
          ])
        }
      }
    }
  }

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

      configuration = {
        ProjectName = module.codebuild_build.codebuild_project_id
      }
    }
  }

  # Static Code Analysis with SonarQube
  stage {
    name = "Sonarqube-Codescan"

    action {
      name             = "sonarqube-code-analysis"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = ["sonarqube"]
      input_artifacts  = ["build"]

      configuration = {
        ProjectName = module.codebuild_codescan.codebuild_project_id
      }
    }
  }

  # Docker build and wiz Scanning
  dynamic "stage" {
    for_each = var.ecr_repo_urls != null ? ["wiz"] : []

    content {
      name = "DockerBuild-WizScanning-PushECR"

      action {
        name             = "WizScanning-Docker-containers"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = ["build"]
        output_artifacts = ["wiz"]
        configuration = {
          ProjectName = module.codebuild_wiz[0].codebuild_project_id
          EnvironmentVariables = jsonencode([
            {
              name  = "GIT_HASH"
              type  = "PLAINTEXT"
              value = "#{SourceVariables.CommitId}"
            }
          ])
        }
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "deploy-project"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      output_artifacts = []
      input_artifacts  = ["build"]

      configuration = {
        ProjectName = module.codebuild_deploy.codebuild_project_id
      }
    }
  }

  tags = var.tags
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.0.14"

  bucket_name         = "${lower(var.project_name)}-pipeline-${var.branch}-ppln"
  kms_key_arn         = var.kms_key_arn
  policy              = data.aws_iam_policy_document.allow_access.json
  force_destroy       = true
  block_public_policy = true
  tags                = var.tags
}

data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*"
    ]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${module.s3.arn}/alb-logs/AWSLogs/${data.aws_caller_identity.current.id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:*"]
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      module.s3.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:*"]
    }
  }
}

######################################################################################
#IAM role for codepipeline - Inline policy is required to create role so it is configured as template_fle
module "codepipeline_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version     = "0.0.8"
  name        = "${var.project_name}-Pipeline-${var.branch}"
  aws_service = ["codepipeline.amazonaws.com"]
  tags        = var.tags

  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", {
    codepipeline_bucket_arn = module.s3.arn
  })]

}

data "aws_iam_policy_document" "kms" {
  statement {
    sid = "CCOETFEAllowAllIAMUserPermissions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
    actions = [
      "kms:DescribeKey",
      "kms:CreateCustomKeyStore",
      "kms:DescribeCustomKeyStores",
      "kms:CreateKey",
      "kms:List*",
      "kms:GetKeyPolicy",
      "kms:UpdatePrimaryRegion",
      "kms:ConnectCustomKeyStore",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyPair",
      "kms:SynchronizeMultiRegionKey",
      "kms:ReplicateKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GetKeyPolicy"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "AllowCBAndCPToUseKMSKey"
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
        "codebuild.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:*"]

    }
  }
}
