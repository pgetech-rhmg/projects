/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_ec2/main.tf
#  Date        : 11 April 2022
#  Author      : PGE
#  Description : ECS EC2 module creation with wiz integration
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
# Description : This terraform module creates a ecs with ec2 with wiz integration

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  wiz_secret_credential            = jsondecode(data.aws_secretsmanager_secret_version.wiz_secret_version.secret_string)
  wiz_container_name               = "wiz-sensor"
  wiz_container_image              = "wizio.azurecr.io/sensor:v1"
  wiz_container_cpu                = "0"
  wiz_container_memory_reservation = "50"
  wiz_privileged                   = true
  wiz_port_mappings                = []
  wiz_essential                    = true
  wiz_mount_points = [{
    sourceVolume  = "wiz-host-cache"
    containerPath = "/wiz-host-cache"
    readOnly      = false
    },
    {
      sourceVolume  = "sys-kernel-debug"
      containerPath = "/sys/kernel/debug"
      readOnly      = true
  }]
  wiz_volumes_from = []
  wiz_user         = "2202:2202"
  wiz_linux_parameters = {
    capabilities = {
      add  = []
      drop = []
    }
    devices            = []
    initProcessEnabled = false
    maxSwap            = 0
    sharedMemorySize   = null
    swappiness         = 0
    tmpfs = [
      {
        containerPath = "/tmp"
        mountOptions  = ["rw"]
        size          = 100
      }
    ]
  }
  wiz_readonly_root_filesystem = true
  wiz_repository_credentials   = data.aws_secretsmanager_secret.wiz_registry_credentials.arn
  wiz_environment = [
    {
      "name" : "API_CLIENT_ID",
      "value" : local.wiz_secret_credential["WIZ_CLIENT_ID"]
    },
    {
      "name" : "API_CLIENT_SECRET",
      "value" : local.wiz_secret_credential["WIZ_CLIENT_SECRET"]
    },
    {
      "name" : "WIZ_RAMFS_STORE",
      "value" : "/tmp/ramfs"
    },
    {
      "name" : "WIZ_HOST_STORE",
      "value" : "/wiz-host-cache/"
    },
    {
      "name" : "SENSOR_TYPE",
      "value" : "ecs"
    },
    {
      "name" : "WIZ_TMP_STORE",
      "value" : "/wiz-host-cache/tmp_store"
    },
    {
      "name" : "LOG_FILE",
      "value" : "/wiz-host-cache/sensor_logs/sensor.log"
    }
  ]
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

  # The condition will execute this block only when the variable ecs_cluster_capacity_providers has value.
  dynamic "default_capacity_provider_strategy" {
    for_each = var.ecs_cluster_capacity_providers != null ? [true] : []
    content {
      capacity_provider = var.ecs_default_capacity_provider
      weight            = var.ecs_cluster_capacity_weight
      base              = var.ecs_cluster_capacity_base
    }
  }
}

module "ecs_task_definition_wiz" {
  source = "./modules/ecs_task_definition"

  family_service           = join("-", [aws_ecs_cluster.ecs_cluster.name, "ecs-task-wiz-definition"])
  requires_compatibilities = var.requires_compatibilities
  volumes                  = var.wiz_volumes
  ipc_mode                 = "host"
  pid_mode                 = "host"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn_wiz
  task_role_arn            = var.task_role_arn_wiz
  container_definition     = jsonencode([module.ecs_container_definition.wiz_json_map_object])
  tags                     = local.module_tags
}

module "ecs_service_daemon" {
  source = "./modules/ecs_service_daemon"

  service_name                    = join("-", [aws_ecs_cluster.ecs_cluster.name, "ecs-ec2-service-daemon"])
  ecs_service_cluster_id          = aws_ecs_cluster.ecs_cluster.name
  ecs_service_task_definition_arn = module.ecs_task_definition_wiz.ecs_task_definition_arn
  ecs_service_launch_type         = var.ecs_service_launch_type
  deployment_type                 = var.daemon_deployment_type
  subnets                         = var.subnets
  security_groups                 = var.security_groups
  desired_count                   = var.daemon_desired_count
  service_platform_version        = null
  scheduling_strategy             = var.scheduling_strategy
  tags                            = local.module_tags
}


module "ecs_container_definition" {
  source = "./modules/ecs_container_definition"

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
  wiz_user                         = local.wiz_user
  wiz_linux_parameters             = local.wiz_linux_parameters
  wiz_readonly_root_filesystem     = local.wiz_readonly_root_filesystem
  wiz_repository_Credentials = {
    credentialsParameter = local.wiz_repository_credentials
  }
  wiz_environment = local.wiz_environment
}
