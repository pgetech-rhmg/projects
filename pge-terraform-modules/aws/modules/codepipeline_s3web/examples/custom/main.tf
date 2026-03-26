/*
 * # AWS codepipeline s3web User module example
 *
 * Prerequisites : In the variable 'ssm_parameter_github_oauth_token', 'github_repo_url', 'project_name', 'project_unit_test_dir', 'project_root_directory', 'artifact_name_nodejs', 'artifactory_key_path', 'artifactory_upload_file', 'provide-nodejs-version-here' Provide the suitable values respectively for testing.
 *
 * Code verified using terraform validate and terraform fmt -check.
 *
 * Known Issue: The secret manager VPC endpoint configured in the SecureByDesign AWS account is not denying the call to secret manager and hence we made some adjustments in the VPC endpoint policy and enabled "Allow all" in the policy temporarily to make the connection to secret manager work.
*/
#
#  Filename    : aws/modules/codepipeline/examples/codepipeline_s3web_custom/main.tf
#  Date        : 08 Sep 2022
#  Author      : PGE
#  Description : The terraform module creates a codepipeline

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  repo_name          = regex("https:\\/\\/github.com\\/(\\w+)\\/([\\w-_]+)(.git$|$)", var.github_repo_url)[1]
  Order              = var.Order
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key

# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name        = var.kms_name
#   description = var.kms_description
#   policy      = templatefile("${path.module}/kms_user_policy.json", { account_num = data.aws_caller_identity.current.account_id, codepipeline_name = var.codepipeline_name })
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

################################################################################
# Supporting Resources
################################################################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_ssm_parameter" "artifactory_repo_key" {
  name = var.ssm_parameter_artifactory_repo_key
}

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}
###########################################################################

module "codepipeline" {
  source = "../../modules/custom"

  codepipeline_name = var.codepipeline_name
  role_arn          = module.codepipeline_iam_role.arn
  region            = data.aws_region.current.name

  #Dynamic stages are added inside stages = [] block. stage "test" is addedd to test dynamic stage and a code build module is added as additional configuration.

  tags = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  repo_name                               = var.repo_name

  artifact_store_location_bucket     = module.s3.id
  encryption_key_id                  = null # replace with module.kms_key.key_arn, after key creation
  environment_type_codebuild         = var.environment_type_codebuild
  environment_type_codescan          = var.environment_type_codescan
  environment_type_codepublish       = var.environment_type_codepublish
  codebuild_role_service             = var.codebuild_role_service
  source_location_codebuild          = var.source_location_codebuild
  environment_image_codebuild        = var.environment_image_codebuild
  environment_image_codescan         = var.environment_image_codescan
  environment_image_codepublish      = var.environment_image_codepublish
  concurrent_build_limit_codepublish = var.concurrent_build_limit_codepublish
  concurrent_build_limit_codescan    = var.concurrent_build_limit_codescan
  concurrent_build_limit_codebuild   = var.concurrent_build_limit_codebuild
  compute_type_codebuild             = var.compute_type_codebuild
  compute_type_codescan              = var.compute_type_codescan
  compute_type_codepublish           = var.compute_type_codepublish
  artifact_path                      = var.artifact_path
  artifact_bucket_owner_access       = var.artifact_bucket_owner_access
  artifact_location                  = module.s3.id
  cidr_egress_rules                  = var.cidr_egress_rules
  sg_name                            = var.sg_name
  sg_description                     = var.sg_description
  source_buildspec_codebuild         = file("${path.module}/buildspec_codebuild.yml")
  s3_static_web_bucket_name          = var.s3_static_web_bucket_name
  s3_static_web_bucket_region        = var.s3_static_web_bucket_region
  aws_cloudfront_distribution_id     = var.aws_cloudfront_distribution_id
  project_key                        = var.project_key
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
      name  = "ARTIFACT_NAME"
      value = var.artifact_name_nodejs
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_HOST"
      value = data.aws_ssm_parameter.artifactory_host.value
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY"
      value = data.aws_ssm_parameter.artifactory_repo_key.value
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY_PATH"
      value = var.artifactory_key_path
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_UPLOAD_FILE"
      value = var.artifactory_upload_file
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
      name  = "APP_ENVIRONMENT"
      value = "/general/environment"
      type  = "PARAMETER_STORE"
    }
  ]
  #Environment variables of yml file
  artifactory_upload_file = var.artifactory_upload_file
  nodejs_version          = var.nodejs_version
  project_root_directory  = var.project_root_directory
  artifact_name_nodejs    = var.artifact_name_nodejs
  artifactory_key_path    = var.artifactory_key_path
  github_branch           = var.github_branch
  project_unit_test_dir   = var.project_unit_test_dir
  project_name            = var.project_name
  github_repo_url         = var.github_repo_url
  unit_test_commands      = var.unit_test_commands
  #ssm parameter variables
  subnet_ids           = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  artifactory_host     = data.aws_ssm_parameter.artifactory_host.value
  sonar_host           = data.aws_ssm_parameter.sonar_host.value
  artifactory_repo_key = data.aws_ssm_parameter.artifactory_repo_key.value
  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token       = var.secretsmanager_sonar_token
  kms_key_arn                      = null # replace with module.kms_key.key_arn, after key creation
}

#github webhook creation

module "codepipeline_webhook" {
  source  = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version = "0.1.5"

  codepipeline_name = var.codepipeline_name
  repo_name         = local.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

####################################################################################
#Below resource 'aws_s3_bucket' to be replaced with the pge s3 module once the pge s3 module logging error is fixed, while calling the pge s3 module.

module "s3" {
  source      = "app.terraform.io/pgetech/s3/aws"
  version     = "0.1.1"
  bucket_name = var.bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.aws_iam_policy_document.allow_access.json
  tags        = module.tags.tags
}


data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*"
    ]
  }
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
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", { codepipeline_bucket_arn = module.s3.arn })]
}




