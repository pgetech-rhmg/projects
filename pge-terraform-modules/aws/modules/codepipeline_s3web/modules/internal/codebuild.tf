# # ################################################################################
# # # Supporting Resources
# # ################################################################################
# 
data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  codebuild_inline_policy     = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]
  codescan_inline_policy      = var.custom_codescan_policy_file != null ? concat([file(var.custom_codescan_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codescan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codescan_iam_policy.json", {})]
  codepublish_inline_policy   = var.custom_codepublish_policy_file != null ? concat([file(var.custom_codepublish_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codepublish_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codepublish_iam_policy.json", {})]
  s3_static_web_bucket_region = data.aws_s3_bucket.s3web.region

  is_package_manager_npm     = var.package_manager == "npm" ? true : false
  codebuild_npm_buildspec    = file("${path.module}/codebuild_buildspec/buildspec_codebuild.yml")
  codebuild_yarn_buildspec   = file("${path.module}/codebuild_buildspec/buildspec_codebuild_with_yarn.yml")
  codebuild_source_buildspec = local.is_package_manager_npm ? local.codebuild_npm_buildspec : local.codebuild_yarn_buildspec
  sonar_tags                 = jsonencode(merge(var.tags, var.optional_tags))
  codebuild_source_type      = lower(var.source_type) == "github" ? "GITHUB" : var.source_type
  codebuild_sc_token = data.aws_secretsmanager_secret.github_token.arn
}
# 
###########################################################################
#CodeBuild module for respective stages in codepipeline
module "codebuild_project" {

  count                        = var.codepipeline_type != "html" ? 1 : 0 ## This module won't be executed for HTML app
  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "codebuild_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codebuild
  environment_type             = var.environment_type_codebuild
  artifact_location            = var.codepipeline_type != "custom" ? module.s3[0].id : var.artifact_store_location_bucket
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  source_location              = var.github_repo_url
  concurrent_build_limit       = var.concurrent_build_limit_codebuild
  codebuild_project_role       = module.codebuild_iam_role[0].arn
  compute_type                 = var.compute_type_codebuild
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codebuild
  cache_location               = var.cache_location_codebuild
  cache_modes                  = var.cache_modes_codebuild
  #source_buildspec             = var.codebuild_source_buildspec ## The buildspec file is present in the calling module
  source_buildspec          = var.codepipeline_type != "custom" ? local.codebuild_source_buildspec : var.codebuild_source_buildspec
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [module.security-group.sg_id]
  codebuild_sc_token        = local.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", { account_num = data.aws_caller_identity.current.account_id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = "codebuild_project_${var.codepipeline_name}" })
  encryption_key            = local.kms_key_arn
  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  environment_variables = var.codepipeline_type == "custom" ? var.environment_variables_codebuild_stage : concat([
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
      value = var.artifactory_repo_key
      type  = "PLAINTEXT"
    },
    {
      name  = "NODEJS_VERSION"
      value = var.nodejs_version
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_NAME"
      value = var.project_name
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "BUILD_ENV"
      value = var.build_args1
      type  = "PLAINTEXT"
    },
    {
      name  = "CODEPIPELINE_TYPE"
      value = var.codepipeline_type
      type  = "PLAINTEXT"
    }
  ], var.environment_variables_codebuild_stage)
}

module "codebuild_codescan" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "codescan_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  artifact_location            = var.codepipeline_type != "custom" ? module.s3[0].id : var.artifact_store_location_bucket
  environment_image            = var.environment_image_codescan
  environment_type             = var.environment_type_codescan
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  source_location              = var.github_repo_url

  concurrent_build_limit = var.concurrent_build_limit_codescan
  codebuild_project_role = module.codescan_iam_role.arn
  compute_type           = var.compute_type_codescan
  tags                   = merge(var.tags, { pge_team = local.namespace })
  cache_type             = var.cache_type_codescan
  cache_location         = var.cache_location_codescan
  cache_modes            = var.cache_modes_codescan
  #   source_buildspec          = var.codescan_source_buildspec ## The buildspec file is present in the calling module
  source_buildspec          = file("${path.module}/codebuild_buildspec/buildspec_codescan.yml")
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [module.security-group.sg_id]
  codebuild_sc_token        = local.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", { account_num = data.aws_caller_identity.current.account_id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = "codescan_project_${var.codepipeline_name}" })
  encryption_key            = local.kms_key_arn
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
      name  = "ARTIFACTORY_REPO_KEY"
      value = var.artifactory_repo_key
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_HOST"
      value = var.artifactory_host
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
      name  = "SONAR_PROJECT_TAGS"
      value = local.sonar_tags
      type  = "PLAINTEXT"
    },
    {
      name  = "GIT_REPO_BRANCH"
      value = var.github_branch
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
      name  = "UNIT_TEST_COMMANDS"
      value = var.unit_test_commands
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_UNIT_TEST_DIRECTORY"
      value = var.project_unit_test_dir
      type  = "PLAINTEXT"
    },
    {
      name  = "NODEJS_VERSION_CODESCAN"
      value = var.nodejs_version_codescan
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "BUILD_ENV"
      value = var.build_args1
      type  = "PLAINTEXT"
    }
  ], var.environment_variables_codescan_stage)
}

module "codebuild_codepublish" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "codepublish_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_location            = var.codepipeline_type != "custom" ? module.s3[0].id : var.artifact_store_location_bucket
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codepublish
  environment_type             = var.environment_type_codepublish
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  source_location              = var.github_repo_url
  concurrent_build_limit       = var.concurrent_build_limit_codepublish
  codebuild_project_role       = module.codepublish_iam_role.arn
  compute_type                 = var.compute_type_codepublish
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codepublish
  cache_location               = var.cache_location_codepublish
  cache_modes                  = var.cache_modes_codepublish
  #   source_buildspec             = var.codepublish_source_buildspec ## The buildspec file is present in the calling module 
  source_buildspec          = file("${path.module}/codebuild_buildspec/buildspec_codepublish.yml")
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  security_group_ids        = [module.security-group.sg_id]
  codebuild_sc_token        = local.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", { account_num = data.aws_caller_identity.current.account_id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = "codepublish_project_${var.codepipeline_name}" })
  encryption_key            = local.kms_key_arn
  #buildspec environment variables: custom variable values are provided by the user to execute phases inside buildspec file.
  environment_variables = concat([
    #     {
    #       name  = "ARTIFACTORY_TOKEN"
    #       value = var.secretsmanager_artifactory_token
    #       type  = "SECRETS_MANAGER"
    #     },
    #     {
    #       name  = "ARTIFACTORY_USER"
    #       value = var.secretsmanager_artifactory_user
    #       type  = "SECRETS_MANAGER"
    #     },
    {
      name  = "ARTIFACTORY_HOST"
      value = var.artifactory_host
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY"
      value = var.artifactory_repo_key
      type  = "PLAINTEXT"
    },
    {
      name  = "NODEJS_VERSION"
      value = var.nodejs_version
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "GIT_REPO_BRANCH"
      value = var.github_branch
      type  = "PLAINTEXT"
    },
    {
      name  = "GIT_REPO_URL"
      value = var.github_repo_url
      type  = "PLAINTEXT"
    },
    {
      name  = "S3_STATIC_WEB_BUCKET"
      value = var.s3_static_web_bucket_name
      type  = "PLAINTEXT"
    },
    {
      name  = "S3_STATIC_WEB_BUCKET_REGION"
      value = local.s3_static_web_bucket_region
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_NAME"
      value = var.project_name
      type  = "PLAINTEXT"
    },
    {
      name  = "S3_WEB_CLOUDFRONT_DISTRIBUTION_ID"
      value = var.aws_cloudfront_distribution_id
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "BUILD_ENV"
      value = var.build_args1
      type  = "PLAINTEXT"
    },
    {
      name  = "CODEPIPELINE_TYPE"
      value = var.codepipeline_type
      type  = "PLAINTEXT"
    },
    {
      name  = "OVERWRITE_S3_BUCKET"
      value = var.overwrite_s3_bucket
      type  = "PLAINTEXT"
    },

  ], var.environment_variables_codepublish_stage)
}

# ##############################################################################
#security group for codebuild projects
module "security-group" {
  source            = "app.terraform.io/pgetech/security-group/aws"
  version           = "0.1.0"
  name              = var.sg_name
  description       = var.sg_description
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(var.tags, { pge_team = local.namespace })
}

################################################################################
#iam_role module for codebuild project in stage 2 - codebuild
module "codebuild_iam_role" {
  count   = var.codepipeline_type != "html" ? 1 : 0 ## This module won't be executed for HTML
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name          = "codebuild_project_${var.codepipeline_name}_iam_role" #var.codebuild_role_name
  aws_service   = var.codebuild_role_service
  tags          = merge(var.tags, { pge_team = local.namespace })
  inline_policy = local.codebuild_inline_policy

}

#################################################################################
#iam_role module for codebuild project in stage 3 - codescan
module "codescan_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name          = "codescan_project_${var.codepipeline_name}_iam_role" #var.codescan_role_name
  aws_service   = var.codebuild_role_service
  tags          = merge(var.tags, { pge_team = local.namespace })
  inline_policy = local.codescan_inline_policy
}

#################################################################################
#iam_role module for codebuild project in stage 4 - codepublish
module "codepublish_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name          = "codepublish_project_${var.codepipeline_name}_iam_role" #var.codepublish_role_name
  aws_service   = var.codebuild_role_service
  tags          = merge(var.tags, { pge_team = local.namespace })
  inline_policy = local.codepublish_inline_policy
}

#################################################################################
