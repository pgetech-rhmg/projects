/*
 * # AWS codepipeline dotnet User module example
 * # Prerequisites : In the variable 'ssm_parameter_github_oauth_token', 'artifact_version' , 'project_name', 'project_root_directory', 'dotnet_version', 'github_branch', 'project_unit_test_dir', 'project_file_location', 'artifact_name_dotnet' and 'github_repo_url' Provide the suitable values respectively for testing.
 * # Code verified using terraform validate and terraform fmt -check.
 * # Known Issue: The secret manager VPC endpoint configured in the SecureByDesign AWS account is not denying the call to secret manager and hence we made some adjustments in the VPC endpoint policy and enabled "Allow all" in the policy temporarily to make the connection to secret manager work.
*/
#
#  Filename    : aws/modules/codepipeline_core/examples/dotnet/main.tf
#  Date        : 11 October 2024
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
  ec2_name           = "${var.ec2_name}-${random_pet.cp_random.id}"
  Order              = var.Order
}

# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms klkey
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name        = "${var.kms_name}-${random_pet.cp_random.id}"
#   description = var.kms_description
#   policy      = templatefile("${path.module}/kms_user_policy.json", { account_num = data.aws_caller_identity.current.account_id, codepipeline_name = var.codepipeline_name })
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
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

################################################################################
# Supporting Resources
################################################################################

data "aws_partition" "current" {}

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

data "aws_ssm_parameter" "artifactory_host" {
  name = var.ssm_parameter_artifactory_host
}

data "aws_ssm_parameter" "sonar_host" {
  name = var.ssm_parameter_sonar_host
}

data "aws_ssm_parameter" "artifactory_repo_key" {
  name = var.ssm_parameter_artifactory_repo_key
}

data "aws_ssm_parameter" "golden_ami_windows" {
  name = var.ssm_parameter_golden_ami_windows_name
}

resource "random_pet" "cp_random" {
  length = 2
}


###########################################################################

module "codepipeline" {

  source = "../../modules/dotnet"

  codepipeline_name = "${var.codepipeline_name}-${random_pet.cp_random.id}"
  role_arn          = module.codepipeline_iam_role.arn
  region            = data.aws_region.current.name
  project_key       = var.project_key
  # build_args        = var.build_args

  #Dynamic stages are added inside stages = [] block. Windows builds skip the integration test stage.
  stages = [
    {
      name = "Deploy-EC2"
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
          DeploymentGroupName = module.codedeploy_deployment_group.deployment_group_name
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


  artifact_store_location_bucket = module.s3.id
  encryption_key_id              = null # replace with module.kms_key.key_arn, after key creation
  # Linux environment variables (not used when Windows build is enabled, but required by module interface)
  environment_type_codebuild         = "LINUX_CONTAINER"            # Placeholder - Windows uses windows_environment_type
  environment_type_codescan          = "LINUX_CONTAINER"            # Placeholder - Windows uses windows_environment_type
  environment_type_codepublish       = "LINUX_CONTAINER"            # Placeholder - Windows uses windows_environment_type
  environment_image_codebuild        = "aws/codebuild/standard:5.0" # Placeholder - Windows uses Windows images
  environment_image_codescan         = "aws/codebuild/standard:5.0" # Placeholder - Windows uses Windows images
  environment_image_codepublish      = "aws/codebuild/standard:5.0" # Placeholder - Windows uses Windows images
  codebuild_role_service             = var.codebuild_role_service
  source_location_codebuild          = var.source_location_codebuild
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
  custom_codebuild_policy_file       = "${path.module}/${var.custom_codebuild_policy_file}"
  custom_codescan_policy_file        = "${path.module}/${var.custom_codescan_policy_file}"
  custom_codepublish_policy_file     = "${path.module}/${var.custom_codepublish_policy_file}"
  source_buildspec_codebuild         = file("${path.module}/buildspec_codebuild_windows.yml")

  # Windows build support for .NET projects
  enable_windows_build                   = true
  windows_environment_type               = var.windows_environment_type
  environment_image_codebuild_windows    = var.environment_image_codebuild_windows
  environment_image_codescan_windows     = var.environment_image_codescan_windows
  environment_image_codepublish_windows  = var.environment_image_codepublish_windows
  environment_image_codedownload_windows = var.environment_image_codedownload_windows
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
      name  = "SONAR_TOKEN"
      value = var.secretsmanager_sonar_token
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "SONAR_HOST"
      value = data.aws_ssm_parameter.sonar_host.value
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
      name  = "DOTNET_VERSION"
      value = var.dotnet_version
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_ROOT_DIRECTORY"
      value = var.project_root_directory
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_UNIT_TEST_DIRECTORY"
      value = "" # Unused variable removed
      type  = "PLAINTEXT"
    },
    {
      name  = "PROJECT_FILE_LOCATION"
      value = "WebApplicationSample" # Unused variable removed, using default value
      type  = "PLAINTEXT"
    },
    {
      name  = "ARTIFACT_NAME"
      value = var.artifact_name_dotnet
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
    }
  ]
  #Environment variables of yml file
  github_branch          = var.github_branch
  project_name           = var.project_name
  project_file           = var.project_file
  dotnet_version         = var.dotnet_version
  project_root_directory = var.project_root_directory
  project_unit_test_dir  = ""                     ## unused variable removed
  project_file_location  = "WebApplicationSample" ## unused variable removed, using default value
  # #artifact_name_dotnet   = var.artifact_name_dotnet
  artifact_version   = "1.0" ## unused variable removed, using default value
  github_repo_url    = var.github_repo_url
  unit_test_commands = var.unit_test_commands
  #ssm parameter variables
  subnet_ids           = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  sonar_host           = data.aws_ssm_parameter.sonar_host.value
  artifactory_repo_key = data.aws_ssm_parameter.artifactory_repo_key.value
  artifactory_host     = data.aws_ssm_parameter.artifactory_host.value
  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token
  secretsmanager_sonar_token       = var.secretsmanager_sonar_token
  kms_key_arn                      = null # replace with module.kms_key.key_arn, after key creation

  // optional telerik installation parameters
  # install_telerik         = true
  # telerik_s3_bucket_name  = "es-RDC-3619-dev-fileshare"
  # s3_telerik_file_name    = "telerik.ui.for.blazor.2.28.0.commercial.msi.zip"
  # s3_telerik_extract_path = "telerik.ui.for.blazor.2.28.0.commercial.msi"
  # install_dotnet9 = true
}

##########################################################################################

#github webhook creation

module "codepipeline_internal_gh_webhook" {
  source            = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version           = "0.1.5"
  codepipeline_name = "var.codepipeline_name-${random_pet.cp_random.id}"
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}

####################################################################################
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name   = "${var.bucket_name}-${random_pet.cp_random.id}"
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

  name        = "codepipeline_iam_role-${random_pet.cp_random.id}" #var.codepipeline_role_name
  aws_service = var.codepipeline_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", { codepipeline_bucket_arn = module.s3.arn })]
}


#################################################################################

data "aws_iam_policy_document" "s3_permission" {
  statement {
    sid    = "s3permission"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*"
    ]
  }
}

module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.0"

  name        = "s3-policy-${random_pet.cp_random.id}"
  path        = "/"
  description = "S3 access permission policy"
  policy      = [data.aws_iam_policy_document.s3_permission.json]
  tags        = merge(module.tags.tags, local.optional_tags)
}


#EC2 configuration for Dynamic stage - CodeDeploy requires EC2
module "security_group_EC2" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name               = "${var.sg_name_ec2}-${random_pet.cp_random.id}"
  description        = var.sg_description_ec2
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules_ec2
  cidr_egress_rules  = var.cidr_egress_rules_ec2
  tags               = merge(module.tags.tags, local.optional_tags)
}

module "ec2_windows" {
  source  = "app.terraform.io/pgetech/ec2/aws//modules/pge_windows"
  version = "0.1.2"

  name                   = local.ec2_name
  ami                    = data.aws_ssm_parameter.golden_ami_windows.value
  instance_type          = var.ec2_instance_type_windows # Use larger instance type for Windows
  availability_zone      = var.ec2_az
  subnet_id              = data.aws_ssm_parameter.subnet_id3.value
  vpc_security_group_ids = [module.security_group_EC2.sg_id]
  user_data_base64       = base64encode(templatefile("${path.module}/user-data-scripts-windows.ps1", {}))
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

##################################################################################

module "iam_role_codedeploy" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = "codedeploy_iam_role-${random_pet.cp_random.id}"
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
  aws_service = var.codedeploy_role_service
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "codedeploy_app_ec2" {
  source  = "app.terraform.io/pgetech/codedeploy/aws"
  version = "0.1.0"

  codedeploy_app_name = var.codedeploy_app_name
  tags                = merge(module.tags.tags, local.optional_tags)
}

module "codedeploy_deployment_group" {
  source  = "app.terraform.io/pgetech/codedeploy/aws//modules/deployment_group"
  version = "0.1.1"

  deployment_group_app_name         = module.codedeploy_app_ec2.codedeploy_app_name
  deployment_group_name             = "codedeploy-group-${var.codedeploy_app_name}"
  deployment_group_service_role_arn = module.iam_role_codedeploy.arn
  deployment_config_name            = "CodeDeployDefault.OneAtATime"
  tags                              = merge(module.tags.tags, local.optional_tags)

  deployment_style = [{
    deployment_option = var.deployment_option
    deployment_type   = var.deployment_type
  }]

  ec2_tag_filter = [{
    key   = var.deployment_tag_key
    type  = "KEY_AND_VALUE"
    value = local.ec2_name
  }]
}

