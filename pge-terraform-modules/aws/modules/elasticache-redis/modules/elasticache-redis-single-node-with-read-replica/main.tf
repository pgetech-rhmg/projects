/*
 * # AWS Elasticache-redis module
 * Terraform module which creates SAF2.0 Elasticache-redis single node instance with read replica in AWS.
 * Creates Elasticache-redis cluster (cluster mode disabled) with read replica.
*/

#  Filename    : aws/modules/Elasticache-redis/modules/elasticache-redis-multinode-cluster/main.tf
#  Date        : 11 April 2022
#  Author      : TCS
#  Description : Creates Elasticache-redis cluster (cluster mode disabled) with read replica.
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

# Single node cluster 
resource "aws_elasticache_replication_group" "elasticache_replication_group" {

  replication_group_id        = var.cluster_id
  description                 = "Elasticache replication group-${var.cluster_id}"
  apply_immediately           = var.apply_immediately
  at_rest_encryption_enabled  = true
  auth_token                  = var.auth_token
  auto_minor_version_upgrade  = true
  automatic_failover_enabled  = var.automatic_failover_enabled
  data_tiering_enabled        = var.data_tiering_enabled
  engine                      = "redis"
  engine_version              = var.redis_engine_version
  node_type                   = var.node_type
  port                        = var.port_number
  parameter_group_name        = var.create_new_parametergroup ? aws_elasticache_parameter_group.paragroup[0].id : var.existing_parameter_group_name
  num_cache_clusters          = var.num_cache_clusters
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs
  maintenance_window          = var.maintenance_window
  multi_az_enabled            = var.multi_az_enabled
  notification_topic_arn      = var.notification_topic_arn
  final_snapshot_identifier   = var.final_snapshot != null ? "${var.final_snapshot}-main-${var.cluster_id}" : null
  global_replication_group_id = var.global_replication_group_id
  kms_key_id                  = var.kms_key_id
  security_group_ids          = var.security_group_ids
  security_group_names        = var.security_group_names
  snapshot_arns               = var.snapshot_arns
  snapshot_name               = var.snapshot_name
  snapshot_retention_limit    = var.snapshot_retention
  snapshot_window             = var.snapshot_window
  subnet_group_name           = aws_elasticache_subnet_group.redis.name
  transit_encryption_enabled  = true
  tags                        = local.module_tags
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

}

# READ REPLICA

resource "aws_elasticache_cluster" "read_replica_single_node" {

  cluster_id                 = "r-replica-${var.cluster_id}"
  replication_group_id       = aws_elasticache_replication_group.elasticache_replication_group.id
  apply_immediately          = var.replica_apply_immediately
  auto_minor_version_upgrade = true
  final_snapshot_identifier  = var.final_snapshot != null ? "${var.final_snapshot}-replica-${var.cluster_id}" : null
  notification_topic_arn     = var.replica_notification_topic_arn
  snapshot_name              = var.replica_snapshot_name
  tags                       = local.module_tags

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

}

resource "aws_elasticache_subnet_group" "redis" {
  name        = var.cluster_id
  description = "Elasticache subnet group for-${var.cluster_id}"
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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo KMS key id is mandatory for the DataClassification type; exit 1"]
}