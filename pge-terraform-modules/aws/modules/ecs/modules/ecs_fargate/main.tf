/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_fargate/main.tf
#  Date        : 13 April 2022
#  Author      : PGE
#  Description : ECS  FARGATE module creation with Wiz integration
#

terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : ecs module
# Description : This terraform module creates a ecs with fargate.

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

data "aws_secretsmanager_secret" "wiz_registry_credentials" {
  name = var.wiz_registry_credentials
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  wiz_repository_credentials       = data.aws_secretsmanager_secret.wiz_registry_credentials.arn
  wiz_container_name               = var.wiz_container_name
  wiz_container_image              = var.wiz_container_image
  wiz_container_cpu                = var.wiz_container_cpu
  wiz_container_memory_reservation = var.wiz_container_memory_reservation
  wiz_privileged                   = var.wiz_privileged
  wiz_port_mappings                = var.wiz_port_mappings
  wiz_essential                    = var.wiz_essential
  wiz_mount_points                 = var.wiz_mount_points
  wiz_volumes_from                 = var.wiz_volumes_from
  wiz_linux_parameters             = var.wiz_linux_parameters
  wiz_readonly_root_filesystem     = var.wiz_readonly_root_filesystem
  wiz_environment                  = var.wiz_environment
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  configuration {
    execute_command_configuration {
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = var.log_cloud_watch_log_group_name
        s3_bucket_name                 = var.log_s3_bucket_name
        s3_bucket_encryption_enabled   = true
        s3_key_prefix                  = var.log_s3_key_prefix
      }
      logging    = var.log_execute_command
      kms_key_id = var.kms_key_id
    }
  }

  # The condition will execute this block only when the variable setting_value has value.
  dynamic "setting" {
    for_each = var.setting_value != null ? [true] : []
    content {
      name  = "containerInsights"
      value = var.setting_value
    }
  }

  tags = local.module_tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {

  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = var.ecs_cluster_capacity_providers

  # The condition will execute this block only when the value of the variable ecs_cluster_capacity_providers is FARGATE or FARGATE_SPOT
  dynamic "default_capacity_provider_strategy" {
    for_each = var.ecs_cluster_capacity_providers == "FARGATE" || var.ecs_cluster_capacity_providers == "FARGATE_SPOT" ? [true] : []
    content {
      capacity_provider = var.ecs_default_cluster_capacity_provider
      weight            = var.ecs_cluster_capacity_weight
      base              = var.ecs_cluster_capacity_base
    }
  }
}


module "ecs_container_definition" {
  source = "../ecs_container_definition"

  container_name               = null
  container_image              = null
  container_memory             = null
  container_cpu                = null
  command                      = null
  container_memory_reservation = null
  essential                    = null
  readonly_root_filesystem     = null
  environment                  = null
  privileged                   = null
  extra_hosts                  = null
  hostname                     = null
  entrypoint                   = null
  pseudo_terminal              = null
  interactive                  = null
  port_mappings                = null
  log_configuration = {
    logDriver = null
    options = {
      awslogs-region        = null
      awslogs-group         = null
      awslogs-stream-prefix = null
      awslogs-create-group  = null
    }
  }
  repository_Credentials = {
    credentialsParameter = null
  }

  #wiz container definition
  wiz_container_name               = local.wiz_container_name
  wiz_container_image              = local.wiz_container_image
  wiz_container_cpu                = local.wiz_container_cpu
  wiz_container_memory_reservation = local.wiz_container_memory_reservation
  wiz_privileged                   = local.wiz_privileged
  wiz_port_mappings                = local.wiz_port_mappings
  wiz_essential                    = local.wiz_essential
  wiz_mount_points                 = local.wiz_mount_points
  wiz_volumes_from                 = local.wiz_volumes_from
  wiz_linux_parameters             = local.wiz_linux_parameters
  wiz_readonly_root_filesystem     = local.wiz_readonly_root_filesystem
  wiz_environment                  = local.wiz_environment
  wiz_repository_Credentials = {
    credentialsParameter = local.wiz_repository_credentials
  }
}