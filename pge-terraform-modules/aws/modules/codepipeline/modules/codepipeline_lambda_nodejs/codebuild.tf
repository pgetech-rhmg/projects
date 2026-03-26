################################################################################
# Supporting Resources
################################################################################
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  codebuild_inline_policy   = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]
  codescan_inline_policy    = var.custom_codescan_policy_file != null ? concat([file(var.custom_codescan_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]
  codepublish_inline_policy = var.custom_codepublish_policy_file != null ? concat([file(var.custom_codepublish_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildpublish_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildpublish_iam_policy.json", {})]
}


######################################################################
#CodeBuild module for respective stages in codepipeline
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
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codebuild
  cache_location               = var.cache_location_codebuild
  cache_modes                  = var.cache_modes_codebuild
  source_buildspec             = var.source_buildspec_codebuild
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id,
    partition              = data.aws_partition.current.partition,
    aws_region             = data.aws_region.current.name,
    codebuild_project_name = "codebuild_project_${var.codepipeline_name}"
  })
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
  source_location              = var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codescan
  codebuild_project_role       = module.codescan_iam_role.arn
  compute_type                 = var.compute_type_codescan
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codescan
  cache_location               = var.cache_location_codescan
  cache_modes                  = var.cache_modes_codescan
  source_buildspec             = file("${path.module}/codebuild_buildspec/buildspec_codescan.yml")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id,
    partition              = data.aws_partition.current.partition,
    aws_region             = data.aws_region.current.name,
    codebuild_project_name = "codescan_project_${var.codepipeline_name}"
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
      name  = "ARTIFACTORY_REPO_KEY"
      value = var.artifactory_repo_name
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_KEY"
      value = var.project_key
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_HOST"
      value = var.sonar_host
      type  = "PLAINTEXT"
    },
    {
      name  = "GIT_REPO_BRANCH"
      value = var.github_branch
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_TOKEN"
      value = var.secretsmanager_sonar_token
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "PROJECT_NAME"
      value = var.project_name
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
    },
    {
      name  = "NODE_RUNTIME_CODESCAN"
      value = var.node_runtime_codescan
      type  = "PLAINTEXT"
    },
  ], var.environment_variables_codescan_stage)
}

module "codebuild_codepublish" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.4"
  codebuild_project_name       = "codepublish_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codepublish
  environment_type             = var.environment_type_codepublish
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codepublish
  codebuild_project_role       = module.codepublish_iam_role.arn
  compute_type                 = var.compute_type_codepublish
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codepublish
  cache_location               = var.cache_location_codepublish
  cache_modes                  = var.cache_modes_codepublish
  source_buildspec             = file("${path.module}/codebuild_buildspec/buildspec_codepublish.yml")
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = var.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num            = data.aws_caller_identity.current.id,
    partition              = data.aws_partition.current.partition,
    aws_region             = data.aws_region.current.name,
    codebuild_project_name = "codepublish_project_${var.codepipeline_name}"
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
      name  = "GIT_REPO_BRANCH"
      value = var.github_branch
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY"
      value = var.artifactory_repo_name
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_HOST"
      value = var.artifactory_host
      type  = "PLAINTEXT"
    },
    {
      name  = "DEPENDENCY_FILES_LOCATION"
      value = var.dependency_files_location
      type  = "PLAINTEXT"
    },
    {
      name  = "NODE_RUNTIME"
      value = var.node_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "LAMBDA_UPDATE"
      value = var.lambda_update
      type  = "PLAINTEXT"
    },
    {
      name  = "LAMBDA_FUNCTION_NAME"
      value = var.lambda_function_name
      type  = "PLAINTEXT"
    },
    {
      name  = "LAMBDA_ALIAS_NAME"
      value = var.lambda_alias_name
      type  = "PLAINTEXT"
    }
  ], var.environment_variables_codepublish_stage)
}

##############################################################################
#security greoup for codebuild projects
module "security-group" {
  source            = "app.terraform.io/pgetech/security-group/aws"
  version           = "0.1.1"
  name              = var.sg_name
  description       = var.sg_description
  vpc_id            = var.vpc_id
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(var.tags, { pge_team = local.namespace })
}

################################################################################
#iam_role module for codebuild project in stage 2 - codebuild
module "codebuild_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codebuild_project_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = merge(var.tags, { pge_team = local.namespace })
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
  tags        = merge(var.tags, { pge_team = local.namespace })
  #inline_policy
  inline_policy = local.codescan_inline_policy
}


#################################################################################
#iam_role module for codebuild project in stage 4 - codepublish
module "codepublish_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codepublish_project_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = merge(var.tags, { pge_team = local.namespace })
  #inline_policy
  inline_policy = local.codepublish_inline_policy
}

#################################################################################
