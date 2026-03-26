/*
 * # AWS codepipeline Custom module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    :  aws/modules/codepipeline_s3web/modules/custom/main.tf
#  Date        : 08 Sep 2022
#  Author      : PGE
#  Description : creation of codepipeline custom module
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

module "internal_s3web" {
  source = "../internal/"

  ##s3-artifact
  codepipeline_name = var.codepipeline_name
  codepipeline_type = "custom"
  kms_key_arn       = var.kms_key_arn

  ##codepipeline_iam_role
  #   codepipeline_role_service = var.codepipeline_role_service
  codepipeline_role_arn          = var.role_arn                       ## The IAM role is being created in the example for custom module
  artifact_store_location_bucket = var.artifact_store_location_bucket ## The S3 artifacts bucket is being created in the example for custom module
  #   artifact_location              = var.artifact_location              ## The S3 artifacts bucket is being created in the example for custom module

  ##codebuild_iam_roles
  codebuild_role_service         = var.codebuild_role_service
  custom_codebuild_policy_file   = var.custom_codebuild_policy_file
  custom_codescan_policy_file    = var.custom_codescan_policy_file
  custom_codepublish_policy_file = var.custom_codepublish_policy_file
  source_type                    = var.source_type
  s3_object_key                  = var.s3_object_key
  s3_bucket                      = var.s3_bucket

  ##codebuild_sg
  sg_name           = var.sg_name
  sg_description    = var.sg_description
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules

  ##codebuild - build
  environment_image_codebuild      = var.environment_image_codebuild
  environment_type_codebuild       = var.environment_type_codebuild
  artifact_bucket_owner_access     = var.artifact_bucket_owner_access
  github_repo_url                  = var.github_repo_url
  concurrent_build_limit_codebuild = var.concurrent_build_limit_codebuild
  compute_type_codebuild           = var.compute_type_codebuild
  cache_type_codebuild             = var.cache_type_codebuild
  cache_location_codebuild         = var.cache_location_codebuild
  cache_modes_codebuild            = var.cache_modes_codebuild
  codebuild_source_buildspec       = var.source_buildspec_codebuild
  subnet_ids                       = var.subnet_ids
  #environment variables.
  secretsmanager_artifactory_token      = var.secretsmanager_artifactory_token
  secretsmanager_artifactory_user       = var.secretsmanager_artifactory_user
  artifactory_host                      = var.artifactory_host
  artifactory_repo_key                  = var.artifactory_repo_key
  nodejs_version                        = var.nodejs_version
  nodejs_version_codescan               = var.nodejs_version_codescan
  project_root_directory                = var.project_root_directory
  build_args1                           = var.build_args1
  environment_variables_codebuild_stage = var.environment_variables_codebuild_stage
  project_name                          = var.project_name

  ##codebuild - codescan
  environment_image_codescan      = var.environment_image_codescan
  environment_type_codescan       = var.environment_type_codescan
  concurrent_build_limit_codescan = var.concurrent_build_limit_codescan
  compute_type_codescan           = var.compute_type_codescan
  cache_type_codescan             = var.cache_type_codescan
  cache_location_codescan         = var.cache_location_codescan
  cache_modes_codescan            = var.cache_modes_codescan
  #   codescan_source_buildspec       = file("${path.module}/codebuild_buildspec/buildspec_codescan.yml")
  #buildspec environment variables
  secretsmanager_sonar_token           = var.secretsmanager_sonar_token
  sonar_host                           = var.sonar_host
  github_branch                        = var.github_branch
  project_key                          = var.project_key
  project_unit_test_dir                = var.project_unit_test_dir
  environment_variables_codescan_stage = var.environment_variables_codescan_stage
  unit_test_commands                   = var.unit_test_commands

  ##codebuild - codepublish
  environment_image_codepublish      = var.environment_image_codepublish
  environment_type_codepublish       = var.environment_type_codepublish
  concurrent_build_limit_codepublish = var.concurrent_build_limit_codepublish
  compute_type_codepublish           = var.compute_type_codepublish
  cache_type_codepublish             = var.cache_type_codepublish
  cache_location_codepublish         = var.cache_location_codepublish
  cache_modes_codepublish            = var.cache_modes_codepublish
  #   codepublish_source_buildspec       = file("${path.module}/codebuild_buildspec/buildspec_codepublish.yml")
  #buildspec-codepublish environment variables
  s3_static_web_bucket_name               = var.s3_static_web_bucket_name
  aws_cloudfront_distribution_id          = var.aws_cloudfront_distribution_id
  environment_variables_codepublish_stage = var.environment_variables_codepublish_stage

  #codepipeline
  artifact_store_region                   = var.artifact_store_region
  region                                  = var.region
  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  pollchanges                             = var.pollchanges
  stages                                  = var.stages
  overwrite_s3_bucket                     = var.overwrite_s3_bucket
  tags                                    = local.module_tags
}