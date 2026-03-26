/*
 * # AWS Fsx lustre file system with data repository association module example
*/
#
#  Filename    : aws/modules/fsx/examples/lustre_with_data_repository_association/main.tf
#  Date        : 27 september 2022
#  Author      : TCS
#  Description : The terraform example creates a fsx lustre file system with data repository association


locals {
  name  = "${var.name}-${random_string.name.result}"
  Order = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
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
  Order              = local.Order
}

#########################################
# Supporting Resources
#########################################

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_vpc" "vpc" {
  id = data.aws_ssm_parameter.vpc_id.value
}

############################################

module "lustre_data_repository_association" {
  source = "../../modules/lustre_with_data_repository_association"

  #lustre_file_system
  storage_capacity               = var.storage_capacity
  per_unit_storage_throughput    = var.per_unit_storage_throughput
  lustre_log_configuration_level = var.log_configuration_level
  subnet_ids                     = [data.aws_ssm_parameter.subnet_id1.value]
  kms_key_id                     = null # replace with module.kms_key.key_arn, after key creation
  security_group_ids             = [module.security_group_lustre.sg_id]

  #data_repository_association
  data_repository_path                 = "s3://${module.s3.id}"
  file_system_path                     = var.file_system_path
  auto_import_policy_events            = var.auto_import_policy_events
  auto_export_policy_events            = var.auto_export_policy_events
  data_repository_association_timeouts = var.data_repository_association_timeouts
  tags                                 = merge(module.tags.tags, var.optional_tags)
}

###############################################
#The module s3 is used to link with the lustre file system.
#The link between directory on the file system and an S3 bucket is called a data repository association .
module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, var.optional_tags)
}

###############################################

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name     = local.name
#   aws_role = var.aws_role
#   kms_role = var.kms_role
#   tags     = merge(module.tags.tags, var.optional_tags)
# }

###############################################

module "security_group_lustre" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 988,
    to               = 988,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 1021,
      to               = 1023,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 988,
    to               = 988,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 1021,
      to               = 1023,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}