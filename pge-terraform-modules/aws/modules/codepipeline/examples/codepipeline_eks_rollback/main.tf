/*
 * # AWS codepipeline example for Containarized Java module example
 * # Prerequisites : In the variables 'ssm_parameter_github_oauth_token', 'github_repo_url', 'dependency_file_location', 'artifactory_repo_key', 'project_root_directory' Provide the suitable values respectively in tfvars for testing.
 * # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/codepipeline/examples/codepipeline_eks_rollback/main.tf
#  Date        : 19 December 2022
#  Author      : Tekyantra
#  Description : The terraform module creates a container codepipeline rollback

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
  version = "0.1.0"

  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
}

###########################################################################

module "codepipeline" {
  source = "../../modules/codepipeline_eks_rollback"

  codepipeline_name  = var.codepipeline_name
  role_arn           = module.codepipeline_iam_role.arn
  region             = data.aws_region.current.name
  aws_account_number = var.account_num

  tags = merge(module.tags.tags, local.optional_tags)

  secretsmanager_github_token_secret_name = var.secretsmanager_github_token_secret_name
  github_org                              = var.github_org
  repo_name                               = var.repo_name
  branch                                  = var.branch
  pollchanges                             = var.pollchanges

  artifact_path     = var.artifact_path
  cidr_egress_rules = var.cidr_egress_rules
  java_runtime      = var.java_runtime

  #ssm parameter variables
  subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]

  vpc_id           = data.aws_ssm_parameter.vpc_id.value
  artifactory_host = data.aws_ssm_parameter.artifactory_host.value

  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token

  ### SNS and Lambda funtion
  ##########################################################################
  endpoint_email                 = var.endpoint_email
  cidr_egress_rules_SNS_codestar = var.cidr_egress_rules_SNS_codestar

  ###############################################################
  # Application

  notification_message = var.notification_message
  tags_codebuild       = merge(module.tags.tags, local.optional_tags)
  container_name       = var.container_name
  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  chart_revision       = var.chart_revision

  compute_type_helmchart           = var.compute_type_helmchart
  environment_type_helmchart       = var.environment_type_helmchart
  environment_image_helmchart      = var.environment_image_helmchart
  concurrent_build_limit_helmchart = var.concurrent_build_limit_helmchart
  source_location_helmchart        = var.source_location_helmchart

  encryption_key_id              = null # replace with module.kms_key.key_arn, after key creation
  artifact_store_location_bucket = module.s3.id

}


# S3 bucket to store Codepipeline artifacts
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.0"

  bucket_name = "s3-${var.codepipeline_name}"
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = data.aws_iam_policy_document.allow_access.json
  tags        = merge(module.tags.tags, local.optional_tags)

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
  inline_policy = [templatefile("${path.module}/codepipeline_iam_policy.json", {
    codepipeline_bucket_arn = module.s3.arn
  })]
}


module "codepipeline_webhook" {
  source            = "../../modules/codepipeline_webhook"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}
