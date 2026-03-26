/*
 * # AWS codepipeline for Container based Java application module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    :  aws/modules/codepipeline_container/modules/ecs_rollback/main.tf
#  Date        : 12-19-2022
#  Author      : Tekyantra
#  Description : creation of codepipeline module from codepipeline_Java
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  # experiments = [module_variable_optional_attrs]
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
  depends_on = [
    module.sns_topic_manual_approval
  ]
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
        Branch               = var.branch
        PollForSourceChanges = var.pollchanges
        Owner                = local.owner
      }
    }
  }

  # Stage 2 Prepare the rolliback config
  stage {
    name = "PrepareRollbackConfigs"

    action {
      name            = "PrepareRollbackConfigs"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["code"]
      output_artifacts = [
        "ImageArtifact",
        "DefinitionArtifact",
      ]
      region = var.region
      configuration = {
        ProjectName = module.codebuild_rollback_config.codebuild_project_id
      }
    }
  }

  # Stage-3 Rollback Approval stage

  stage {
    name = "ManualApproval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = module.sns_topic_manual_approval.sns_topic_arn
        CustomData      = var.notification_message
      }
    }
  }

  stage {
    name = "Rollback"
    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      version  = "1"
      provider = var.codedeploy_provider
      input_artifacts = [
        var.image1_artifact_name,
        var.task_definition_template_artifact

      ]
      configuration = {
        ApplicationName                = var.codedeploy_application_name
        DeploymentGroupName            = var.codedeploy_deployment_groupname
        TaskDefinitionTemplateArtifact = var.task_definition_template_artifact
        TaskDefinitionTemplatePath     = var.task_definition_template_path
        AppSpecTemplateArtifact        = var.task_definition_template_artifact
        AppSpecTemplatePath            = var.appspec_template_path
        Image1ArtifactName             = var.image1_artifact_name
        Image1ContainerName            = var.image1_container_name

      }
    }

  }

  tags = local.module_tags

}

module "iam_role_codedeploy" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.0"
  name        = "codedeploy_${var.codepipeline_name}_iam_role"
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
  aws_service = var.codedeploy_role_service
  tags        = local.module_tags
}
