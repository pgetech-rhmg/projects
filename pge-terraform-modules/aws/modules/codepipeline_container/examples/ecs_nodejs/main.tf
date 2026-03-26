/*
* # AWS codepipeline example for NodeJs based Container application module example
* # Prerequisites : In the variables 'ssm_parameter_vpc_id', 'ssm_parameter_subnet_id1/2/3', 'ssm_parameter_artifactory_host', 'ssm_parameter_artifactory_nodejs_repo', 'ssm_parameter_sonar_host', 'ssm_parameter_environment', 'ssm_parameter_artifactory_docker_repo', 'secretsmanager_github_token_secret_name', 'secretsmanager_artifactory_token','secretsmanager_artifactory_user', 'secretsmanager_sonar_token', 'secretsmanager_wiz_client_id', 'secretsmanager_wiz_client_secret'.  Provide the suitable values respectively in tfvars.
* # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/codepipeline_container/examples/ecs_nodejs/main.tf
#  Date        : 03 November 2022
#  Author      : Tekyantra
#  Description : The terraform module creates a nodejs application container codepipeline

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  Order              = var.Order
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey

# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   name        = var.kms_name
#   description = var.kms_description
#   policy = templatefile("${path.module}/kms_user_policy.json",
#     {
#       account_num       = data.aws_caller_identity.current.account_id
#       codepipeline_name = var.codepipeline_name
#   })
#   tags     = merge(module.tags.tags, local.optional_tags)
#   aws_role = local.aws_role
#   kms_role = module.codepipeline_iam_role.name
# }

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}


###########################################################################

module "codepipeline" {
  source             = "../../modules/ecs_nodejs"
  codepipeline_name  = var.codepipeline_name
  role_arn           = module.codepipeline_iam_role.arn
  region             = data.aws_region.current.name
  aws_account_number = var.account_num
  project_key        = var.project_key
  project_name       = var.project_name

  #Dynamic stages are added inside stages = [] block. stage "test" is addedd to test dynamic stage and a code build module is added as additional configuration.
  stages = [
    {
      name = "Deploy-ECS"
      action = [
        {
          name            = "Deploy"
          category        = "Deploy"
          owner           = "AWS"
          version         = "1"
          provider        = var.codedeploy_provider
          input_artifacts = var.codedeploy_provider == "ECS" ? ["wiz-scan"] : ["ImageArtifact", "DefinitionArtifact"]
          configuration = merge(
            var.codedeploy_provider == "ECS" ? {
              ClusterName       = var.ecs_cluster_name
              ServiceName       = var.ecs_service_name
              DeploymentTimeout = var.deployment_timeout
            } : {},
            var.codedeploy_provider == "CodeDeployToECS" ? {
              ApplicationName                = join("-", [var.ecs_service_name, "deploy-app"])
              DeploymentGroupName            = join("-", [var.ecs_service_name, "deploy-group"])
              TaskDefinitionTemplateArtifact = "DefinitionArtifact"
              AppSpecTemplateArtifact        = "DefinitionArtifact"
              Image1ArtifactName             = "ImageArtifact"
              TaskDefinitionTemplatePath     = var.task_definition_template_path
              AppSpecTemplatePath            = var.appspec_template_path
              Image1ContainerName            = var.image1_container_name
            } : {}
          )
        }
      ]
    }
  ]
  tags = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  github_org                              = var.github_org
  repo_name                               = var.repo_name
  branch                                  = var.branch
  unit_test_commands                      = var.unit_test_commands
  node_build                              = var.node_build

  branch_codesecret      = var.branch_codesecret
  pollchanges_codesecret = var.pollchanges_codesecret

  artifact_store_location_bucket = module.s3.id
  encryption_key_id              = null # replace with module.kms_key.key_arn, after key creation
  environment_type_codebuild     = var.environment_type_codebuild
  environment_type_codesecret    = var.environment_type_codesecret
  environment_type_codescan      = var.environment_type_codescan
  environment_type_codepublish   = var.environment_type_codepublish
  privileged_mode_wizscan        = var.privileged_mode

  codebuild_role_service             = var.codebuild_role_service
  source_location_codebuild          = var.source_location_codebuild
  source_location_codesecret         = var.source_location_codesecret
  source_location_codescan           = var.source_location_codescan
  source_location_codepublish        = var.source_location_codepublish
  environment_image_codebuild        = var.environment_image_codebuild
  environment_image_codesecret       = var.environment_image_codesecret
  environment_image_codescan         = var.environment_image_codescan
  environment_image_codepublish      = var.environment_image_codepublish
  concurrent_build_limit_codepublish = var.concurrent_build_limit_codepublish
  concurrent_build_limit_codescan    = var.concurrent_build_limit_codescan
  concurrent_build_limit_codebuild   = var.concurrent_build_limit_codebuild
  concurrent_build_limit_codesecret  = var.concurrent_build_limit_codesecret
  compute_type_codebuild             = var.compute_type_codebuild
  compute_type_codesecret            = var.compute_type_codesecret
  compute_type_codescan              = var.compute_type_codescan
  compute_type_codepublish           = var.compute_type_codepublish
  artifact_path                      = var.artifact_path
  artifact_bucket_owner_access       = var.artifact_bucket_owner_access
  artifact_location                  = module.s3.id
  cidr_egress_rules                  = var.cidr_egress_rules
  sg_name                            = "sg_codebuild_${var.codepipeline_name}"
  sg_description                     = var.sg_description
  node_runtime                       = var.node_runtime
  source_buildspec_codebuild         = file("${path.module}/buildspec_codebuild.yml")


  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  #environment_variables_codebuild - stage 2 environment variables
  environment_variables_codebuild_stage = [
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
      value = data.aws_ssm_parameter.artifactory_host.value
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY"
      value = data.aws_ssm_parameter.artifactory_repo_name.value
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "NODE_RUNTIME"
      value = var.node_runtime
      type  = "PLAINTEXT"
    }
  ]
  project_root_directory = var.project_root_directory
  #ssm parameter variables
  subnet_ids = [data.aws_ssm_parameter.subnet_id2.value]

  vpc_id                      = data.aws_ssm_parameter.vpc_id.value
  artifactory_host            = data.aws_ssm_parameter.artifactory_host.value
  artifactory_repo_name       = data.aws_ssm_parameter.artifactory_repo_name.value
  sonar_host                  = data.aws_ssm_parameter.sonar_host.value
  artifactory_docker_registry = data.aws_ssm_parameter.artifactory_docker_registry.value

  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token       = var.secretsmanager_sonar_token
  secretsmanager_wiz_client_id     = var.secretsmanager_wiz_client_id
  secretsmanager_wiz_client_secret = var.secretsmanager_wiz_client_secret

  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation

  # Application
  container_name          = var.container_name
  version_file            = var.version_file
  publish_docker_registry = var.publish_docker_registry
  codedeploy_provider     = var.codedeploy_provider
  Environment             = var.Environment
  image_type              = var.image_type
  app_owners              = var.app_owners

  tags_codebuild = merge(module.tags.tags, local.optional_tags)
  AppID          = var.AppID


  # codestar variables
  ###############################################################
  codestar_environment              = var.codestar_environment
  cidr_egress_rules_SNS_codestar    = var.cidr_egress_rules_SNS_codestar
  codestar_lambda_encryption_key_id = null # replace with module.kms_key.key_arn, after key creation
  codestar_sns_kms_key_arn          = null # replace with module.kms_key.key_arn, after key creation
  endpoint_email                    = var.endpoint_email
  ###############################################################
}

##########################################################################################
#To use a CodeBuild project in Dynamic stage of codepipeline, Need to configure here in the examples, main.tf
module "codebuild_codetest" {
  source  = "app.terraform.io/pgetech/codebuild/aws"
  version = "0.1.29"

  codebuild_project_name       = "codetest_project_${var.codepipeline_name}"
  artifact_type                = "S3"
  source_type                  = "GITHUB"
  source_git_clone_depth       = 1
  source_fetch_sub             = true
  artifact_name                = "build"
  artifact_packaging           = "ZIP"
  artifact_namespace_type      = "BUILD_ID"
  environment_image            = var.environment_image_codetest
  environment_type             = var.environment_type_codetest
  artifact_location            = module.s3.id
  artifact_bucket_owner_access = var.artifact_bucket_owner_access
  artifact_path                = var.artifact_path
  source_location              = var.source_location_codetest
  concurrent_build_limit       = var.concurrent_build_limit_codetest
  codebuild_project_role       = module.codetest_iam_role.arn
  compute_type                 = var.compute_type_codetest
  tags                         = merge(module.tags.tags, local.optional_tags)
  source_buildspec             = templatefile("${path.module}/buildspec_codetest.yml", {})
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  subnet_ids                   = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]

  security_group_ids = [module.security-group-codebuild.sg_id]
  codebuild_sc_token = data.aws_secretsmanager_secret.github_token.arn
  codebuild_resource_policy = templatefile("${path.module}/codebuild_inline_policy.json",
    {
      account_num            = data.aws_caller_identity.current.id
      partition              = data.aws_partition.current.partition
      aws_region             = data.aws_region.current.name
      codebuild_project_name = "codetest_project_${var.codepipeline_name}"
  })
  encryption_key = null # replace with module.kms_key.key_arn, after key creation
  #buildspec environment variables
  environment_variables = [
    {
      name  = "NODE_RUNTIME"
      value = var.node_runtime
      type  = "PLAINTEXT"
    }
  ]
}

#github webhook creation

module "codepipeline_internal_gh_webhook" {
  source            = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version           = "0.1.6"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

#security group for codebuild - codetest
module "security-group-codebuild" {
  source            = "app.terraform.io/pgetech/security-group/aws"
  version           = "0.1.1"
  name              = "sg_codetest_${var.codepipeline_name}"
  description       = var.sg_description_codebuild
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  cidr_egress_rules = var.cidr_egress_rules_codebuild
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "codetest_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "codetest_project_${var.codepipeline_name}"
  aws_service = var.codebuild_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codetest_iam_policy.json", {
    codepipeline_bucket_arn = module.s3.arn
  })]
}

# S3 bucket to store Codepipeline artifacts
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name         = "s3-${var.codepipeline_name}"
  kms_key_arn         = null # replace with module.kms_key.key_arn, after key creation
  policy              = data.aws_iam_policy_document.allow_access.json
  force_destroy       = var.s3_force_destroy
  block_public_policy = var.s3_block_public_policy
  tags                = merge(module.tags.tags, local.optional_tags)
}

######################################################################################
#IAM role for codepipeline - Inline policy is required to create role so it is configured as template_fle
module "codepipeline_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  name        = "codepipeline_${var.codepipeline_name}_iam_role"
  aws_service = var.codepipeline_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", {
    codepipeline_bucket_arn = module.s3.arn
  })]

}

module "iam_role_codedeploy" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "codedeploy_${var.codepipeline_name}_iam_role"
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
  aws_service = var.codedeploy_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
}
