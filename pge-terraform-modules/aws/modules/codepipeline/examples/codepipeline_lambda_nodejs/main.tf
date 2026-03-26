/*
 * # AWS codepipeline project User module example
 * # CodeScan and CodePublish stages buildpsec files gets added by terraform module. CodePublish stage reads lambda function name variable and publishes lambda version using aws cli, generates zip file with built code, uploads to artifactory and updates lambda funnction
 * # Prerequisites : In the variables 'lambda_function_name', 'lambda_alias_name', 'secretsmanager_github_token_secret_name', 'secretsmanager_artifactory_user', 'ssm_parameter_sonar_host', 'ssm_parameter_artifactory_repo_name', 'secretsmanager_artifactory_token', 'unit_test_commands', secretsmanager_sonar_token Provide the suitable values respectively in tfvars for testing.
 * # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/codepipeline/examples/codepipeline_lambda_nodejs/main.tf
#  Date        : 15 September 2023
#  Author      : PGE
#  Description : The terraform module creates a codepipeline for Lambda Node

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.0"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
}

################################################################################
# Supporting Resources
################################################################################

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

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "artifactory_repo_name" {
  name = var.ssm_parameter_artifactory_repo_name
}

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}

resource "random_pet" "cp_random" {
  length = 2
}

#############################################################

module "codepipeline" {
  source            = "../../modules/codepipeline_lambda_nodejs"
  codepipeline_name = var.codepipeline_name
  role_arn          = module.codepipeline_iam_role.arn
  region            = data.aws_region.current.name
  tags              = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  github_org                              = var.github_org
  repo_name                               = var.repo_name
  branch                                  = var.branch

  artifact_store_location_bucket     = module.s3.id
  encryption_key_id                  = null #if you want to encrypt the data, replace with module.kms_key.key_arn, after key creation
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
  sg_name                            = "${var.sg_name}-${var.codepipeline_name}"
  sg_description                     = var.sg_description
  source_buildspec_codebuild         = file("${path.module}/buildspec_codebuild.yml")

  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  #environment_variables_codebuild - stage 2 environment variables
  #environment variables takes precedence over variables set on buildpsec files
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
      value = var.ssm_parameter_artifactory_host
      type  = "PARAMETER_STORE"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACTORY_REPO_KEY"
      value = var.ssm_parameter_artifactory_repo_name
      type  = "PARAMETER_STORE"
    },
    {
      name  = "NODEJS_VERSION"
      value = var.node_runtime
      type  = "PLAINTEXT"
    }
  ]
  environment_variables_codescan_stage = var.environment_variables_codescan_stage
  #Environment variables of yml file
  project_key               = var.project_key
  project_name              = var.project_name
  project_root_directory    = var.project_root_directory
  github_branch             = var.branch
  unit_test_commands        = var.unit_test_commands
  dependency_files_location = var.dependency_files_location
  #ssm parameter variables
  subnet_ids            = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  codebuild_sc_token    = var.secretsmanager_github_token_secret_name
  artifactory_repo_name = data.aws_ssm_parameter.artifactory_repo_name.value
  artifactory_host      = data.aws_ssm_parameter.artifactory_host.value
  sonar_host            = data.aws_ssm_parameter.sonar_host.value
  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token       = var.secretsmanager_sonar_token
  kms_key_arn                      = null # replace with module.kms_key.key_arn, after key creation
  node_runtime                     = var.node_runtime
  lambda_function_name             = var.lambda_function_name
  lambda_alias_name                = var.lambda_alias_name
}

##########################################################################################

#github webhook creation

module "codepipeline_webhook" {
  source            = "../../modules/codepipeline_webhook"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

####################################################################################

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name   = "${var.bucket_name}-${random_pet.cp_random.id}"
  kms_key_arn   = null # replace with module.kms_key.key_arn, after key creation
  policy        = data.aws_iam_policy_document.allow_access.json
  force_destroy = true
  tags          = module.tags.tags
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
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"
  name        = "codepipeline_iam_role-${random_pet.cp_random.id}"
  aws_service = var.codepipeline_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", { codepipeline_bucket_arn = module.s3.arn })]
}


####################################################################################
# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
#KMS key module
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   name        = "${var.kms_name}-${random_pet.cp_random.id}"
#   description = var.kms_description
#   policy      = templatefile("${path.module}/kms_user_policy.json", { account_num = data.aws_caller_identity.current.account_id, codepipeline_name = var.codepipeline_name })
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }

#lambda creation

module "lambda_function" {
  source        = "app.terraform.io/pgetech/lambda/aws"
  version       = "0.1.1"
  function_name = var.lambda_function_name
  role          = module.aws_lambda_iam_role.arn
  description   = var.description
  runtime       = var.runtime
  source_code = {
    content  = "#this is a empty lambda, code will get added via codepipeline"
    filename = "index.js"
  }
  allow_outofband_update        = var.allow_outofband_update
  tags                          = merge(module.tags.tags, local.optional_tags)
  vpc_config_security_group_ids = [module.security_group_lambda.sg_id]
  vpc_config_subnet_ids         = [data.aws_ssm_parameter.subnet_id3.value]
  handler                       = var.handler
  environment_variables = {
    variables   = var.environment_variables
    kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  }
}

module "security_group_lambda" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = var.lambda_sg_name
  description        = var.lambda_sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.lambda_cidr_ingress_rules
  cidr_egress_rules  = var.lambda_cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "aws_lambda_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = var.lambda_iam_name
  aws_service = var.lambda_iam_aws_service
  tags        = merge(module.tags.tags, local.optional_tags)

  #AWS_Managed_Policy
  policy_arns = var.lambda_iam_policy_arns
}

module "lambda_alias" {
  source                        = "app.terraform.io/pgetech/lambda/aws//modules/lambda_alias"
  version                       = "0.1.1"
  lambda_alias_name             = var.lambda_alias_name
  lambda_alias_description      = "alias for lambda function"
  lambda_alias_function_name    = module.lambda_function.lambda_arn
  lambda_alias_function_version = module.lambda_function.lambda_version
}
