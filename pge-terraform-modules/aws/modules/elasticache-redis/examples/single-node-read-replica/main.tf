/*
 * # AWS Elasticache-redis module example
 * # Usage creation for elasticache-redis cluster (cluster mode disabled) with read replica.
*/
#
# Filename    : aws/modules/elasticache-redis/examples/single-node/main.tf
# Date        : 22 April 2022
# Author      : TCS
# Description : Usage creation for elasticache-redis cluster (cluster mode disabled) with read replica.
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
  kms_role      = var.kms_role
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
#  source      = "app.terraform.io/pgetech/kms/aws"
#  version     = "0.1.2"
#  name        = var.kms_name
#  description = var.kms_description
#  tags        = merge(module.tags.tags, local.optional_tags)
#  aws_role    = local.aws_role
#  kms_role    = local.kms_role
# }

#########################################

module "redis_single_node" {
  source                  = "../../modules/elasticache-redis-single-node-with-read-replica"
  cluster_id              = var.cluster_id
  node_type               = var.node_type
  redis_engine_version    = var.redis_engine_version
  snapshot_retention      = var.snapshot_retention
  subnet_group_subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value]
  maintenance_window      = var.maintenance_window
  snapshot_window         = var.snapshot_window
  auth_token              = data.aws_ssm_parameter.auth_token.value
  security_group_ids      = [module.security_group_redis.sg_id]
  #kms-customer managed key is not attached as the "CCOE-TFE DenyFromInternet" in the key policy is not allowing the creation of redis clusters using kms-cmk.
  kms_key_id     = null # replace with module.kms_key.key_arn, after key creation
  tags           = merge(module.tags.tags, local.optional_tags)
  final_snapshot = var.final_snapshot
}

module "redis_single_node_global_replication" {
  source = "../../modules/elasticache-redis-global-replication-group"
  depends_on = [
    module.redis_single_node
  ]

  primary_replication_group_id = module.redis_single_node.replication_group_id
  redis_engine_version         = var.redis_engine_version
  global_suffix                = var.global_suffix
  cluster_id                   = var.cluster_id
  tags                         = merge(module.tags.tags, local.optional_tags)
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


