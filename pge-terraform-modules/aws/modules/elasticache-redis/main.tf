/*
 * # AWS Elasticache-redis module
 * # Terraform module which creates SAF2.0 Elasticache-redis single node instance in AWS.
 * # Creates elasticache-redis single node instance with no replication.
*/

#  Filename    : aws/modules/elasticache-redis/main.tf
#  Date        : 21 April 2022
#  Author      : TCS
#  Description :  Creates elasticache-redis single node instance with no replication.
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

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })

  # The parameter group family coincides with the cluster's engine version. The below line fetches the parameter_group "family" from the "redis_engine_version".
  para_family = join("", ["redis", substr(var.redis_engine_version, 0, 3)])
}

resource "aws_elasticache_cluster" "redis_single_node" {
  depends_on = [
    aws_elasticache_subnet_group.redis,
    aws_elasticache_parameter_group.paragroup
  ]

  cluster_id                 = var.cluster_id
  engine                     = "redis"
  node_type                  = var.node_type
  engine_version             = var.redis_engine_version
  port                       = var.port
  parameter_group_name       = var.create_new_parametergroup ? aws_elasticache_parameter_group.paragroup[0].id : var.existing_parameter_group_name
  num_cache_nodes            = 1
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = true
  final_snapshot_identifier  = var.final_snapshot != null ? "${var.final_snapshot}-${var.cluster_id}" : null
  maintenance_window         = var.maintenance_window
  notification_topic_arn     = var.notification_topic_arn
  replication_group_id       = var.replication_group_id
  security_group_ids         = var.security_group_ids
  snapshot_arns              = var.snapshot_arns
  snapshot_name              = var.snapshot_name
  snapshot_retention_limit   = var.snapshot_retention
  snapshot_window            = var.snapshot_window
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  # checks for the variable 'slow_logs_log_delivery_destination'. If the value for the variable is provided, then it enables the slow_logs_log_delivery.
  dynamic "log_delivery_configuration" {
    for_each = var.slow_logs_log_delivery_destination != null ? [true] : []
    content {
      destination      = var.slow_logs_log_delivery_destination
      destination_type = var.slow_logs_log_delivery_destination_type
      log_format       = var.slow_logs_log_delivery_log_format
      log_type         = "slow-log"
    }
  }
  # checks for the variable 'engine_logs_log_delivery_destination'. If the value for the variable is provided, then it enables the engine_logs_log_delivery.
  dynamic "log_delivery_configuration" {
    for_each = var.engine_logs_log_delivery_destination != null ? [true] : []
    content {
      destination      = var.engine_logs_log_delivery_destination
      destination_type = var.engine_logs_log_delivery_destination_type
      log_format       = var.engine_logs_log_delivery_log_format
      log_type         = "engine-log"
    }
  }
  tags = local.module_tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = var.cluster_id
  description = var.subnet_group_description_redis
  subnet_ids  = var.subnet_group_subnet_ids
  tags        = local.module_tags
}

resource "aws_elasticache_parameter_group" "paragroup" {

  # The resource will be created if the boolean variable 'create_new_parametergroup value is 'true'
  count = var.create_new_parametergroup ? 1 : 0

  name        = var.cluster_id
  family      = local.para_family
  description = "Redis parameter group-${var.cluster_id}"
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
  tags = local.module_tags
}

