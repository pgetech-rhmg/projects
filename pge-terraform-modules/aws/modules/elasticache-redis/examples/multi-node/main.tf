/*
 * # AWS Elasticache-redis module example
 * # Usage creation for Elasticache redis multinode cluster enabled cluster with replication and data partitioning.
*/
#
# Filename    : aws/modules/elasticache-redis/examples/multi-node/main.tf
# Date        : 14 April 2022
# Author      : TCS
# Description : Usage creation for Elasticache redis multinode cluster enabled cluster with replication and data partitioning.


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
  kms_role      = var.kms_role
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

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

#########################################

module "redis_multi_node" {
  source = "../../modules/elasticache-redis-multinode-cluster"

  # Cluster
  cluster_id              = var.cluster_id
  nodetype                = var.nodetype
  redis_engine_version    = var.redis_engine_version
  apply_immediately       = var.apply_immediately
  auth_token              = data.aws_ssm_parameter.auth_token.value
  tags                    = merge(module.tags.tags, local.optional_tags)
  subnet_group_subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group
  security_group_ids      = [module.security_group_redis.sg_id]
  #kms-customer managed key is not attached as the "CCOE-TFE DenyFromInternet" in the key policy is not allowing the creation of redis clusters using kms-cmk.
  kms_key_id                              = null # replace with module.kms_key.key_arn, after key creation
  slow_logs_log_delivery_destination      = var.slow_logs_log_delivery_destination
  slow_logs_log_delivery_destination_type = var.slow_logs_log_delivery_destination_type
  slow_logs_log_delivery_log_format       = var.slow_logs_log_delivery_log_format
  final_snapshot                          = var.final_snapshot
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

data "aws_ssm_parameter" "auth_token" {
  name = var.ssm_parameter_name_auth_token
}

