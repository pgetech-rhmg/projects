/*
 * # AWS codepipeline for Container based rollback pipelines for ECS workloads
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    :  aws/modules/codepipeline_container/modules/ecs_rollback/codebuild.tf
#  Date        : 12-19-2022
#  Author      : Tekyantra
#  Description : creation of codepipeline module from codepipeline_ecs_rollback
#

######################################################################

locals {
  codebuild_rollback_inline_policy = var.custom_codebuild_rollback_policy_file != null ? concat([file(var.custom_codebuild_rollback_policy_file)], [templatefile("${path.module}/../internal/codebuild_iam_policies/codebuild_rollback_iam_policy.json", {})]) : [templatefile("${path.module}/../internal/codebuild_iam_policies/codebuild_rollback_iam_policy.json", {})]
}

module "codebuild_rollback_config" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "wiz_scanning_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codepublish
  environment_type             = var.environment_type_codepublish
  environment_privileged_mode  = var.privileged_mode_wizscan
  artifact_location            = var.artifact_store_location_bucket
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codepublish
  concurrent_build_limit       = var.concurrent_build_limit_codepublish
  codebuild_project_role       = module.wiz_scan_iam_role.arn
  compute_type                 = var.compute_type_codepublish
  tags                         = var.tags_codebuild
  cache_type                   = var.cache_type_rollback_config
  cache_location               = var.cache_location_rollback_config
  cache_modes                  = var.cache_modes_rollback_config
  source_buildspec             = file("${path.module}/codebuild_buildspec/buildspec_prepare_rollback.yml")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = data.aws_secretsmanager_secret.github_token.arn
  codebuild_resource_policy = templatefile("${path.module}/../internal/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id,
    partition              = data.aws_partition.current.partition,
    aws_region             = data.aws_region.current.name,
    codebuild_project_name = "wiz_scanning_${var.codepipeline_name}"
  })

  encryption_key = var.encryption_key_id

  #buildspec environment variables
  environment_variables = concat([
    {
      name  = "ARTIFACTORY_TOKEN"
      value = var.secretsmanager_artifactory_token
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "ARTIFACTORY_USER"
      value = var.secretsmanager_artifactory_user
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "ARTIFACTORY_DOCKER_REGISTRY"
      value = var.artifactory_docker_registry
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = var.aws_account_number
      type  = "PLAINTEXT"
    },

    {
      name  = "APPLICATION_NAME"
      value = var.application_name
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_REGION"
      value = var.region
      type  = "PLAINTEXT"
    },

    {
      name  = "PUBLISH_DOCKER_REGISTRY"
      value = var.publish_docker_registry
      type  = "PLAINTEXT"
    },

    {
      name  = "CODEDEPLOY_PROVIDER"
      value = var.codedeploy_provider
      type  = "PLAINTEXT"
    },

    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    }
    ,
    {
      name  = "ROLLBACK_IMAGE_TAG"
      value = var.rollback_image_tag
      type  = "PLAINTEXT"
    },
  ], var.environment_variables_rollback_config)
}

##############################################################################
#security greoup for codebuild projects
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name              = "sg_codepipeline_${var.codepipeline_name}"
  description       = "security group for sg_codepipeline_${var.codepipeline_name}"
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = var.tags_codebuild
}

#################################################################################
#iam_role module for codebuild project in stage 4 - codepublish
module "wiz_scan_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "wiz_scanning_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = var.tags_codebuild
  #inline_policy
  inline_policy = local.codebuild_rollback_inline_policy
}
