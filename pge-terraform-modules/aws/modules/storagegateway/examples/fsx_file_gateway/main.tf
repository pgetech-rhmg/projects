/*
 * # AWS storagegateway Fsx_file_gateway Example
 * Prerequisites : 
 * To generate activation key for the storage gateway.
 * Step-1: Create one EC2 instance with the ami "ami-0aa80e1f5cd5b99be" (gateway instance).
 * Step-2: Create another EC2 instance to connect (SSH) with the gateway instance to generate the activation key.
 * Step-3: After doing SSH, in gateway instance select appropriate options to generate activation key.
 * Step-4: Once the activation key is generated store the value in ssm parameter store (ssm_parameter_activation_key).
 * Testing status: 
 * This example is not tested in the AWS console due to active_directory settings dependency. Tested until terraform plan.
 * # Terraform module example usage for storagegateway fsx_file_gateway
*/
#
#  Filename    : aws/modules/storagegateway/examples/Fsx_file_gateway/main.tf
#  Date        : 07 Oct 2022
#  Author      : TCS
#  Description : The terraform module creates storagegateway Fsx_file_gateway

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

locals {
  name          = "${var.name}-${random_string.name.result}"
  aws_role      = var.aws_role
  kms_role      = var.kms_role
  optional_tags = var.optional_tags
}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_vpc" "vpc" {
  id = data.aws_ssm_parameter.vpc_id.value
}

data "aws_ssm_parameter" "activation_key" {
  name = var.ssm_parameter_activation_key
}

data "aws_secretsmanager_secret" "fsx_file_system_association_username" {
  name = var.fsx_file_system_association_username
}

data "aws_secretsmanager_secret_version" "fsx_file_system_association_username_latest_ver" {
  secret_id = data.aws_secretsmanager_secret.fsx_file_system_association_username.id
}

data "aws_secretsmanager_secret" "fsx_file_system_association_password" {
  name = var.fsx_file_system_association_password
}

data "aws_secretsmanager_secret_version" "fsx_file_system_association_password_latest_ver" {
  secret_id = data.aws_secretsmanager_secret.fsx_file_system_association_password.id
}

data "aws_secretsmanager_secret" "secrets" {
  arn = module.secretsmanager.arn
}

data "aws_secretsmanager_secret_version" "secrets_activation_key" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "cloudwatch_log_group" {
  source  = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version = "0.1.3"

  name = var.logs_name
  tags = module.tags.tags
}

module "secretsmanager" {
  source  = "app.terraform.io/pgetech/secretsmanager/aws"
  version = "0.1.3"

  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = var.secretsmanager_description
  kms_key_id                 = null # replace with module.kms_key.key_arn once key is created
  recovery_window_in_days    = 0    #var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = data.aws_ssm_parameter.activation_key.value
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}

module "fsx_filesystem" {
  source = "../../"

  activation_gateway = {
    #As we are using object attributes in module, we need to pass null for attributes which we are not required in example.
    #using "module_variable_optional_attrs" in terraform block in module, we can make the varibale as optional.
    #As of now, that feature is experimental in terraform.    
    gateway_ip_address = null
    activation_key     = data.aws_secretsmanager_secret_version.secrets_activation_key.secret_string
  }
  gateway_name             = local.name
  gateway_timezone         = var.gateway_timezone
  gateway_type             = var.gateway_type
  smb_security_strategy    = var.smb_security_strategy
  gateway_vpc_endpoint     = var.gateway_vpc_endpoint
  cloudwatch_log_group_arn = module.cloudwatch_log_group.cloudwatch_log_group_arn
  #we are providing a dummy domain, username and password here.For testing this example, please a provide valid username & password.
  smb_active_directory_settings = {
    domain_name = var.domain_name
    password    = var.password
    username    = var.username
  }
  tags = merge(module.tags.tags, var.optional_tags)
}

data "aws_storagegateway_local_disk" "cache" {
  disk_node   = var.disk_node
  gateway_arn = module.fsx_filesystem.arn
}

module "fsx_filesystem_cache" {
  source = "../../modules/cache"

  gateway_arn = module.fsx_filesystem.arn
  disk_id     = data.aws_storagegateway_local_disk.cache.id
}

########################################################################

#Creates an AWS Storage Gateway SMB File Share.
module "smb_file_share" {
  source = "../../modules/smb_file_share"

  gateway_arn                    = module.fsx_filesystem.arn
  location_arn                   = module.s3.arn
  role_arn                       = module.iam.arn
  kms_key_arn                    = null # replace with module.kms_key.key_arn once key is created
  audit_destination_arn          = module.cloudwatch_log_group.cloudwatch_log_group_arn
  cache_stale_timeout_in_seconds = var.cache_stale_timeout_in_seconds
  timeouts                       = var.timeouts
  tags                           = merge(module.tags.tags, var.optional_tags)
}

###################################################################

#Associate an Amazon FSx file system with the FSx File Gateway.
module "fsx_file_system_association" {
  source = "../../modules/fsx_file_system_association"

  gateway_arn  = module.fsx_filesystem.arn
  location_arn = module.windows_file_system.fsx_windows_file_system_arn

  #we are providing a dummy username and password here.For testing this example, please a provide valid username & password.
  #The user name of the user credential that has permission to access the root share of the Amazon FSx file system.
  username = data.aws_secretsmanager_secret_version.fsx_file_system_association_username_latest_ver.secret_string
  #The password of the user credential.
  password = data.aws_secretsmanager_secret_version.fsx_file_system_association_username_latest_ver.secret_string

  audit_destination_arn = module.cloudwatch_log_group.cloudwatch_log_group_arn
  tags                  = merge(module.tags.tags, var.optional_tags)
}

####################################################################

#Manages a FSx Windows File System.
module "windows_file_system" {
  source  = "app.terraform.io/pgetech/fsx/aws"
  version = "0.1.1"

  file_system = {
    file_system_type                          = var.file_system_type
    storage_capacity                          = var.storage_capacity
    deployment_type                           = var.deployment_type
    storage_type                              = var.storage_type
    windows_throughput_capacity               = var.throughput_capacity
    windows_shared_active_directory_id        = var.windows_shared_active_directory_id
    windows_skip_final_backup                 = var.skip_final_backup
    windows_file_access_audit_log_level       = var.file_access_audit_log_level
    windows_file_share_access_audit_log_level = var.file_share_access_audit_log_level
    #As we are using object attributes in module, we need to pass null for attributes which we are not required in example.
    #using "module_variable_optional_attrs" in terraform block in module, we can make the varibale as optional.
    #As of now, that feature is experimental in terraform.
    #https://www.terraform.io/language/expressions/type-constraints#optional-object-type-attributes
    windows_preferred_subnet_id          = null
    windows_aliases                      = null
    lustre_per_unit_storage_throughput   = null
    lustre_drive_cache_type              = null
    windows_audit_log_destination        = null
    lustre_auto_import_policy            = null
    lustre_data_compression_type         = null
    lustre_file_system_type_version      = null
    lustre_export_path                   = null
    lustre_import_path                   = null
    lustre_imported_file_chunk_size      = null
    lustre_log_configuration_level       = null
    lustre_log_configuration_destination = null
  }

  subnet_ids         = [data.aws_ssm_parameter.subnet_id1.value]
  kms_key_id         = null # replace with module.kms_key.key_arn once key is created
  security_group_ids = [module.security_group_windows.sg_id]
  timeouts           = var.file_system_timeouts
  tags               = merge(module.tags.tags, var.optional_tags)
}

#################################################################

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"

#   name     = local.name
#   aws_role = var.aws_role
#   kms_role = var.kms_role
#   tags     = merge(module.tags.tags, var.optional_tags)
# }

#######################################################

#Security group for fsx windows file system.
module "security_group_windows" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name   = local.name
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 445,
    to               = 445,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = []
    description      = "CCOE Ingress rules"
    prefix_list_ids  = []
    },
    {
      from             = 5985,
      to               = 5985,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE Ingress rules"
      prefix_list_ids  = []
  }]
  cidr_egress_rules = [{
    from             = 53,
    to               = 53,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = []
    description      = "CCOE egress rules"
    prefix_list_ids  = []
    },
    {
      from             = 53,
      to               = 53,
      protocol         = "UDP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 88,
      to               = 88,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 88,
      to               = 88,
      protocol         = "UDP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 464,
      to               = 464,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 464,
      to               = 464,
      protocol         = "UDP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 389,
      to               = 389,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 389,
      to               = 389,
      protocol         = "UDP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 123,
      to               = 123,
      protocol         = "UDP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
    },
    {
      from             = 135,
      to               = 135,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 445,
      to               = 445,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 636,
      to               = 636,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 3268,
      to               = 3268,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 3269,
      to               = 3269,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 5985,
      to               = 5985,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 9389,
      to               = 9389,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
      }, {
      from             = 49152,
      to               = 65535,
      protocol         = "TCP",
      cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
      ipv6_cidr_blocks = []
      description      = "CCOE egress rules"
      prefix_list_ids  = []
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

############################################################################

#IAM role that a file gateway assumes when it accesses the underlying storage.
module "iam" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  aws_service = var.aws_service
  #Managed_Policy
  policy_arns = var.policy_arns
  tags        = merge(module.tags.tags, var.optional_tags)
}

############################################################################

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.name
  kms_key_arn = null # replace with module.kms_key.key_arn once key is created
  tags        = merge(module.tags.tags, local.optional_tags)
}