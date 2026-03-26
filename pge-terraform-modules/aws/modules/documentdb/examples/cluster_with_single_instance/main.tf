/*
 * # AWS DocumentDB Cluster with single instance User module example
*/
#
#  Filename    : aws/modules/documentdb/examples/cluster_with_single_instance/main.tf
#  Date        : 05 August 2022
#  Author      : TCS
#  Description : The terraform example creates a cluster with single instance


locals {
  kms_custom_policy = templatefile(
    "${path.module}/kms_policy.json",
    {
      account_num = data.aws_caller_identity.current.account_id
      role_name   = var.aws_role
    }
  )
  name = "${var.name}-${random_string.name.result}"
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.0.10"
#   name        = "alias/${local.name}"
#   description = "CMK for encrypting Redshift"
#   tags        = merge(module.tags.tags, var.optional_tags)
#   aws_role    = var.aws_role
#   policy      = local.kms_custom_policy
#   kms_role    = var.kms_role
# }

# The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

resource "random_password" "cluster_password" {
  length      = 16
  special     = false
  min_numeric = 1
}

resource "random_password" "cluster_username" {
  length      = 16
  special     = false
  min_numeric = 1
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#########################################
# Supporting Resources
#########################################

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
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

data "aws_subnet" "docdb_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "docdb_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

module "docdb_cluster" {
  source = "../.."

  cluster_identifier              = local.name
  cluster_master_username         = "aws${random_password.cluster_username.result}"
  cluster_master_password         = random_password.cluster_password.result
  cluster_kms_key_id              = null # replace with module.kms_key.key_arn, after key creation
  cluster_engine_version          = var.cluster_engine_version
  cluster_vpc_security_group_ids  = [module.security_group_docdb.sg_id]
  cluster_skip_final_snapshot     = var.cluster_skip_final_snapshot
  db_subnet_group_name            = module.subnet_group.docdb_subnet_group_id
  db_cluster_parameter_group_name = module.cluster_parameter_group.documentdb_cluster_parameter_group_id
  cluster_timeouts                = var.cluster_timeouts
  tags                            = merge(module.tags.tags, var.optional_tags)
}

module "security_group_docdb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}



module "subnet_group" {
  source = "../../modules/subnet_group"

  subnet_group_name       = local.name
  subnet_group_subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "cluster_parameter_group" {
  source = "../../modules/cluster_parameter_group"

  docdb_cluster_parameter_group_family = var.docdb_cluster_parameter_group_family
  docdb_cluster_parameter_group_name   = local.name
  parameter                            = var.parameter
  tags                                 = merge(module.tags.tags, var.optional_tags)
}

module "cluster_instance" {
  source = "../../modules/cluster_instance"

  cluster_identifier = module.docdb_cluster.docdb_cluster_id
  instance_class     = var.cluster_instance_instance_class
  tags               = merge(module.tags.tags, var.optional_tags)
}