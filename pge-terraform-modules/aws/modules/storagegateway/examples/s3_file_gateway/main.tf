/*
 * # AWS storagegateway s3_file_gateway Example
 * Prerequisites : 
 * To generate activation key for the storage gateway.
 * Step-1: Create one EC2 instance with the ami "ami-0aa80e1f5cd5b99be" (gateway instance).
 * Step-2: Create another EC2 instance to connect (SSH) with the gateway instance to generate the activation key.
 * Step-3: After doing SSH, in gateway instance select appropriate options to generate activation key.
 * Step-4: Once the activation key is generated store the value in ssm parameter store (ssm_parameter_activation_key).
 * Testing status: 
 * This example is tested in the AWS console. Steps in the prerequisites are followed during testing.
 * # Terraform module example usage for storagegateway s3_file_gateway
*/
#
#  Filename    : aws/modules/storagegateway/examples/s3_file_gateway/main.tf
#  Date        : 07 Oct 2022
#  Author      : TCS
#  Description : The terraform module creates storagegateway s3_file_gateway

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

data "aws_ssm_parameter" "activation_key" {
  name = var.ssm_parameter_activation_key
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
  kms_key_id                 = null # replace with module.kms_key.key_arn after key creation
  recovery_window_in_days    = 0    #var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = data.aws_ssm_parameter.activation_key.value
  secret_version_enabled     = var.secret_version_enabled
  tags                       = merge(module.tags.tags, local.optional_tags)
}

module "s3_filesystem" {
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
  gateway_vpc_endpoint     = var.gateway_vpc_endpoint
  cloudwatch_log_group_arn = module.cloudwatch_log_group.cloudwatch_log_group_arn
  maintenance_start_time = {
    day_of_month   = var.day_of_month
    day_of_week    = var.day_of_week
    hour_of_day    = var.hour_of_day
    minute_of_hour = var.minute_of_hour
  }

  tags = merge(module.tags.tags, var.optional_tags)
}

data "aws_storagegateway_local_disk" "cache" {
  disk_node   = var.disk_node
  gateway_arn = module.s3_filesystem.arn
}

module "s3_filesystem_cache" {
  source = "../../modules/cache"

  gateway_arn = module.s3_filesystem.arn
  disk_id     = data.aws_storagegateway_local_disk.cache.id
}

module "nfs_file_share" {
  source = "../../modules/nfs_file_share"

  client_list           = var.client_list
  gateway_arn           = module.s3_filesystem.arn
  location_arn          = module.s3.arn
  role_arn              = module.storagegateway_iam_role.arn
  kms_key_arn           = null # replace with module.kms_key.key_arn after key creation
  audit_destination_arn = module.cloudwatch_log_group.cloudwatch_log_group_arn
  timeouts              = var.timeouts
  vpc_endpoint_bucket = {
    bucket_region         = ""
    vpc_endpoint_dns_name = ""
  }
  nfs_file_share_defaults = {
    directory_mode = var.directory_mode
    file_mode      = var.file_mode
    group_id       = var.group_id
    owner_id       = var.owner_id
  }
  cache_stale_timeout_in_seconds = var.cache_stale_timeout_in_seconds

  tags = merge(module.tags.tags, var.optional_tags)
}

module "s3" {
  source  = "app.terraform.io/pgetech/s3/aws"
  version = "0.1.1"

  bucket_name = local.name
  kms_key_arn = null # replace with module.kms_key.key_arn after key creation
  policy      = data.aws_iam_policy_document.allow_access.json
  tags        = module.tags.tags
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      module.s3.arn,
      "${module.s3.arn}/*"
    ]
  }
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.2"

#   name     = "storagegateway-cmk-${local.name}"
#   policy   = file("${path.module}/kms_user_policy.json")
#   aws_role = var.aws_role
#   kms_role = var.kms_role
#   tags     = merge(module.tags.tags, var.optional_tags)
# }

module "storagegateway_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name          = local.name
  aws_service   = var.aws_service
  tags          = merge(module.tags.tags, local.optional_tags)
  inline_policy = [file("${path.module}/storagegateway_iam_role.json")]
}