/*
 * # AWS Codebuild module creating Codebuild project
 * Terraform module which creates SAF2.0 Codebuild in AWS.
*/
#
# Filename    : aws/modules/codebuild/modules/codebuild_project/main.tf
# Date        : 20/04/2022
# Author      : TCS
# Description : AWS Codebuild project module main

### AWS Secrets Manager - GitHub Token
# For testing this example, you need to create a GitHub token and store it in AWS Secrets Manager.
# Provide the **ARN** of the secret in the variable "secretsmanager_github_token_secret_arn".
#
# Note: Previously, this variable used the secret name. It has now been updated to use the full ARN.
#
# Steps to create the secret in AWS Secrets Manager:
# 1. Create a plain text secret with the following key-value pairs:
#    - ServerType = GITHUB
#    - AuthType = PERSONAL_ACCESS_TOKEN
#    - Token = "your_personal_access_token"


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
  namespace        = "ccoe-tf-developers"
  github_token_arn = var.codebuild_sc_token
  auth_type        = "PERSONAL_ACCESS_TOKEN"
  server_type      = "GITHUB"
  Token            = var.codebuild_sc_token
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags              = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  is_dc_public_or_internal = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false
}



data "aws_secretsmanager_secret" "github_token" {
  arn = var.codebuild_sc_token
}


data "external" "validate_kms" {
  count   = (!local.is_dc_public_or_internal && var.encryption_key == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo codebuild project kms key id is mandatory for the DataClassfication type; exit 1"]
}

resource "aws_codebuild_project" "codebuild_project" {

  name                   = var.codebuild_project_name
  service_role           = var.codebuild_project_role
  badge_enabled          = var.badge_enabled
  build_timeout          = var.codebuild_project_build_timeout
  concurrent_build_limit = var.concurrent_build_limit
  description            = var.codebuild_project_description
  encryption_key         = var.encryption_key
  project_visibility     = var.project_visibility
  resource_access_role   = var.resource_access_role
  queued_timeout         = var.queued_timeout
  source_version         = var.source_version
  tags                   = local.module_tags

  artifacts {
    artifact_identifier    = var.artifact_identifier
    bucket_owner_access    = var.artifact_bucket_owner_access
    encryption_disabled    = false
    location               = var.artifact_location
    name                   = var.artifact_name
    namespace_type         = var.artifact_namespace_type
    override_artifact_name = var.artifact_override_name
    packaging              = var.artifact_packaging
    path                   = var.artifact_path
    type                   = var.artifact_type
  }

  environment {
    certificate                 = var.environment_certificate
    compute_type                = var.compute_type
    image_pull_credentials_type = var.image_pull_credentials_type
    image                       = var.environment_image
    privileged_mode             = var.environment_privileged_mode
    type                        = var.environment_type

    #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = lookup(environment_variable.value, "type", null)
      }
    }

    #This block will be executed only if the variable 'environment_credential' is not empty.
    dynamic "registry_credential" {
      for_each = var.environment_credential != null ? [true] : []
      content {
        credential          = var.environment_credential
        credential_provider = "SECRETS_MANAGER"
      }
    }
  }

  source {
    buildspec           = var.source_buildspec
    git_clone_depth     = var.source_git_clone_depth
    insecure_ssl        = false
    location            = var.source_location
    report_build_status = var.source_report_build_status
    type                = var.source_type

    auth {
      type     = "SECRETS_MANAGER"
      resource = var.codebuild_sc_token
    }

    #This block will be executed only if the variable 'source_type' is equal to "GITHUB_ENTERPRISE"
    dynamic "git_submodules_config" {
      for_each = var.source_type == "GITHUB_ENTERPRISE" ? [true] : []
      content {
        fetch_submodules = var.source_fetch_sub
      }
    }
  }

  #This block will be executed only if the variable 'build_batch_service_role' is not empty.
  dynamic "build_batch_config" {
    for_each = var.build_batch_service_role != null ? [true] : []
    content {
      combine_artifacts = var.build_batch_artifacts
      service_role      = var.build_batch_service_role
      timeout_in_mins   = var.build_batch_timeout
      dynamic "restrictions" {
        for_each = var.compute_types_allowed != [] ? [true] : []
        content {
          compute_types_allowed  = var.compute_types_allowed
          maximum_builds_allowed = var.maximum_builds_allowed
        }
      }
    }
  }

  dynamic "cache" {
    for_each = var.cache_type != null ? [true] : []
    content {
      type     = var.cache_type
      location = var.cache_type == "S3" ? var.cache_location : null   #Required when cache type is S3
      modes    = var.cache_type == "LOCAL" ? [var.cache_modes] : null #Required when cache type is LOCAL
    }
  }

  dynamic "file_system_locations" {
    for_each = length(keys(var.file_system_locations)) == 0 ? [] : [var.file_system_locations]
    content {
      identifier    = lookup(file_system_locations.value, "identifier", null)
      location      = lookup(file_system_locations.value, "location", null)
      mount_options = lookup(file_system_locations.value, "mount_options", null)
      mount_point   = lookup(file_system_locations.value, "mount_point", null)
      type          = "EFS"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_logs_group_name
      status      = "ENABLED"
      stream_name = var.cloudwatch_logs_stream_name
    }

    #This block will be executed only if the variable 's3_location' is not empty.
    dynamic "s3_logs" {
      for_each = var.s3_location != null ? [true] : []
      content {
        encryption_disabled = false
        location            = var.s3_location
        status              = var.s3_logs_status
        bucket_owner_access = var.s3_bucket_owner_access
      }
    }
  }

  #It will support multiple secondary artifacts. We can pass multiple values through the varable "secondary_artifacts"
  # artifact_identifier & type are required arguments for this block
  dynamic "secondary_artifacts" {
    for_each = var.secondary_artifacts
    content {
      artifact_identifier    = secondary_artifacts.value.artifact_identifier
      bucket_owner_access    = lookup(secondary_artifacts.value, "bucket_owner_access", null)
      encryption_disabled    = lookup(secondary_artifacts.value, "encryption_disabled", null)
      location               = lookup(secondary_artifacts.value, "location", null)
      name                   = lookup(secondary_artifacts.value, "name", null)
      namespace_type         = lookup(secondary_artifacts.value, "namespace_type", null)
      override_artifact_name = lookup(secondary_artifacts.value, "override_artifact_name", null)
      packaging              = lookup(secondary_artifacts.value, "packaging", null)
      path                   = lookup(secondary_artifacts.value, "path", null)
      type                   = secondary_artifacts.value.type
    }
  }

  #It will support multiple secondary sources. We can pass multiple values through the varable "secondary_sources"
  dynamic "secondary_sources" {
    for_each = var.secondary_sources
    content {
      buildspec           = lookup(secondary_sources.value, "buildspec", null)
      git_clone_depth     = lookup(secondary_sources.value, "git_clone_depth", null)
      insecure_ssl        = lookup(secondary_sources.value, "insecure_ssl", false)
      location            = lookup(secondary_sources.value, "location", null)
      report_build_status = lookup(secondary_sources.value, "report_build_status", null)
      type                = secondary_sources.value.type
      source_identifier   = secondary_sources.value.source_identifier

      #This block will be executed only if the argument 'type' is equal to "GITHUB_ENTERPRISE"
      dynamic "git_submodules_config" {
        for_each = secondary_sources.value.type == "GITHUB_ENTERPRISE" ? [true] : []
        content {
          fetch_submodules = lookup(secondary_sources.value, "fetch_submodules", false)
        }
      }

      dynamic "build_status_config" {
        for_each = var.build_status_config
        content {
          context    = lookup(build_status_config.value, "context", null)
          target_url = lookup(build_status_config.value, "target_url", null)
        }
      }
    }
  }

  dynamic "secondary_source_version" {
    for_each = var.secondary_source_version
    content {
      source_version    = lookup(secondary_source_version.value, "source_version", null)
      source_identifier = lookup(secondary_source_version.value, "source_identifier", null)
    }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_codebuild_resource_policy" "codebuild_resource_policy" {
  resource_arn = aws_codebuild_project.codebuild_project.arn
  policy       = var.codebuild_resource_policy
}

