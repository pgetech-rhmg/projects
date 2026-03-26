/*
 * # AWS Elasticache-redis module example
 * # Usage creation for elasticache-redis single node instance with no replication.
*/
#
# Filename    : aws/modules/elasticache-redis/examples/single-node/main.tf
# Date        : 22 April 2022
# Author      : TCS
# Description : Usage creation for elasticache-redis single node instance with no replication.
#

locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order

  optional_tags = var.optional_tags
  aws_role      = var.aws_role

}

module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

#########################################

module "redis_single_node" {
  source                  = "../../"
  cluster_id              = var.cluster_id
  node_type               = var.node_type
  redis_engine_version    = var.redis_engine_version
  snapshot_retention      = var.snapshot_retention
  final_snapshot          = var.final_snapshot
  subnet_group_subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  maintenance_window      = var.maintenance_window
  snapshot_window         = var.snapshot_window
  security_group_ids      = [module.security_group_redis.sg_id]

  tags = merge(module.tags.tags, local.optional_tags)

  slow_logs_log_delivery_destination      = var.slow_logs_log_delivery_destination
  slow_logs_log_delivery_destination_type = var.slow_logs_log_delivery_destination_type
  slow_logs_log_delivery_log_format       = var.slow_logs_log_delivery_log_format
}

module "security_group_redis" {
  source             = "app.terraform.io/pgetech/security-group/aws"
  version            = "0.1.2"
  name               = var.sg_name
  description        = var.sg_description
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules
  cidr_egress_rules  = var.cidr_egress_rules
  tags               = merge(module.tags.tags, local.optional_tags)
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_name_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_name_private_subnet1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_name_private_subnet2
}


