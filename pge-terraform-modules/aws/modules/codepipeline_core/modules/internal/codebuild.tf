################################################################################
# Supporting Resources
################################################################################
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  codebuild_inline_policy    = var.custom_codebuild_policy_file != null ? concat([file(var.custom_codebuild_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuild_iam_policy.json", {})]
  codescan_inline_policy     = var.custom_codescan_policy_file != null ? concat([file(var.custom_codescan_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildscan_iam_policy.json", {})]
  codepublish_inline_policy  = var.custom_codepublish_policy_file != null ? concat([file(var.custom_codepublish_policy_file)], [templatefile("${path.module}/codebuild_iam_policies/codebuildpublish_iam_policy.json", {})]) : [templatefile("${path.module}/codebuild_iam_policies/codebuildpublish_iam_policy.json", {})]
  codedownload_inline_policy = var.custom_codedownload_policy_file != null ? concat([file(var.custom_codedownload_policy_file)], [file("${path.module}/codebuild_iam_policies/codebuilddownload_iam_policy.json")]) : [file("${path.module}/codebuild_iam_policies/codebuilddownload_iam_policy.json")]

  # Windows build support - only for .NET
  is_dotnet_windows  = var.enable_windows_build && var.codebuildapp_language == "dotnet"
  codebuild_sc_token = data.aws_secretsmanager_secret.github_token.arn

  # Environment configurations
  codebuild_environment_type    = local.is_dotnet_windows ? var.windows_environment_type : var.environment_type_codebuild
  codescan_environment_type     = local.is_dotnet_windows ? var.windows_environment_type : var.environment_type_codescan
  codepublish_environment_type  = local.is_dotnet_windows ? var.windows_environment_type : var.environment_type_codepublish
  codedownload_environment_type = local.is_dotnet_windows ? var.windows_environment_type : var.environment_type_codedownload

  # Environment images
  codebuild_environment_image    = local.is_dotnet_windows ? var.environment_image_codebuild_windows : var.environment_image_codebuild
  codescan_environment_image     = local.is_dotnet_windows ? var.environment_image_codescan_windows : var.environment_image_codescan
  codepublish_environment_image  = local.is_dotnet_windows ? var.environment_image_codepublish_windows : var.environment_image_codepublish
  codedownload_environment_image = local.is_dotnet_windows ? var.environment_image_codedownload_windows : var.environment_image_codedownload

  # Buildspec selection based on Windows support
  codescan_buildspec = {
    "python" = module.codebuild_codescan.codescan_buildspec_python
    "nodejs" = module.codebuild_codescan.codescan_buildspec_nodejs
    "java"   = module.codebuild_codescan.codescan_buildspec_java
    "dotnet" = var.enable_windows_build ? module.codebuild_codescan.codescan_buildspec_dotnet_windows : module.codebuild_codescan.codescan_buildspec_dotnet
  }
  codepublish_buildspec = {
    "python" = var.download_artifact ? null : module.codebuild_codepublish[0].codepublish_buildspec_python
    "nodejs" = var.download_artifact ? null : module.codebuild_codepublish[0].codepublish_buildspec_nodejs
    "java"   = var.download_artifact ? null : module.codebuild_codepublish[0].codepublish_buildspec_java
    "dotnet" = var.download_artifact ? null : (var.enable_windows_build ? module.codebuild_codepublish[0].codepublish_buildspec_dotnet_windows : module.codebuild_codepublish[0].codepublish_buildspec_dotnet)
  }
  codedownload_buildspec = {
    # "python" = module.codebuild_codedownload[0].getartifact_buildspec_python
    "nodejs" = var.download_artifact ? module.codebuild_codedownload[0].getartifact_buildspec_nodejs : null
    "java"   = var.download_artifact ? module.codebuild_codedownload[0].getartifact_buildspec_java : null
    "dotnet" = var.download_artifact ? module.codebuild_codedownload[0].getartifact_buildspec_dotnet : null
  }
  codebuild_source_type = lower(var.source_type) == "github" ? "GITHUB" : var.source_type
  merged_tags           = merge(var.tags, var.optional_tags)
}

######################################################################
#CodeBuild module for respective stages in codepipeline
module "codebuild_project" {
  count = var.download_artifact ? 0 : 1

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
  environment_image            = local.codebuild_environment_image
  environment_type             = local.codebuild_environment_type
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
  version                      = "0.1.29"
  codebuild_project_name       = "codescan_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = local.codescan_environment_image
  environment_type             = local.codescan_environment_type
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codescan != null ? var.source_location_codescan : var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codescan
  codebuild_project_role       = module.codescan_iam_role.arn
  compute_type                 = var.compute_type_codescan
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codescan
  cache_location               = var.cache_location_codescan
  cache_modes                  = var.cache_modes_codescan
  # source_buildspec = var.codebuildapp_language == "python" ? module.codebuild_codescan.codescan_buildspec_python : var.codebuildapp_language == "nodejs" ? module.codebuild_codescan.codescan_buildspec_nodejs : var.codebuildapp_language == "dotnet" ? module.codebuild_codescan.codescan_buildspec_dotnet : module.codebuild_codescan.codescan_buildspec_java
  source_buildspec   = lookup(local.codescan_buildspec, var.codebuildapp_language)
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = [module.security-group.sg_id]
  codebuild_sc_token = local.codebuild_sc_token
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
      name  = "PROJECT_KEY"
      value = var.project_key
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
      name  = "PYTHON_RUNTIME"
      value = var.python_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "NODEJS_VERSION_CODESCAN"
      value = var.nodejs_version_codescan
      type  = "PLAINTEXT"
    },
    {
      name  = "DOTNET_RUNTIME"
      value = var.dotnet_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME_CODESCAN"
      value = var.java_runtime_codescan
      type  = "PLAINTEXT"
    },
    {
      name  = "CODEBUILDAPP_LANGUAGE"
      value = var.codebuildapp_language
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_SCANNER_CLI_VERSION"
      value = var.sonar_scanner_cli_version
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_PROJECT_TAGS"
      value = jsonencode(local.merged_tags)
      type  = "PLAINTEXT"
    },
    {
      name  = "ENABLE_WINDOWS_BUILD"
      value = tostring(var.enable_windows_build)
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_FILE"
      value = var.project_file
      type  = "PLAINTEXT"
    },
    {
      name  = "INSTALL_TELERIK"
      value = var.install_telerik
      type  = "PLAINTEXT"
    },
    {
      name  = "S3_BUCKET_NAME"
      value = var.telerik_s3_bucket_name
      type  = "PLAINTEXT"
    },
    {
      name  = "S3_TELERIK_FILE_NAME"
      value = var.s3_telerik_file_name
      type  = "PLAINTEXT"
    },
    {
      name  = "S3_TELERIK_EXTRACT_PATH"
      value = var.s3_telerik_extract_path
      type  = "PLAINTEXT"
    },
    {
      name  = "INSTALL_DOTNET9"
      value = var.install_dotnet9
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_EXCLUSION_LIST"
      value = var.sonar_exclusion_list
      type  = "PLAINTEXT"
    },
  ], var.environment_variables_codescan_stage)
}

module "codebuild_codepublish" {
  count                        = var.download_artifact ? 0 : 1
  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "codepublish_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = local.codepublish_environment_image
  environment_type             = local.codepublish_environment_type
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codepublish != null ? var.source_location_codepublish : var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codepublish
  codebuild_project_role       = module.codepublish_iam_role.arn
  compute_type                 = var.compute_type_codepublish
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codepublish
  cache_location               = var.cache_location_codepublish
  cache_modes                  = var.cache_modes_codepublish
  source_buildspec             = lookup(local.codepublish_buildspec, var.codebuildapp_language)
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = local.codebuild_sc_token
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
      name  = "ARTIFACTORY_USER"
      value = var.secretsmanager_artifactory_user
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
      name  = "GIT_REPO_URL"
      value = var.github_repo_url
      type  = "PLAINTEXT"
    },
    {
      name  = "DEPENDENCY_FILES_LOCATION"
      value = var.dependency_files_location
      type  = "PLAINTEXT"
    },
    {
      name  = "PYTHON_RUNTIME"
      value = var.python_runtime
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
    },
    {
      name  = "INCLUDE_LIB_FILES"
      value = var.include_lib_files
      type  = "PLAINTEXT"
    },
    {
      name  = "NODE_RUNTIME"
      value = var.node_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "DOTNET_RUNTIME"
      value = var.dotnet_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "EXCLUDE_FILES"
      value = var.exclude_files
      type  = "PLAINTEXT"
    },
    {
      name  = "LAMBDA_UPDATE"
      value = var.lambda_update
      type  = "PLAINTEXT"
    },
    {
      name  = "DOTNET_PROJECT_METADATA_FILE"
      value = var.dotnet_project_metadata_file
      type  = "PLAINTEXT"
    },
    {
      name  = "CODEBUILDAPP_LANGUAGE"
      value = var.codebuildapp_language
      type  = "PLAINTEXT"
    },
    {
      name  = "ENABLE_WINDOWS_BUILD"
      value = tostring(var.enable_windows_build)
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_FILE"
      value = var.project_file
      type  = "PLAINTEXT"
    }
  ], var.environment_variables_codepublish_stage)
}

module "codebuild_codedownload" {
  count                        = var.download_artifact ? 1 : 0
  source                       = "app.terraform.io/pgetech/codebuild/aws"
  version                      = "0.1.29"
  codebuild_project_name       = "codedownload_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = local.codebuild_source_type
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = local.codedownload_environment_image
  environment_type             = local.codedownload_environment_type
  artifact_location            = var.artifact_location
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codedownload
  concurrent_build_limit       = var.concurrent_build_limit_codedownload
  codebuild_project_role       = module.codedownload_iam_role[0].arn
  compute_type                 = var.compute_type_codedownload
  tags                         = merge(var.tags, { pge_team = local.namespace })
  cache_type                   = var.cache_type_codedownload
  cache_location               = var.cache_location_codedownload
  cache_modes                  = var.cache_modes_codedownload
  source_buildspec             = lookup(local.codedownload_buildspec, var.codebuildapp_language)
  vpc_id                       = var.vpc_id
  subnet_ids                   = var.subnet_ids
  security_group_ids           = [module.security-group.sg_id]
  codebuild_sc_token           = local.codebuild_sc_token
  codebuild_resource_policy    = templatefile("${path.module}/codebuild_iam_policies/codebuild_inline_policy.json", { account_num = data.aws_caller_identity.current.id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = "codedownload_project_${var.codepipeline_name}" })
  encryption_key               = var.kms_key_arn
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
      name  = "JAVA_RUNTIME"
      value = var.java_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "SONAR_BRANCH_SCANNED"
      value = var.sonar_branch_scanned
      type  = "PLAINTEXT"
    },
    {
      name  = "NODE_RUNTIME"
      value = var.node_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "DOWNLOAD_ARTIFACT"
      value = var.download_artifact
      type  = "PLAINTEXT"
    },
    {
      name  = "DOTNET_RUNTIME"
      value = var.dotnet_runtime
      type  = "PLAINTEXT"
    },
    {
      name  = "ENABLE_WINDOWS_BUILD"
      value = tostring(var.enable_windows_build)
      type  = "PLAINTEXT"
    }
  ], var.environment_variables_codedownload_stage)
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
#iam_role module for codebuild project in stage - codedownload
module "codedownload_iam_role" {
  count   = var.download_artifact ? 1 : 0
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codedownload_${var.codepipeline_name}_iam_role"
  aws_service = var.codebuild_role_service
  tags        = merge(var.tags, { pge_team = local.namespace })
  #inline_policy
  inline_policy = local.codedownload_inline_policy
}
#################################################################################
