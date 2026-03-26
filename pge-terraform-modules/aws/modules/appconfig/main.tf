/*
 * # AWS AppConfig simple module
 * Terraform module which creates SAF2.0 simplified, full Appconfig resource in AWS
 *
 * This module is to create a rapid, simple deployment of a single AppConfig application, environment,
 * configuration profile, and hosted configuration version. See the "appconfig_simple" example for usage.
 * If you need more flexibility (like multiple of any resource) see the "appconfig_complete" example for
 * how to create a modularized deployment.
*/
#
#  Filename    : aws/modules/appconfig/main.tf
#  Date        : 29 January 2024
#  Author      : Eric Barnard @e6bo 
#  Description : AppConfig TF module that creates a simplified AppConfig resource
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

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

data "aws_caller_identity" "this" {}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type; exit 1"]
}

module "application" {
  source = "./modules/application"

    name        = var.name
  description = var.description

  tags = local.module_tags
}

module "configuration_profile" {
  source = "./modules/configuration_profile"

  name        = var.config_profile_name
  description = var.config_profile_description
  tags        = local.module_tags

  application_id     = module.application.id
  kms_key_id = var.kms_key_id
}

module "hosted_configuration_version" {
  source = "./modules/hosted_configuration_version"

  application_id           = module.application.id
  configuration_profile_id = module.configuration_profile.id
  description              = var.hosted_config_description
  content                  = var.hosted_config_content
  content_type             = var.hosted_config_content_type
  tags        = local.module_tags
}

module "environment" {
  source = "./modules/environment"

  name        = var.env_name
  description = var.env_description
  tags        = local.module_tags

  monitors = var.env_monitors
  application_id = module.application.id
}