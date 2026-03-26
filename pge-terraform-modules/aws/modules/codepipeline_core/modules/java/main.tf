/*
 * # AWS codepipeline module for java
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#  Filename    : aws/modules/codepipeline_core/modules/nodejs/main.tf
#  Date        : 04 Oct 2024
#  Author      : PGE
#  Description : The terraform module creates a codepipeline for Java application

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
  namespace     = "ccoe-tf-developers"
  github_branch = var.branch
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.encryption_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
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

module "internal_core" {
  source = "../internal/"

  codebuildapp_language = "java"

  ##codepipeline
  codepipeline_name              = var.codepipeline_name
  role_arn                       = var.role_arn
  artifact_store_location_bucket = var.artifact_store_location_bucket
  artifact_store_region          = var.artifact_store_region
  encryption_key_id              = var.encryption_key_id
  region                         = var.region
  repo_name                      = var.repo_name
  branch                         = var.branch
  pollchanges                    = var.pollchanges
  stages                         = var.stages
  source_type                    = var.source_type
  s3_object_key                  = var.s3_object_key
  s3_bucket                      = var.s3_bucket

  ##codebuild

  custom_codebuild_policy_file            = var.custom_codebuild_policy_file
  custom_codescan_policy_file             = var.custom_codescan_policy_file
  custom_codepublish_policy_file          = var.custom_codepublish_policy_file
  custom_codedownload_policy_file         = var.custom_codedownload_policy_file
  environment_image_codebuild             = var.environment_image_codebuild
  environment_type_codebuild              = var.environment_type_codebuild
  artifact_location                       = var.artifact_location
  artifact_bucket_owner_access            = var.artifact_bucket_owner_access
  artifact_path                           = var.artifact_path
  source_location_codebuild               = var.source_location_codebuild
  source_location_codepublish             = var.source_location_codepublish
  source_location_codescan                = var.source_location_codescan
  concurrent_build_limit_codebuild        = var.concurrent_build_limit_codebuild
  compute_type_codebuild                  = var.compute_type_codebuild
  cache_type_codebuild                    = var.cache_type_codebuild
  cache_location_codebuild                = var.cache_location_codebuild
  cache_modes_codebuild                   = var.cache_modes_codebuild
  source_buildspec_codebuild              = var.source_buildspec_codebuild
  vpc_id                                  = var.vpc_id
  subnet_ids                              = var.subnet_ids
  environment_variables_codebuild_stage   = var.environment_variables_codebuild_stage
  environment_image_codescan              = var.environment_image_codescan
  environment_type_codescan               = var.environment_type_codescan
  concurrent_build_limit_codescan         = var.concurrent_build_limit_codescan
  compute_type_codescan                   = var.compute_type_codescan
  cache_type_codescan                     = var.cache_type_codescan
  cache_location_codescan                 = var.cache_location_codescan
  cache_modes_codescan                    = var.cache_modes_codescan
  environment_variables_codescan_stage    = var.environment_variables_codescan_stage
  environment_image_codepublish           = var.environment_image_codepublish
  environment_type_codepublish            = var.environment_type_codepublish
  concurrent_build_limit_codepublish      = var.concurrent_build_limit_codepublish
  compute_type_codepublish                = var.compute_type_codepublish
  cache_type_codepublish                  = var.cache_type_codepublish
  cache_location_codepublish              = var.cache_location_codepublish
  cache_modes_codepublish                 = var.cache_modes_codepublish
  environment_variables_codepublish_stage = var.environment_variables_codepublish_stage
  kms_key_arn                             = var.kms_key_arn
  sg_name                                 = var.sg_name
  sg_description                          = var.sg_description
  cidr_egress_rules                       = var.cidr_egress_rules
  codebuild_role_service                  = var.codebuild_role_service

  artifactory_host                 = var.artifactory_host
  sonar_host                       = var.sonar_host
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  project_key                      = var.project_key
  github_org                       = var.github_org
  artifactory_repo_name            = var.artifactory_repo_name

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  secretsmanager_artifactory_user         = var.secretsmanager_artifactory_user
  secretsmanager_sonar_token              = var.secretsmanager_sonar_token
  github_repo_url                         = var.github_repo_url
  project_name                            = var.project_name
  project_root_directory                  = var.project_root_directory

  java_runtime          = var.java_runtime
  java_runtime_codescan = var.java_runtime_codescan
  unit_test_commands    = var.unit_test_commands
  github_branch         = local.github_branch



  # sonar_scanner_cli_version               = var.sonar_scanner_cli_version
  # lambda_function_name                    = var.lambda_function_name
  # lambda_alias_name                       = var.lambda_alias_name
  # lambda_update                           = var.lambda_update
  # dependency_files_location               = var.dependency_files_location

  download_artifact                        = var.download_artifact
  sonar_branch_scanned                     = var.sonar_branch_scanned
  environment_image_codedownload           = var.environment_image_codedownload
  environment_type_codedownload            = var.environment_type_codedownload
  source_location_codedownload             = var.source_location_codedownload
  concurrent_build_limit_codedownload      = var.concurrent_build_limit_codedownload
  compute_type_codedownload                = var.compute_type_codedownload
  environment_variables_codedownload_stage = var.environment_variables_codedownload_stage
  cache_type_codedownload                  = var.cache_type_codedownload
  cache_location_codedownload              = var.cache_location_codedownload
  cache_modes_codedownload                 = var.cache_modes_codedownload

  tags = local.module_tags
}