/*
 * # AWS codebuild project User module example
*/
#
#  Filename    : aws/modules/codebuild/examples/codebuild_project/main.tf
#  Date        : 24 January 2022
#  Author      : TCS
#  Description : The terraform module creates a codebuild

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
  aws_role           = var.aws_role
  kms_role           = var.kms_role
}

# To use encryption with this example module please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.0.10"
#  name        = "${var.kms_name}-${random_pet.cb_random.id}"
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
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

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_id1" {
  name = "/vpc/privatesubnet1/id"
}

data "aws_ssm_parameter" "subnet_id2" {
  name = "/vpc/privatesubnet2/id"
}

data "aws_region" "current" {}


data "aws_caller_identity" "current" {}


data "aws_partition" "current" {}

resource "random_pet" "cb_random" {
  length = 2
}



module "codebuild_project" {
  source = "../.."

  #CodeBuild project
  codebuild_project_name        = var.codebuild_project_name
  codebuild_project_description = var.codebuild_project_description
  codebuild_project_role        = module.aws_iam_role.arn
  encryption_key                = null # replace with module.kms_key.key_arn, after key creation
  concurrent_build_limit        = var.concurrent_build_limit
  artifact_type                 = var.artifact_type
  tags                          = merge(module.tags.tags, local.optional_tags)

  cache_type     = var.cache_type
  cache_location = module.s3.arn

  s3_logs_status = var.s3_logs_status
  s3_location    = module.s3.arn

  compute_type                = var.compute_type
  environment_image           = var.environment_image
  environment_type            = var.environment_type
  image_pull_credentials_type = var.image_pull_credentials_type
  cloudwatch_logs_group_name  = var.cloudwatch_logs_group_name
  cloudwatch_logs_stream_name = var.cloudwatch_logs_stream_name

  source_type            = var.source_type
  source_location        = var.source_location
  source_git_clone_depth = var.source_git_clone_depth
  source_fetch_sub       = var.source_fetch_sub

  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  subnet_ids         = [data.aws_ssm_parameter.subnet_id2.value]
  security_group_ids = [module.security_group_project.sg_id]

  #CodeBuild Source Credentials
  codebuild_sc_token = var.secretsmanager_github_token_secret_arn

  #CodeBuild Resource policy
  codebuild_resource_policy = templatefile("${path.module}/${var.policy_file_name}", { account_num = data.aws_caller_identity.current.account_id, partition = data.aws_partition.current.partition, aws_region = data.aws_region.current.name, codebuild_project_name = var.codebuild_project_name })
}

module "github_webhook" {
  source = "../../modules/github_repository_webhook"

  github_token        = var.secretsmanager_github_token_secret_arn
  github_base_url     = var.github_base_url
  github_repository   = var.github_repository
  github_events       = var.github_events
  github_content_type = var.github_content_type

  codebuild_webhook_project_name = module.codebuild_project.codebuild_project_arn
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name = "${var.bucket_name}-${random_pet.cb_random.id}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "security_group_project" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name              = "${var.sg_name}-${random_pet.cb_random.id}"
  description       = var.sg_description
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  cidr_egress_rules = var.cidr_egress_rules
  tags              = merge(module.tags.tags, local.optional_tags)
}

module "aws_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = "${var.role_name}-${random_pet.cb_random.id}"
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/iam_inline_policy.json", { account_num = data.aws_caller_identity.current.account_id, aws_region = data.aws_region.current.name, s3_arn = module.s3.arn, subnet_id = data.aws_ssm_parameter.subnet_id1.value })] #Policy used for the Codebuild Iam role. It is used to share a project that we own.
}