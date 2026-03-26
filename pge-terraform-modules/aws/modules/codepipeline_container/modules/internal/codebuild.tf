/*
AWS codepipeline for Container-based workloads
Consolidated CodeBuild file for:
- Java
- Node.js
- Python
Date: 3rd Dec 2024
*/

######################################################################
#CodeBuild module for respective stages in codepipeline



locals {
  codesecret_inline_policy         = var.custom_codesecret_policy_file != null ? concat([file(var.custom_codesecret_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]
  codebuild_inline_policy          = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]
  codescan_inline_policy           = var.custom_codescan_policy_file != null ? concat([file(var.custom_codescan_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]
  codepublish_inline_policy        = var.custom_codepublish_policy_file != null ? concat([file(var.custom_codepublish_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_wizscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_wizscan_iam_policy.json", {})]
  codebuild_rollback_inline_policy = var.custom_codebuild_rollback_policy_file != null ? concat([file(var.custom_codebuild_rollback_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_rollback_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_rollback_iam_policy.json", {})]

  codescan_buildspec = {
    "python" = module.codebuild_codescan.codescan_buildspec_python
    "nodejs" = module.codebuild_codescan.codescan_buildspec_nodejs
    "java"   = module.codebuild_codescan.codescan_buildspec_java
  }

  wizscan_buildspec = {
    "python" = module.codebuild_wiz.wizscan_buildspec_container_python
    "nodejs" = module.codebuild_wiz.wizscan_buildspec_container_nodejs
    "java"   = module.codebuild_wiz.wizscan_buildspec_container_java
  }
  sonar_tags            = jsonencode(merge(var.tags, var.optional_tags))
  codebuild_source_type = lower(var.source_type) == "github" ? "GITHUB" : var.source_type
  codebuild_sc_token    = data.aws_secretsmanager_secret.github_token.arn
}

module "codesecret_project" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "codesecret_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
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
  tags                         = merge(var.tags, { pge_team = local.namespace })
  source_buildspec             = module.codesecret_project.secretscan_buildspec_container
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = local.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num = data.aws_caller_identity.current.id,
    partition   = data.aws_partition.current.partition,
    aws_region  = data.aws_region.current.name,
  codebuild_project_name = "codesecret_project_${var.codepipeline_name}" })
  encryption_key        = var.kms_key_arn
  environment_variables = var.environment_variables_codesecret_stage
}

module "codebuild_project" {

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
  codebuild_sc_token           = local.codebuild_sc_token
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
  version                      = "0.1.29"
  codebuild_project_name       = "codescan_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
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
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codescan
  cache_location               = var.cache_location_codescan
  cache_modes                  = var.cache_modes_codescan
  source_buildspec             = lookup(local.codescan_buildspec, var.codebuildapp_language)
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = local.codebuild_sc_token
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
      value = var.artifactory_repo_name
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
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME_CODESCAN"
      value = var.java_runtime_codescan
      type  = "PLAINTEXT"
    },
    {
      name  = "NODEJS_RUNTIME_CODESCAN"
      value = var.nodejs_runtime_codescan
      type  = "PLAINTEXT"
    },
    {
      name  = "NODE_BUILD"
      value = var.node_build
      type  = "PLAINTEXT"
    },

    {
      name  = "CODEBUILDAPP_LANGUAGE"
      value = var.codebuildapp_language
      type  = "PLAINTEXT"
    },

    {
      name  = "BUILD_COMMAND"
      value = var.build_command
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
      name  = "SONAR_SCANNER_CLI_VERSION"
      value = var.sonar_scanner_cli_version
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_PROJECT_TAGS"
      value = local.sonar_tags
      type  = "PLAINTEXT"
    }

  ], var.environment_variables_codescan_stage)
}

module "codebuild_wiz" {

  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "wiz_scanning_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
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
  source_location              = var.source_location_codepublish
  concurrent_build_limit       = var.concurrent_build_limit_codepublish
  codebuild_project_role       = module.codepublish_iam_role.arn
  compute_type                 = var.compute_type_codepublish
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_wiz
  cache_location               = var.cache_location_wiz
  cache_modes                  = var.cache_modes_wiz
  source_buildspec             = lookup(local.wizscan_buildspec, var.codebuildapp_language)
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = local.codebuild_sc_token
  codebuild_resource_policy = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", {
    account_num = data.aws_caller_identity.current.id,
    partition   = data.aws_partition.current.partition,
    aws_region  = data.aws_region.current.name,
  codebuild_project_name = "wiz_scanning_${var.codepipeline_name}" })
  encryption_key              = var.kms_key_arn
  environment_privileged_mode = var.privileged_mode_wizscan

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
      name  = "ARTIFACTORY_DOCKER_REGISTRY"
      value = var.artifactory_docker_registry
      type  = "PLAINTEXT"
    },
    {
      name  = "WIZ_CLIENT_ID"
      value = var.secretsmanager_wiz_client_id
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "WIZ_CLIENT_SECRET"
      value = var.secretsmanager_wiz_client_secret
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "PYTHON_RUNTIME"
      value = var.python_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },

    {
      name  = "NODE_RUNTIME"
      value = var.node_runtime
      type  = "PLAINTEXT"
    },

    {
      name  = "CODEBUILDAPP_LANGUAGE"
      value = var.codebuildapp_language
      type  = "PLAINTEXT"
    },
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = var.aws_account_number
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
      name  = "CODEDEPLOY_PROVIDER"
      value = var.codedeploy_provider
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "APP_OWNERS"
      value = "${var.app_owners}${var.Notify}"
      type  = "PLAINTEXT"
    },
    {
      name  = "IMAGE_TYPE"
      value = var.image_type
      type  = "PLAINTEXT"
    },

    {
      name  = "HELMCHART_LOCAL_REPO"
      value = var.artifactory_helm_local_repo
      type  = "PLAINTEXT"
    },
    {
      name  = "ACM_SSL_ARN"
      value = var.acm_certificate_arn
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "CUSTOM_DOMAIN_NAME"
      value = var.custom_domain_name
      type  = "PLAINTEXT"
    },
    {
      name  = "IS_EKS_FARGATE"
      value = var.is_eks_fargate
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ID"
      value = var.AppID
      type  = "PLAINTEXT"
    }


  ], var.environment_variables_wiz_stage)
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
  tags              = merge(var.tags, { pge_team = local.namespace })
}

################################################################################
#iam_role module for codebuild project in stage 2 - codescrets
module "codesecret_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codesecret_project_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = merge(var.tags, { pge_team = local.namespace })
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

  name        = "wiz_scanning_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = merge(var.tags, { pge_team = local.namespace })
  #inline_policy
  inline_policy = local.codepublish_inline_policy
}


