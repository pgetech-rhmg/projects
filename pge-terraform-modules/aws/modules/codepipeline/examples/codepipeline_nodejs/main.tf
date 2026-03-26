/*
 * # AWS codepipeline NodeJS User module example
 * # Prerequisites : In the variable 'ssm_parameter_github_oauth_token', 'github_repo_url', 'project_name', 'project_root_directory','nodejs_version` Provide the suitable values respectively for testing.
 * # Code verified using terraform validate and terraform fmt -check.
 * # Known Issue: The secret manager VPC endpoint configured in the SecureByDesign AWS account is not denying the call to secret manager and hence we made some adjustments in the VPC endpoint policy and enabled "Allow all" in the policy temporarily to make the connection to secret manager work.
*/
#
#  Filename    : aws/modules/codepipeline/examples/codepipeline_nodejs/main.tf
#  Date        : 28 April 2022
#  Author      : TCS
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
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key

# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.0.10"

#   name        = var.kms_name
#   description = var.kms_description
#   policy      = templatefile("${path.module}/kms_user_policy.json", { account_num = data.aws_caller_identity.current.account_id, codepipeline_name = var.codepipeline_name })
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }


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

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "golden_ami" {
  name = var.ssm_parameter_golden_ami_name
}

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

data "aws_ssm_parameter" "artifactory_repo_name" {
  name = var.ssm_parameter_artifactory_repo_name
}

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}
###########################################################################

module "codepipeline" {
  source            = "../../modules/codepipeline_nodejs"
  codepipeline_name = var.codepipeline_name
  role_arn          = module.codepipeline_iam_role.arn
  region            = data.aws_region.current.name
  project_key       = var.project_key
  project_name      = var.project_name


  #Dynamic stages are added inside stages = [] block. stage "test" is addedd to test dynamic stage and a code build module is added as additional configuration.
  stages = [
    {
      name = "Integrationtest"
      action = [{
        name             = "Integrationtest"
        category         = "Test"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["publish"]
        output_artifacts = ["Test"]
        version          = "1"
        run_order        = 1
        configuration = {
          ProjectName = module.codebuild_codetest.codebuild_project_id
        }
      }]
    },
    {
      name = "Deploy"
      action = [{
        name             = "Deploy"
        category         = "Deploy"
        owner            = "AWS"
        provider         = "CodeDeploy"
        version          = "1"
        input_artifacts  = ["publish"]
        output_artifacts = []
        configuration = {
          ApplicationName     = module.codedeploy_app_ec2.codedeploy_app_name
          DeploymentGroupName = aws_codedeploy_deployment_group.default.deployment_group_name
        }
        run_order = 1
      }]
    }
  ]
  tags = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  github_org                              = var.github_org
  repo_name                               = var.repo_name
  branch                                  = var.branch

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
      name  = "NODEJS_VERSION"
      value = var.nodejs_version
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    }
  ]
  #Environment variables of yml file
  nodejs_version         = var.nodejs_version
  project_root_directory = var.project_root_directory
  artifact_name_nodejs   = var.artifact_name_nodejs
  unit_test_commands     = var.unit_test_commands
  #ssm parameter variables
  subnet_ids           = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  codebuild_sc_token   = var.secretsmanager_github_token_secret_name
  artifactory_host     = data.aws_ssm_parameter.artifactory_host.value
  sonar_host           = data.aws_ssm_parameter.sonar_host.value
  artifactory_repo_key = data.aws_ssm_parameter.artifactory_repo_name.value
  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token       = var.secretsmanager_sonar_token
  kms_key_arn                      = null # replace with module.kms_key.key_arn, after key creation
}

##########################################################################################
#To use a CodeBuild project in Dynamic stage of codepipeline, Need to configure here in the examples, main.tf
module "codebuild_codetest" {
  source  = "app.terraform.io/pgetech/codebuild/aws"
  version = "0.1.4"

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
  source_location              = var.source_location_codebuild
  concurrent_build_limit       = var.concurrent_build_limit_codetest
  codebuild_project_role       = module.codetest_iam_role.arn
  compute_type                 = var.compute_type_codetest
  tags                         = merge(module.tags.tags, local.optional_tags)
  source_buildspec             = file("${path.module}/buildspec_codetest.yml")
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  subnet_ids                   = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  security_group_ids           = [module.security-group-codebuild.sg_id]
  codebuild_sc_token           = var.secretsmanager_github_token_secret_name
  codebuild_resource_policy    = templatefile("${path.module}/codebuild_inline_policy.json", { account_num = data.aws_caller_identity.current.id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = "codetest_project_${var.codepipeline_name}" })
  encryption_key               = null # replace with module.kms_key.key_arn, after key creation
  #buildspec environment variables
  environment_variables = [
    {
      name  = "NODEJS_VERSION"
      value = var.nodejs_version
      type  = "PLAINTEXT"
    }
  ]
}

#github webhook creation

module "codepipeline_webhook" {
  source            = "../../modules/codepipeline_webhook"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

#security group for codebuild - codetest
module "security-group-codebuild" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name              = var.sg_name_codebuild
  description       = var.sg_description_codebuild
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  cidr_egress_rules = var.cidr_egress_rules_codebuild
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "codetest_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = var.codetest_role_name
  aws_service = var.codebuild_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [file("${path.module}/codetest_iam_policy.json")]
}

####################################################################################
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name   = var.bucket_name
  force_destroy = true
  policy        = data.aws_iam_policy_document.allow_access.json
  kms_key_arn   = null # replace with module.kms_key.key_arn, after key creation
  tags          = merge(module.tags.tags, local.optional_tags)
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

  name        = "codepipeline_${var.codepipeline_name}_iam_role"
  aws_service = var.codepipeline_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", { codepipeline_bucket_arn = module.s3.arn })]
}



#################################################################################
#EC2 configuration for Dynamic stage - CodeDeploy requires EC2

resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "${var.ec2_name}-kms-policy"
  description = "kms key policy for ec2"
  policy      = file("${path.module}/ec2_iam_policy.json")
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "security_group_EC2" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = var.sg_name_ec2
  description        = var.sg_description_ec2
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules_ec2
  cidr_egress_rules  = var.cidr_egress_rules_ec2
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "ec2" {
  source  = "app.terraform.io/pgetech/ec2/aws"
  version = "0.1.0"

  name                   = var.ec2_name
  ami                    = data.aws_ssm_parameter.golden_ami.value
  instance_type          = var.ec2_instance_type
  availability_zone      = var.ec2_az
  subnet_id              = data.aws_ssm_parameter.subnet_id3.value
  vpc_security_group_ids = [module.security_group_EC2.sg_id]
  policy_arns            = [aws_iam_policy.ec2_kms_policy.arn]
  user_data_base64       = base64encode(templatefile("${path.module}/user-data-scripts.sh", {}))
  metadata_http_endpoint = var.metadata_http_endpoint

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = var.root_block_device_volume_type
      throughput  = var.root_block_device_throughput
      volume_size = var.root_block_device_volume_size
      tags        = merge(module.tags.tags, { Name = "my-root-block" })
    },
  ]

  tags = merge(module.tags.tags, local.optional_tags)
}

module "iam_role_codedeploy" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codedeploy_${var.codepipeline_name}_iam_role"
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
  aws_service = var.codedeploy_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "codedeploy_app_ec2" {
  source  = "app.terraform.io/pgetech/codedeploy/aws"
  version = "0.1.1"

  codedeploy_app_name = var.codedeploy_app_name
  tags                = merge(module.tags.tags, local.optional_tags)
}

resource "aws_codedeploy_deployment_group" "default" {
  app_name              = module.codedeploy_app_ec2.codedeploy_app_name
  deployment_group_name = "codedeploy-group-${var.codedeploy_app_name}"
  service_role_arn      = module.iam_role_codedeploy.arn
  tags                  = merge(module.tags.tags, local.optional_tags)

  ec2_tag_set {
    ec2_tag_filter {
      key   = var.deployment_tag_key
      type  = "KEY_AND_VALUE"
      value = var.ec2_name
    }
  }

  deployment_style {
    deployment_type = var.deployment_type
  }
}
