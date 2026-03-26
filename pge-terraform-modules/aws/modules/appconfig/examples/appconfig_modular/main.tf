/*
 * # AWS AppConfig modular example
 *
 * #### This example demonstrates a full and modularized AppConfig use case that allows for complete control
 * over your AppConfig resources.
 * 
 * You may also reference the appconfig_simple example for a rapid, simple use case that uses a single module
 * that wraps submodules for a simplified configuration, but more restricted in its use case.
*/
#
#  Filename    : aws/modules/appconfig/examples/appconfig_modular/main.tf
#  Date        : 29 Jan 2024
#  Author      : Eric Barnard @e6bo
#  Description : This terraform module demonstrates a full and modularized AppConfig use case.

data "aws_caller_identity" "this" {}

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
  optional_tags      = var.optional_tags
}

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

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.0"
#   name        = var.kms_name
#   description = var.kms_description
#   tags        = module.tags.tags
#   aws_role    = var.aws_role
#   kms_role    = var.kms_role
# }

module "application" {
  source = "../../modules/application"

  name        = var.name
  description = var.description
  tags        = merge(module.tags.tags, local.optional_tags)
}

module "environment" {
  source = "../../modules/environment"

  name        = var.env_name
  description = var.env_description
  tags        = merge(module.tags.tags, local.optional_tags)

  application_id = module.application.id
  monitors       = var.monitors
}

module "configuration_profile" {
  source = "../../modules/configuration_profile"

  name        = var.config_profile_name
  description = var.config_profile_desc
  tags        = merge(module.tags.tags, local.optional_tags)

  application_id = module.application.id
  kms_key_id     = null # replace with module.kms_key.key_arn
}

module "hosted_configuration_version" {
  source = "../../modules/hosted_configuration_version"

  description = var.hosted_config_description
  tags        = merge(module.tags.tags, local.optional_tags)

  content                  = var.content
  configuration_profile_id = module.configuration_profile.id
  application_id           = module.application.id
}

module "deployment_strategy" {
  source = "../../modules/deployment_strategy"

  name        = var.strategy_name
  description = var.strategy_description
  tags        = merge(module.tags.tags, local.optional_tags)

  growth_type         = var.growth_type
  growth_factor       = var.growth_factor
  deployment_duration = var.deployment_duration
  bake_time           = var.bake_time
  replicate_to        = var.replicate_to
}

module "deployment" {
  source = "../../modules/deployment"

  description = "A test deployment"
  tags        = merge(module.tags.tags, local.optional_tags)

  strategy_id              = module.deployment_strategy.id
  application_id           = module.application.id
  configuration_profile_id = module.configuration_profile.id
  configuration_version    = module.hosted_configuration_version.version
  kms_key_id               = null # replace with module.kms_key.key_arn
  environment_id           = module.environment.id
}

