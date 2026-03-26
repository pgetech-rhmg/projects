/*
 * # AWS Neptune User module example
*/
#
#  Filename    : aws/modules/Neptune/examples/cluster_with_two_read_replicas/main.tf
#  Date        : 12 July 2022
#  Author      : TCS
#  Description : The terraform example creates a cluster with two read replicas


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  Order              = var.Order
  common_name        = "${var.name}-${random_string.name.result}"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_subnet" "selected_id1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "selected_id2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

data "aws_subnet" "selected_id3" {
  id = data.aws_ssm_parameter.subnet_id3.value
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.0"
#   name        = "alias/${local.common_name}"
#   kms_role    = var.kms_role
#   description = "CMK for encrypting Neptune"
#   tags        = merge(module.tags.tags, local.optional_tags)
#   aws_role    = var.aws_role
#   policy      = file("${path.module}/${var.template_file_name}")
# }

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
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


module "neptune_cluster" {
  source = "../../"

  cluster_identifier     = local.common_name
  vpc_security_group_ids = [module.security_group.sg_id]
  kms_key_arn            = null # replace with module.kms_key.key_arn, after key creation

  engine_version                       = var.engine_version
  neptune_subnet_group_name            = module.neptune_subnet_group.neptune_subnet_group_id
  neptune_cluster_parameter_group_name = module.neptune_cluster_parameter_group.neptune_cluster_parameter_group_id
  skip_final_snapshot                  = var.skip_final_snapshot
  tags                                 = merge(module.tags.tags, local.optional_tags)

}

module "security_group" {
  source      = "app.terraform.io/pgetech/security-group/aws"
  version     = "0.1.2"
  name        = local.common_name
  description = "Security group for example usage"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.selected_id1.cidr_block, data.aws_subnet.selected_id2.cidr_block, data.aws_subnet.selected_id3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 0,
    to               = 65535,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.selected_id1.cidr_block, data.aws_subnet.selected_id2.cidr_block, data.aws_subnet.selected_id3.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "sample egress rules"
  }]
  tags = merge(module.tags.tags, local.optional_tags)
}

module "neptune_cluster_instance" {
  source = "../../modules/cluster_instance"

  instance_count     = var.instance_count
  cluster_identifier = module.neptune_cluster.neptune_cluster_id
  instance_class     = var.instance_class

  identifier                   = local.common_name
  engine_version               = var.engine_version
  neptune_subnet_group_name    = module.neptune_subnet_group.neptune_subnet_group_id                         #module.neptune_subnet_group.neptune_subnet_group_id#"${var.neptune_subnet_group_name}-${random_string.name.result}"
  neptune_parameter_group_name = module.neptune_instance_parameter_group.neptune_instance_parameter_group_id #"${var.neptune_instance_parameter_group_name}-${random_string.name.result}"
  tags                         = merge(module.tags.tags, local.optional_tags)

  cluster_instance_timeouts = [{
    create = "90m"
    update = "90m"
    delete = "90m"
  }]
}



#Time sleep is used to wait for 15 mins after cluster resource creation, so that it will have enough time to get created in console, for endpoint resource to be created 
resource "time_sleep" "wait_20min" {
  depends_on = [module.neptune_cluster]

  create_duration = "20m"
}

module "neptune_cluster_endpoint" {
  depends_on = [time_sleep.wait_20min]
  source     = "../../modules/cluster_endpoint"

  neptune_cluster_identifier          = module.neptune_cluster.neptune_cluster_id
  neptune_cluster_endpoint_identifier = local.common_name
  neptune_cluster_endpoint_type       = var.neptune_cluster_endpoint_type

  #if members block is used both static_members and excluded_members are required, if one of them has no value still need to pass as empty.

  tags = merge(module.tags.tags, local.optional_tags)
}

module "neptune_cluster_parameter_group" {
  source = "../../modules/cluster_parameter_group"

  #cluster parameter group variables 
  neptune_cluster_parameter_group_name = local.common_name

  parameter = {
    neptune_streams      = var.neptune_streams_value,
    neptune_lookup_cache = var.neptune_lookup_cache_value,
    neptune_result_cache = var.neptune_result_cache_value,
    neptune_ml_iam_role  = var.neptune_ml_iam_role_value,
    neptune_ml_endpoint  = var.neptune_ml_endpoint_value
  }

  tags = merge(module.tags.tags, local.optional_tags)
}

module "neptune_instance_parameter_group" {
  source = "../../modules/instance_parameter_group"

  #instance parameter group variables 
  neptune_instance_parameter_group_name = local.common_name

  parameter = {
    neptune_dfe_query_engine = var.neptune_dfe_query_engine_value,
    neptune_query_timeout    = var.neptune_query_timeout_value
  }
  tags = merge(module.tags.tags, local.optional_tags)
}

module "neptune_subnet_group" {
  source = "../../modules/subnet_group"

  neptune_subnet_group_name = local.common_name
  neptune_subnet_ids        = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags                      = merge(module.tags.tags, local.optional_tags)
}