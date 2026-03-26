/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_task_definition/main.tf
#  Date        : 13 April 2022
#  Author      : TCS
#  Description : ECS task definition resource creation
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
# Description : This terraform module creates a ecs.

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.family_service
  requires_compatibilities = var.requires_compatibilities
  container_definitions    = var.container_definition

  # The variable cpu will take value only when the value of the variable requires_compatibilities is ["FARGATE"].
  cpu                = var.requires_compatibilities == ["EC2"] ? null : var.cpu
  execution_role_arn = var.execution_role_arn


  # The variable memory will take value only when the value of the variable requires_compatibilities is ["FARGATE"].
  memory       = var.requires_compatibilities == ["EC2"] ? null : var.memory
  network_mode = var.network_mode
  ipc_mode     = var.ipc_mode
  pid_mode     = var.pid_mode

  # The condition will execute this block only when the variable volume has value.
  dynamic "volume" {
    #for_each = var.volumes != null ? [true] : []
    for_each = [for v in var.volumes : {
      name      = v.name
      host_path = v.host_path
    }]
    content {
      # The condition will execute this block only when the variable docker_volume_configuration has value.
      dynamic "docker_volume_configuration" {
        for_each = var.docker_volume_configuration != null ? [true] : []
        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
          scope         = lookup(docker_volume_configuration.value, "scope", null)
        }
      }
      # The condition will execute this block only when the variable efs_volume_configuration has value.
      dynamic "efs_volume_configuration" {
        for_each = var.efs_volume_configuration != null ? [true] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = lookup(efs_volume_configuration.value, "root_directory", null)
          transit_encryption      = lookup(efs_volume_configuration.value, "transit_encryption", null)
          transit_encryption_port = lookup(efs_volume_configuration.value, "transit_encryption_port", null)
          # The condition will execute this block only when the variable authorization_config has value.
          dynamic "authorization_config" {
            for_each = var.authorization_config != null ? [true] : []
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", null)
            }
          }
        }
      }
      # The condition will execute this block only when the variable fsx_windows_file_server_volume_configuration has value.
      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = var.fsx_windows_file_server_volume_configuration != null ? [true] : []
        content {
          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory
          # The condition will execute this block only when the variables  credentials_parameter and domain have values.
          dynamic "authorization_config" {
            for_each = (var.credentials_parameter && var.domain) != null ? [true] : []
            content {
              credentials_parameter = var.credentials_parameter
              domain                = var.domain
            }
          }
        }
      }
      name      = volume.value.name
      host_path = volume.value.host_path
    }
  }

  # The condition will execute this block only when the variable placement_constraints has value.
  dynamic "placement_constraints" {
    for_each = var.placement_constraints != null ? [true] : []
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }

  # The condition will execute this block only when the variable proxy_configuration has value.
  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration != null ? [true] : []
    content {
      container_name = proxy_configuration.value.container_name
      properties     = proxy_configuration.value.properties
      type           = lookup(proxy_configuration.value, "type", null)
    }
  }

  # The condition will execute this block only when the variable runtime_platform has value.


  dynamic "runtime_platform" {
  for_each = var.runtime_platform != null ? { "runtime_platform": var.runtime_platform } : {}
  content {
    operating_system_family = lookup(runtime_platform.value, "operatingSystemFamily", null)
    cpu_architecture        = lookup(runtime_platform.value, "cpuArchitecture", null)
  }
}

  # The condition will execute this block only when the variable ephemeral_storage has value.
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage != null ? [true] : []
    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  task_role_arn = var.task_role_arn
  tags          = local.module_tags
}

