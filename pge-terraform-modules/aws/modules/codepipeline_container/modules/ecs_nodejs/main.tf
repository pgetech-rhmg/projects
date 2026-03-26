/*
 * # AWS codepipeline ECS module for nodejs
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    : aws/modules/codepipeline_container/modules/ecs_nodejs/main.tf
#  Date        : 12/31/2024
#  Author      : PGE
#  Description : The terraform module creates a codepipeline for ECS nodejs
#
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
  namespace        = "ccoe-tf-developers"
  artifactory_repo = coalesce(var.artifactory_nodejs_repo, var.artifactory_repo_name)
  build            = coalesce(var.node_build, var.build_command)
  runtime          = coalesce(var.node_runtime, var.runtime_version)

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

#Module : Codepipeline
#Description : This terraform module creates codepipeline
module "internal_container" {
  source = "../internal/"

  codebuildapp_language = "nodejs"

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
  codedeploy_provider            = var.codedeploy_provider
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
  kms_key_arn                             = var.kms_key_arn
  sg_name                                 = var.sg_name
  sg_description                          = var.sg_description
  cidr_egress_rules                       = var.cidr_egress_rules
  codebuild_role_service                  = var.codebuild_role_service
  artifactory_host                        = var.artifactory_host
  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  secretsmanager_artifactory_user         = var.secretsmanager_artifactory_user
  secretsmanager_sonar_token              = var.secretsmanager_sonar_token
  project_name                            = var.project_name
  project_root_directory                  = var.project_root_directory
  node_runtime                            = var.node_runtime
  sonar_host                              = var.sonar_host
  secretsmanager_artifactory_token        = var.secretsmanager_artifactory_token
  project_key                             = var.project_key
  unit_test_commands                      = var.unit_test_commands
  github_org                              = var.github_org
  artifactory_docker_registry             = var.artifactory_docker_registry
  concurrent_build_limit_codesecret       = var.concurrent_build_limit_codebuild
  secretsmanager_wiz_client_id            = var.secretsmanager_wiz_client_id
  secretsmanager_wiz_client_secret        = var.secretsmanager_wiz_client_secret
  aws_account_number                      = var.aws_account_number
  container_name                          = var.container_name
  environment_type_codesecret             = var.environment_type_codesecret
  source_location_codepublish             = var.source_location_codepublish
  environment_image_codesecret            = var.environment_image_codesecret
  compute_type_codesecret                 = var.compute_type_codesecret
  source_location_codescan                = var.source_location_codescan
  cidr_egress_rules_SNS_codestar          = var.cidr_egress_rules_SNS_codestar
  codestar_lambda_encryption_key_id       = var.codestar_lambda_encryption_key_id
  source_location_codesecret              = var.source_location_codesecret
  publish_docker_registry                 = var.publish_docker_registry
  tags_codebuild                          = var.tags_codebuild
  artifactory_repo_name                   = local.artifactory_repo
  version_file                            = var.version_file
  node_build                              = local.build
  nodejs_runtime_codescan                 = var.nodejs_runtime_codescan
  endpoint_email                          = var.endpoint_email
  privileged_mode_wizscan                 = var.privileged_mode_wizscan
  is_eks_fargate                          = var.is_eks_fargate
  AppID                                   = var.AppID
  tags                                    = local.module_tags
}
