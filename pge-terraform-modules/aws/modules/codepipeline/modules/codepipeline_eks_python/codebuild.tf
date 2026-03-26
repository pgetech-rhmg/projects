/*
 * # AWS codepipeline for Container based python application module
 * Terraform module which creates SAF2.0 codepipeline in AWS
*/
#
#  Filename    :  aws/modules/codepipeline/modules/codepipeline_ecs_python/main.tf
#  Date        : 03 November 2022 
#  Author      : Tekyantra
#  Description : creation of codepipeline module from codepipeline_python
# 

######################################################################
#CodeBuild module for respective stages in codepipeline

locals {
  codesecret_inline_policy  = var.custom_codesecret_policy_file != null ? concat([file(var.custom_codesecret_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]
  codebuild_inline_policy   = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]
  codescan_inline_policy    = var.custom_codescan_policy_file != null ? concat([file(var.custom_codescan_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]
  codepublish_inline_policy = var.custom_codepublish_policy_file != null ? concat([file(var.custom_codepublish_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_twistlockscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_twistlockscan_iam_policy.json", {})]
}


module "codesecret_project" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.4"
  codebuild_project_name       = "codesecret_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codesecret
  environment_type             = var.environment_type_codesecret
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codesecret
  concurrent_build_limit       = var.concurrent_build_limit_codesecret
  codebuild_project_role       = module.codesecret_iam_role.arn
  compute_type                 = var.compute_type_codesecret
  tags                         = var.tags_codebuild
  cache_type                   = var.cache_type_codesecret
  cache_location               = var.cache_location_codesecret
  cache_modes                  = var.cache_modes_codesecret
  source_buildspec             = file("${path.module}/codebuild_buildspec/buildspec_secretscan.yml")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num = data.aws_caller_identity.current.id,
    partition   = data.aws_partition.current.partition,
    aws_region  = data.aws_region.current.name,
  codebuild_project_name = "codesecret_project_${var.codepipeline_name}" })
  encryption_key = var.kms_key_arn
  environment_variables = concat([
    {
      name  = "PYTHON_RUNTIME"
      value = var.python_runtime
      type  = "PLAINTEXT"
    }
  ], var.environment_variables_codesecret_stage)
}
module "codebuild_project" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.4"
  codebuild_project_name       = "codebuild_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codebuild
  environment_type             = var.environment_type_codebuild
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codebuild
  codebuild_project_role       = module.codebuild_iam_role.arn
  compute_type                 = var.compute_type_codebuild
  tags                         = var.tags_codebuild
  cache_type                   = var.cache_type_codebuild
  cache_location               = var.cache_location_codebuild
  cache_modes                  = var.cache_modes_codebuild
  source_buildspec             = var.source_buildspec_codebuild
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num = data.aws_caller_identity.current.id,
    partition   = data.aws_partition.current.partition,
    aws_region  = data.aws_region.current.name,
  codebuild_project_name = "codebuild_project_${var.codepipeline_name}" })
  encryption_key = var.kms_key_arn
  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  environment_variables = var.environment_variables_codebuild_stage
}

module "codebuild_codescan" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.4"
  codebuild_project_name       = "codescan_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codescan
  environment_type             = var.environment_type_codescan
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codescan
  concurrent_build_limit       = var.concurrent_build_limit_codescan
  codebuild_project_role       = module.codescan_iam_role.arn
  compute_type                 = var.compute_type_codescan
  tags                         = var.tags_codebuild
  cache_type                   = var.cache_type_codescan
  cache_location               = var.cache_location_codescan
  cache_modes                  = var.cache_modes_codescan
  source_buildspec             = file("${path.module}/codebuild_buildspec/buildspec_codescan.yml")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num = data.aws_caller_identity.current.id,
    partition   = data.aws_partition.current.partition,
    aws_region  = data.aws_region.current.name,
  codebuild_project_name = "codescan_project_${var.codepipeline_name}" })

  encryption_key = var.kms_key_arn
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
      name  = "ARTIFACTORY_HOST"
      value = var.artifactory_host
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY"
      value = var.artifactory_python_repo
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_TOKEN"
      value = var.secretsmanager_sonar_token
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "SONAR_HOST"
      value = var.sonar_host
      type  = "PLAINTEXT"
    },
    {
      name  = "GIT_REPO_BRANCH"
      value = var.branch
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_NAME"
      value = var.project_name
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_KEY"
      value = var.project_key
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "PYTHON_RUNTIME"
      value = var.python_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "UNIT_TEST_COMMANDS"
      value = var.unit_test_commands
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    }
  ], var.environment_variables_codescan_stage)
}

module "codebuild_twistlock" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.4"
  codebuild_project_name       = "twistlock_scanning_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codepublish
  environment_type             = var.environment_type_codepublish
  environment_privileged_mode  = var.privileged_mode_twistlockscan
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codepublish
  concurrent_build_limit       = var.concurrent_build_limit_codepublish
  codebuild_project_role       = module.codepublish_iam_role.arn
  compute_type                 = var.compute_type_codepublish
  tags                         = var.tags_codebuild
  cache_type                   = var.cache_type_twistlock
  cache_location               = var.cache_location_twistlock
  cache_modes                  = var.cache_modes_twistlock
  source_buildspec             = file("${path.module}/codebuild_buildspec/buildspec_twistlockscan.yml")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id,
    partition              = data.aws_partition.current.partition,
    aws_region             = data.aws_region.current.name,
    codebuild_project_name = "twistlock_scanning_${var.codepipeline_name}"
  })

  encryption_key = var.kms_key_arn

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
      name  = "ARTIFACTORY_HOST"
      value = var.artifactory_host
      type  = "PLAINTEXT"
    },
    {
      name  = "HELMCHART_LOCAL_REPO"
      value = var.artifactory_helm_local_repo
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_DOCKER_REGISTRY"
      value = var.artifactory_docker_registry
      type  = "PLAINTEXT"
    },
    {
      name  = "TWISTLOCK_USER_ID"
      value = var.secretsmanager_twistlock_user_id
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "TWISTLOCK_USER_TOKEN"
      value = var.secretsmanager_twistlock_token
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "TWISTLOCK_CONSOLE"
      value = var.twistlock_console
      type  = "PLAINTEXT"
    },
    {
      name  = "PYTHON_RUNTIME"
      value = var.python_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = var.aws_account_number
      type  = "PLAINTEXT"
    },
    {
      name  = "ACM_SSL_ARN"
      value = var.acm_certificate_arn
      type  = "PLAINTEXT"
    },

    {
      name  = "CUSTOM_DOMAIN_NAME"
      value = var.custom_domain_name
      type  = "PLAINTEXT"
    },

    {
      name  = "CONTAINER_NAME"
      value = var.container_name
      type  = "PLAINTEXT"
    },

    {
      name  = "VERSION_FILE"
      value = var.version_file
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
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    },

    {
      name  = "APP_OWNERS"
      value = var.app_owners
      type  = "PLAINTEXT"
    },
    {
      name  = "IMAGE_TYPE"
      value = var.image_type
      type  = "PLAINTEXT"
    }

  ], var.environment_variables_twistlock_stage)
}

##############################################################################
#security greoup for codebuild projects
module "security-group" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name              = var.sg_name
  description       = var.sg_description
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = var.tags_codebuild
}

################################################################################
#iam_role module for codebuild project in stage 2 - codescrets
module "codesecret_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codesecret_project_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = var.tags_codebuild
  #inline_policy
  inline_policy = local.codesecret_inline_policy
}

################################################################################
#iam_role module for codebuild project in stage 2 - codebuild
module "codebuild_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codebuild_project_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = var.tags_codebuild
  #inline_policy
  inline_policy = local.codebuild_inline_policy
}

#################################################################################
#iam_role module for codebuild project in stage 3 - codescan
module "codescan_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codescan_project_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = var.tags_codebuild
  #inline_policy
  inline_policy = local.codescan_inline_policy
}

#################################################################################
#iam_role module for codebuild project in stage 4 - codepublish
module "codepublish_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "twistlock_scanning_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = var.tags_codebuild
  #inline_policy
  inline_policy = local.codepublish_inline_policy
}
