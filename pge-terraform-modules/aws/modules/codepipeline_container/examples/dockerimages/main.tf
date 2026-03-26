/*
 * # AWS codepipeline example for codepipeline dockerimages
 * # Prerequisites : In the variables 'ssm_parameter_github_oauth_token', 'github_repo_url', 'artifactory_repo_key' Provide the suitable values respectively in tfvars for testing.
 * # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/codepipeline_container/examples/dockerimages/main.tf
#  Date        : 08 December 2022
#  Author      : Tekyantra
#  Description : The terraform module creates a codepipeline for docker images

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  account_num        = var.account_num
  Order              = var.Order
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   name        = "${var.codepipeline_name}_kms"
#   description = "${var.codepipeline_name}_kms for codepipeline"
#   policy = templatefile("${path.module}/kms_user_policy.json",
#     {
#       account_num       = data.aws_caller_identity.current.account_id
#       codepipeline_name = var.codepipeline_name
#   })
#   tags     = merge(module.tags.tags, local.optional_tags)
#   aws_role = var.aws_role
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

data "aws_ssm_parameter" "environment" {
  name = "/general/environment"
}

###########################################################################

module "codepipeline" {
  source = "../../../codepipeline_container"

  codepipeline_name                       = var.codepipeline_name
  role_arn                                = module.codepipeline_iam_role.arn
  region                                  = data.aws_region.current.name
  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  github_org                              = var.github_org
  repo_name                               = var.repo_name
  branch                                  = var.branch
  environment_type_codebuild              = var.environment_type_codebuild
  codebuild_role_service                  = var.codebuild_role_service
  source_location_codebuild               = var.source_location_codebuild
  environment_image_codebuild             = var.environment_image_codebuild
  concurrent_build_limit_codebuild        = var.concurrent_build_limit_codebuild
  compute_type_codebuild                  = var.compute_type_codebuild
  artifact_path                           = var.artifact_path
  artifact_bucket_owner_access            = var.artifact_bucket_owner_access
  cidr_egress_rules                       = var.cidr_egress_rules
  s3_bucket                               = var.s3_bucket
  sg_name                                 = "sg_codepipeline_${var.codepipeline_name}"
  sg_description                          = "sg_codepipeline_${var.codepipeline_name} group"
  source_buildspec_codebuild              = file("${path.module}/generic_buildspec.yml")
  tags                                    = merge(module.tags.tags, local.optional_tags)
  subnet_ids                              = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]

  vpc_id = data.aws_ssm_parameter.vpc_id.value
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
      name  = "ARTIFACTORY_DOCKER_REGISTRY"
      value = data.aws_ssm_parameter.artifactory_docker_registry.value
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
      name  = "DOCKER_IMAGE_NAME"
      value = var.DockerImage_name
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_OWNERS"
      value = var.app_owners
      type  = "PLAINTEXT"
    },
    {
      name  = "ENVIRONMENT"
      value = data.aws_ssm_parameter.environment.value
      type  = "PLAINTEXT"
    },
    {
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "AWS_ACCOUNT_NUMBER"
      value = local.account_num
      type  = "PLAINTEXT"
    },
    {
      name  = "PUBLISH_DOCKER_REGISTRY"
      value = var.publish_docker_registry
      type  = "PLAINTEXT"
    },

  ]

  # #buildspec environment variables
  # environment_variables_codebuild_stage = [

  # ]

  ### SNS and Lambda funtion
  endpoint_email = var.endpoint_email

  ###############################################################

  encryption_key_id              = null # replace with module.kms_key.key_arn, after key creation
  artifact_store_location_bucket = module.s3.id
}

#github webhook creation

module "codepipeline_internal_gh_webhook" {
  source            = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version           = "0.1.6"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}


#s3 bucket for Codepipeline build logs and artifacts
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = "s3-${var.codepipeline_name}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.aws_iam_policy_document.allow_access.json
  tags        = merge(module.tags.tags, local.optional_tags)
}

######################################################################################
#IAM role for codepipeline - Inline policy is required to create role so it is configured as template_fle
module "codepipeline_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "codepipeline_${var.codepipeline_name}_iam_role"
  aws_service = var.codepipeline_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", {
    codepipeline_bucket_arn = module.s3.arn
  })]
}
