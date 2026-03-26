/*
 * # AWS codepipeline example for Containarized Java module example
 * # Prerequisites : In the variables 'ssm_parameter_github_oauth_token', 'github_repo_url', 'dependency_file_location', 'artifactory_repo_key', 'project_root_directory' Provide the suitable values respectively in tfvars for testing.
 * # Code verified using terraform validate and terraform fmt -check.
*/
#
#  Filename    : aws/modules/codepipeline_container/examples/ecs_rollback/main.tf
#  Date        : 19 December 2022
#  Author      : Tekyantra
#  Description : The terraform module creates a container codepipeline

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

###########################################################################

module "codepipeline" {
  source = "../../modules/ecs_rollback"

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

  environment_type_codepublish = var.environment_type_codebuild
  privileged_mode_wizscan      = var.privileged_mode

  source_location_codepublish = var.source_location_codebuild

  environment_image_codepublish      = var.environment_image_codebuild
  concurrent_build_limit_codepublish = var.concurrent_build_limit_codebuild

  compute_type_codepublish = var.compute_type_codebuild
  artifact_path            = var.artifact_path
  cidr_egress_rules        = var.cidr_egress_rules

  java_runtime = var.java_runtime

  codedeploy_application_name       = var.codedeploy_application_name
  codedeploy_deployment_groupname   = var.codedeploy_deployment_groupname
  task_definition_template_artifact = var.task_definition_template_artifact
  task_definition_template_path     = var.task_definition_template_path
  appspec_template_path             = var.appspec_template_path
  image1_artifact_name              = var.image1_artifact_name
  image1_container_name             = var.image1_container_name

  #It will support multiple environment variables. We can pass multiple values through the varable "environment_variables"
  #environment_variables_codebuild - stage 2 environment variables

  #ssm parameter variables
  subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  artifactory_docker_registry = data.aws_ssm_parameter.artifactory_docker_registry.value

  #secrets manager variables
  secretsmanager_artifactory_user  = var.secretsmanager_artifactory_user
  secretsmanager_artifactory_token = var.secretsmanager_artifactory_token

  ### SNS and Lambda funtion
  ##########################################################################

  endpoint_email                 = var.endpoint_email
  cidr_egress_rules_SNS_codestar = var.cidr_egress_rules_SNS_codestar

  ################################################################

  ###############################################################

  # Application
  application_name        = var.application_name
  publish_docker_registry = var.publish_docker_registry
  codedeploy_provider     = var.codedeploy_provider
  rollback_image_tag      = var.rollback_image_tag
  notification_message    = var.notification_message

  encryption_key_id              = null # replace with module.kms_key.key_arn, after key creation
  artifact_store_location_bucket = module.s3.id

  tags_codebuild = merge(module.tags.tags, local.optional_tags)

}

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


#github webhook creation

module "codepipeline_internal_gh_webhook" {
  source            = "app.terraform.io/pgetech/codepipeline_internal/aws//modules/gh_webhook"
  version           = "0.1.6"
  codepipeline_name = var.codepipeline_name
  repo_name         = var.repo_name
  tags              = merge(module.tags.tags, local.optional_tags)
}