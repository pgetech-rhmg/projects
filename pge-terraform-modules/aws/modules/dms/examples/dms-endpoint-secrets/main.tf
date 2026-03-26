/*
* # AWS DMS with usage example
* Terraform module which creates SAF2.0 dms resources in AWS.
* Secrets key is a pre-requisite and must be existing to run this example. 
*/
#
# Filename    : modules/dms/examples/dms/main.tf
# Date        : 5 July 2022
# Author      : TCS
# Description : The Terraform usage example creates aws dms resources


locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  optional_tags      = var.optional_tags
  aws_role           = var.aws_role
  kms_role           = var.kms_role
  Order              = var.Order
}


# To use encryption with this example module please refer 
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create kms key
# module "kms_key" {
#   source  = "app.terraform.io/pgetech/kms/aws"
#   version = "0.1.0"

#   name        = var.kms_name
#   policy      = templatefile("${path.module}/kms_user_policy.json", { account_num = data.aws_caller_identity.current.account_id, role_name = var.iam_role_name })
#   description = var.kms_description
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
#   tags        = merge(module.tags.tags, local.optional_tags)
# }


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

################################################################################
# Supporting Resources
################################################################################

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

module "dms_endpoint" {
  source = "../../modules/dms_endpoint_secrets"

  source_endpoint_id                              = var.source_endpoint_id
  source_endpoint_engine_name                     = var.source_endpoint_engine_name
  source_endpoint_kms_key_arn                     = null # replace with module.kms_key.key_arn, after key creation
  source_endpoint_database_name                   = var.source_endpoint_database_name
  source_endpoint_ssl_mode                        = var.source_endpoint_ssl_mode
  source_endpoint_secrets_manager_access_role_arn = module.secrets_manager_access_iam_role.arn
  source_endpoint_secrets_manager_arn             = var.source_endpoint_secrets_manager_arn
  source_certificate_arn                          = var.source_certificate_arn

  target_endpoint_id                              = var.target_endpoint_id
  target_endpoint_engine_name                     = var.target_endpoint_engine_name
  target_endpoint_kms_key_arn                     = null # replace with module.kms_key.key_arn, after key creation
  target_endpoint_database_name                   = var.target_endpoint_database_name
  target_endpoint_ssl_mode                        = var.target_endpoint_ssl_mode
  target_certificate_arn                          = var.target_certificate_arn
  target_endpoint_secrets_manager_access_role_arn = module.secrets_manager_access_iam_role.arn
  target_endpoint_secrets_manager_arn             = var.target_endpoint_secrets_manager_arn
  tags                                            = merge(module.tags.tags, local.optional_tags)
}

module "secrets_manager_access_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = var.iam_role_name
  aws_service = var.role_service
  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
  tags        = merge(module.tags.tags, local.optional_tags)
}



# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. 
# To use the AWS CLI or the AWS DMS API for your database migration, 
# you must add three IAM roles to your AWS account before you can use the features of AWS DMS.
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

module "access_for_endpoint" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = var.role_name_access_endpoint
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [templatefile("${path.module}/access_for_endpoint.json", { account_num = data.aws_caller_identity.current.account_id })] #Policy used for the access-for-endpoint.
}

module "cloudwatch_logs" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = var.role_name_cloudwatch_logs
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [file("${path.module}/cloudwatch_logs.json")] #Policy used for the cloudwatch_logs.
}

module "vpc_dms" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  name        = var.role_name_vpc
  aws_service = var.role_service
  tags        = merge(module.tags.tags, local.optional_tags)
  #inline_policy
  inline_policy = [file("${path.module}/dms_vpc_policy.json")] #Policy used for the dms vpc.
}

#security-group for DMS
module "security_group_dms" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.0"

  name               = var.sg_name_replication_instance
  description        = var.sg_description_replication_instance
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = var.cidr_ingress_rules_replication_instance
  cidr_egress_rules  = var.cidr_egress_rules_replication_instance
  tags               = merge(module.tags.tags, local.optional_tags)
}

#Replication_instance
module "dms_replication_instance" {
  source = "../../modules/replication_instance"

  instance_allocated_storage           = var.instance_allocated_storage
  instance_allow_major_version_upgrade = var.instance_allow_major_version_upgrade
  instance_apply_immediately           = var.instance_apply_immediately
  instance_version_upgrade             = var.instance_version_upgrade
  instance_availability_zone           = var.instance_availability_zone
  instance_engine_version              = var.instance_engine_version
  instance_multi_az                    = var.instance_multi_az
  #kms-customer managed key is not attached as the "CCOE-TFE DenyFromInternet" in the key policy is not allowing the creation of DMS replication_instance using kms-cmk. we are using default key which will be creating automatically.
  #instance_kms_key_arn               = null # replace with module.kms_key.key_arn, after key creation
  instance_preferred_maintenance      = var.instance_preferred_maintenance
  instance_publicly_accessible        = var.instance_publicly_accessible
  instance_replication_instance_class = var.instance_replication_instance_class
  instance_replication_id             = var.instance_replication_id
  vpc_security_group_ids              = [module.security_group_dms.sg_id]
  #Subnet group variables
  replication_subnet_group_description = var.replication_subnet_group_description
  replication_subnet_group_id          = var.replication_subnet_group_id
  subnet_ids                           = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags                                 = merge(module.tags.tags, local.optional_tags)

  #To handle dependency on the aws_iam_role_policy that Terraform cannot
  #automatically infer, so it must be declared explicitly. To create replication_instance via aws cli the resource depends on these three dedicated roles. 
  depends_on = [
    module.access_for_endpoint.arn,
    module.cloudwatch_logs.arn,
    module.vpc_dms.arn
  ]
}

module "dms_replication_task" {
  source = "../.."

  migration_type           = var.migration_type
  replication_instance_arn = module.dms_replication_instance.replication_instance_arn
  replication_task_id      = var.replication_task_id
  source_endpoint_arn      = module.dms_endpoint.dms_source_endpoint_arn
  table_mappings           = file("${path.module}/table-mapping.json")
  target_endpoint_arn      = module.dms_endpoint.dms_target_endpoint_arn
  tags                     = merge(module.tags.tags, local.optional_tags)
}

# SNS module for event_subscription
module "sns_topic" {
  source  = "app.terraform.io/pgetech/sns/aws"
  version = "0.1.0"

  snstopic_name         = var.snstopic_name
  snstopic_display_name = var.snstopic_display_name
  kms_key_id            = null # replace with module.kms_key.key_arn, after key creation

  tags = merge(module.tags.tags, local.optional_tags)
}

# DMS event_subscription
module "dms_event_subscription_one" {
  source           = "../../modules/event_subscription"
  event_enabled    = var.event_enabled
  event_categories = var.event_categories
  event_name       = var.event_name
  sns_topic_arn    = module.sns_topic.sns_topic_arn
  source_ids       = var.source_ids
  source_type      = var.source_type
  tags             = merge(module.tags.tags, local.optional_tags)
}