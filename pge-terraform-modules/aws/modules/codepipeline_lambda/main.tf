/*
 * # AWS codepipeline lambda module for Python
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    : aws/modules/codepipeline_lambda/main.tf
#  Date        : 06 June 2024
#  Author      : PGE
#  Description : The terraform module creates a codepipeline for Lambda Python
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
  namespace = "ccoe-tf-developers"
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

module "internal_lambda" {
  source = "./modules/internal/"

  codebuildapp_language = "python"

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
  environment_image_codebuild             = var.environment_image_codebuild
  environment_type_codebuild              = var.environment_type_codebuild
  artifact_location                       = var.artifact_location
  artifact_bucket_owner_access            = var.artifact_bucket_owner_access
  artifact_path                           = var.artifact_path
  source_location_codebuild               = var.source_location_codebuild
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
  dependency_files_location               = var.dependency_files_location
  artifactory_host                        = var.artifactory_host
  github_branch                           = var.github_branch
  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  secretsmanager_artifactory_user         = var.secretsmanager_artifactory_user
  secretsmanager_sonar_token              = var.secretsmanager_sonar_token
  github_repo_url                         = var.github_repo_url
  project_name                            = var.project_name
  project_root_directory                  = var.project_root_directory
  python_runtime                          = var.python_runtime
  sonar_host                              = var.sonar_host
  sonar_scanner_cli_version               = var.sonar_scanner_cli_version
  artifactory_repo_name                   = var.artifactory_repo_name
  secretsmanager_artifactory_token        = var.secretsmanager_artifactory_token
  unit_test_commands                      = var.unit_test_commands
  project_key                             = var.project_key
  lambda_function_name                    = var.lambda_function_name
  github_org                              = var.github_org
  lambda_alias_name                       = var.lambda_alias_name
  lambda_update                           = var.lambda_update
  include_lib_files                       = var.include_lib_files

  tags = local.module_tags
}