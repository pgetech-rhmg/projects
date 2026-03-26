/*
 * # AWS Amplify App module.
 * Terraform module which creates SAF2.0 Amplify App in AWS.
*/

#
#  Filename    : aws/modules/amplify/main.tf
#  Date        : 20 September 2022
#  Author      : TCS
#  Description : Amplify App Creation
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of Amplify App
# Description : This terraform module creates an Amplify App.

locals {
  namespace                          = "ccoe-tf-developers"
  organization                       = "pgetech"
  enable_auto_branch_creation_config = var.auto_branch_creation_config.build_spec != null || var.auto_branch_creation_config.enable_auto_build != null || var.auto_branch_creation_config.enable_performance_mode != null || var.auto_branch_creation_config.enable_pull_request_preview != null || var.auto_branch_creation_config.environment_variables != null || var.auto_branch_creation_config.framework != null || var.auto_branch_creation_config.pull_request_environment_name != null || var.auto_branch_creation_config.stage != null

  github_sm_list      = split(":", var.secretsmanager_github_access_token_secret_name)
  github_sm_name      = local.github_sm_list[0]
  github_sm_key_name  = length(local.github_sm_list) == 2 ? local.github_sm_list[1] : null
  github_sm_key_value = local.github_sm_key_name != null ? jsondecode(data.aws_secretsmanager_secret_version.github_access_token_id.secret_string)[local.github_sm_key_name] : null
  github_access_token = local.github_sm_key_value != null ? local.github_sm_key_value : data.aws_secretsmanager_secret_version.github_access_token_id.secret_string

  basic_auth_cred_sm_list      = split(":", var.secretsmanager_basic_auth_cred_secret_name)
  basic_auth_cred_sm_name      = local.basic_auth_cred_sm_list[0]
  basic_auth_cred_sm_key_name  = length(local.basic_auth_cred_sm_list) == 2 ? local.basic_auth_cred_sm_list[1] : null
  basic_auth_cred_sm_key_value = local.basic_auth_cred_sm_key_name != null ? jsondecode(data.aws_secretsmanager_secret_version.basic_auth_cred_id.secret_string)[local.basic_auth_cred_sm_key_name] : null
  basic_auth_cred              = local.basic_auth_cred_sm_key_value != null ? "${local.basic_auth_cred_sm_key_name}:${local.basic_auth_cred_sm_key_value}" : data.aws_secretsmanager_secret_version.basic_auth_cred_id.secret_string
}

data "aws_secretsmanager_secret" "github_access_token" {
  name = local.github_sm_name
}

data "aws_secretsmanager_secret_version" "github_access_token_id" {
  secret_id = data.aws_secretsmanager_secret.github_access_token.id
}

data "aws_secretsmanager_secret" "basic_auth_cred" {
  name = local.basic_auth_cred_sm_name
}

data "aws_secretsmanager_secret_version" "basic_auth_cred_id" {
  secret_id = data.aws_secretsmanager_secret.basic_auth_cred.id
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}



resource "aws_amplify_app" "amplify_app" {

  name = var.name

  access_token                  = local.github_access_token
  auto_branch_creation_patterns = var.auto_branch_creation_patterns
  basic_auth_credentials        = base64encode(local.basic_auth_cred)
  build_spec                    = var.build_spec
  description                   = coalesce(var.description, format("%s - Managed by Terraform", var.name))
  enable_auto_branch_creation   = var.enable_auto_branch_creation

  # As per SAF, Ensure that AWS Amplify Applications are configured with basic auth.
  # Enables basic authorization for an Amplify app. This will apply to all branches that are part of this app.
  enable_basic_auth           = true
  enable_branch_auto_build    = var.enable_branch_auto_build
  enable_branch_auto_deletion = var.enable_branch_auto_deletion
  environment_variables       = var.environment_variables
  iam_service_role_arn        = var.iam_service_role_arn
  platform                    = var.platform
  repository                  = "https://github.com/${local.organization}/${var.github_repository_name}"

  # This is an optional dynamic block and will execute when 'enable_auto_branch_creation_config' is  true.
  dynamic "auto_branch_creation_config" {
    for_each = local.enable_auto_branch_creation_config == true ? [true] : []
    content {
      basic_auth_credentials        = base64encode(local.basic_auth_cred)
      build_spec                    = try(var.auto_branch_creation_config.build_spec, null)
      enable_auto_build             = try(var.auto_branch_creation_config.enable_auto_build, null)
      enable_basic_auth             = true
      enable_performance_mode       = try(var.auto_branch_creation_config.enable_performance_mode, null)
      enable_pull_request_preview   = try(var.auto_branch_creation_config.enable_pull_request_preview, null)
      environment_variables         = try(var.auto_branch_creation_config.environment_variables, null)
      framework                     = try(var.auto_branch_creation_config.framework, null)
      pull_request_environment_name = try(var.auto_branch_creation_config.pull_request_environment_name, null)
      stage                         = try(var.auto_branch_creation_config.stage, null)
    }
  }

  # This is an optional dynamic block and the loop will run only when the value for 'custom_rule.source' && 'var.custom_rule.target' is not null. The arguments: 'custom_rule.source' & 'custom_rule.target' are mandatory for 'custom_rule'.
  dynamic "custom_rule" {
    for_each = var.custom_rule.source != null && var.custom_rule.target != null ? [true] : []
    content {
      condition = var.custom_rule.condition
      source    = var.custom_rule.source
      status    = var.custom_rule.status
      target    = var.custom_rule.target
    }
  }

  tags = local.module_tags

}