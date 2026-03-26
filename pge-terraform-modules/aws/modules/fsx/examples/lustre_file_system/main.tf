/*
 * # AWS Fsx lustre file system module example
*/
#
#  Filename    : aws/modules/fsx/examples/lustre_file_system/main.tf
#  Date        : 13 september 2022
#  Author      : TCS
#  Description : The terraform example creates a fsx lustre file system


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

data "aws_subnet" "fsx_lustre_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

############################################

module "lustre_file_system" {
  source = "../.."

  file_system = {
    file_system_type                   = var.file_system_type
    storage_capacity                   = var.storage_capacity
    deployment_type                    = var.deployment_type
    storage_type                       = var.storage_type
    lustre_per_unit_storage_throughput = var.per_unit_storage_throughput
    lustre_data_compression_type       = var.lustre_data_compression_type
    lustre_file_system_type_version    = var.lustre_file_system_type_version
    lustre_log_configuration_level     = var.log_configuration_level
    #As we are using object attributes in module, we need to pass null for attributes which we are not required in example.
    #using "module_variable_optional_attrs" in terraform block in module, we can make the varibale as optional.
    #As of now, that feature is experimental in terraform.
    #https://www.terraform.io/language/expressions/type-constraints#optional-object-type-attributes
    lustre_drive_cache_type                   = null
    lustre_auto_import_policy                 = null
    lustre_export_path                        = null
    lustre_import_path                        = null
    lustre_imported_file_chunk_size           = null
    lustre_log_configuration_destination      = null
    windows_throughput_capacity               = null
    windows_preferred_subnet_id               = null
    windows_shared_active_directory_id        = null
    windows_aliases                           = null
    windows_skip_final_backup                 = null
    windows_audit_log_destination             = null
    windows_file_access_audit_log_level       = null
    windows_file_share_access_audit_log_level = null
  }

  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  kms_key_id         = null # replace with module.kms_key.key_arn, after key creation
  security_group_ids = [module.security_group_lustre.sg_id]
  tags               = merge(module.tags.tags, var.optional_tags)
}

###############################################
#Provides a FSx user initiated Backup for the lustre_file_system
module "lustre_backup" {
  source = "../../modules/backup"

  file_system_id = module.lustre_file_system.fsx_lustre_file_system_id
  tags           = merge(module.tags.tags, var.optional_tags)
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
    cidr_blocks      = [data.aws_subnet.fsx_lustre_1.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 1021,
      to               = 1023,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_subnet.fsx_lustre_1.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 988,
    to               = 988,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_subnet.fsx_lustre_1.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 1021,
      to               = 1023,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_subnet.fsx_lustre_1.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

