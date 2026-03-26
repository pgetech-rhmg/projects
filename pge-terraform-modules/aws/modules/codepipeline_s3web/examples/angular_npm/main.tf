/*
 * # AWS codepipeline angular User module example
 * Prerequisites : In the variable 'ssm_parameter_github_oauth_token', 'github_repo_url', 'project_name', 'project_unit_test_dir', 'project_root_directory', 'artifact_name_nodejs', 'artifactory_key_path', 'artifactory_upload_file', 'provide-nodejs-version-here' Provide the suitable values respectively for testing.
 *
 * Code verified using terraform validate and terraform fmt -check.
 *
 * Known Issue: The secret manager VPC endpoint configured in the SecureByDesign AWS account is not denying the call to secret manager and hence we made some adjustments in the VPC endpoint policy and enabled "Allow all" in the policy temporarily to make the connection to secret manager work.
*/
#
#  Filename    : aws/modules/codepipeline/examples/codepipeline_s3web_angular/main.tf
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

#   name        = "${var.kms_name}-${random_pet.cp_random.id}"
#   description = var.kms_description
#   policy      = templatefile("${path.module}/kms_user_policy.json", { account_num = data.aws_caller_identity.current.account_id, codepipeline_name = var.codepipeline_name })
#   tags        = merge(module.tags.tags, local.optional_tags)
#   kms_role    = local.aws_role
#   aws_role    = local.kms_role
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

resource "random_pet" "cp_random" {
  length = 2
}

###########################################################################

module "codepipeline" {
  source = "../../modules/angular"

  codepipeline_name = var.codepipeline_name
  region            = data.aws_region.current.name

  #Dynamic stages are added inside stages = [] block. stage "test" is addedd to test dynamic stage and a code build module is added as additional configuration.

  tags = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name

  cidr_egress_rules         = var.cidr_egress_rules
  sg_name                   = "${var.sg_name}-${random_pet.cp_random.id}"
  sg_description            = var.sg_description
  s3_static_web_bucket_name = var.s3_static_web_bucket_name
  build_args1               = var.build_args1
  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  package_manager        = var.package_manager
  nodejs_version         = var.nodejs_version
  project_root_directory = var.project_root_directory
  github_branch          = var.github_branch
  project_unit_test_dir  = var.project_unit_test_dir
  project_name           = var.project_name
  github_repo_url        = var.github_repo_url
  unit_test_commands     = var.unit_test_commands
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
  aws_cloudfront_distribution_id   = var.aws_cloudfront_distribution_id
  project_key                      = var.project_key
}

#github webhook creation

module "codepipeline_webhook" {
  source  = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version = "0.1.5"

  codepipeline_name = var.codepipeline_name
  repo_name         = local.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}



