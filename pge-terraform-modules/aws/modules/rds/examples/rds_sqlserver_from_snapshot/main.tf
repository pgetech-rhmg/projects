/*
 * # RDS SQL Server module
 * Terraform module which creates an RDS SQL Server Database from a DB snapshot identifier.
 *
 * Pre-Requisites:
 *    1. IAM Role rds-enhanced-monitoring-role exists within your account (should be automatically deployed to PG&E accounts)
 *    2. RDS VPC Endpoint exists for the account.  If not, you can deploy one in the account as shown with the rds_vpc_endpoint example module (rds/examples/rds_vpc_endpoint)
 * Notes:
 *   1. At this time, this module is not fully SAF 2.0 Compliant.  Compliance will be implemented at a later date.
 *   2. This module will also create various SSM Parameters to store data pertaining to the SQL Server DB.
 *   3. This example should take roughly one hour to deploy if you are running it locally.  Be patient my friend.
 *   4. This particular module is modeled from [link](https://github.com/pgetech/aws-cfn-sqlserver).  If you are creating the SQL Server Enterprise Edition, db_name variable must be null.
 *   5. if the DataClassification is not internal or public, passing null KMS will result in error, hence create the KMS key using the module in the code, its a 2 step process
        a. first comment all the code except for kms module, run terraform apply, this create the KMS key and stores in state file.
        b. uncomment remaining code, replace null for kms for all the arguments with the module created value.
 *
#  Notes       
#      If the password you pass in does not satisfy the minimum length as per SAF compliance which is min 16 chars,
#      a validation is put in place to meet the requirement, Password will be stored in secrets manager. 
#      If argument manage_master_user_password is set to "true", then user provided password will be disregarded,
#      and AWS creates random password and creates a secret manager and stores this password, rotation is enabled and default is 7 days.
*/


#
#  Filename    : modules/rds/examples/rds_sqlserver_from_snapshot/main.tf
#  Date        : 5/26/2022
#  Author      : PGE
#  Description : Example of RDS SQL Server module from DB Snapshot identifier
#
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}


data "aws_ssm_parameter" "private_subnet1_id" {
  name = "/vpc/privatesubnet1/id"
}
data "aws_ssm_parameter" "private_subnet2_id" {
  name = "/vpc/privatesubnet2/id"
}
data "aws_ssm_parameter" "private_subnet3_id" {
  name = "/vpc/privatesubnet3/id"
}
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}
data "aws_caller_identity" "current" {}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source       = "app.terraform.io/pgetech/kms/aws"
#   version      = "0.1.2"
#   name         = var.kms_name
#   description  = var.kms_description
#   multi_region = true
#   tags         = var.tags
#   aws_role     = var.aws_role
#   kms_role     = var.kms_role
# }

# Use the output of the `master_user_secret` object, which includes `secret_arn`,
# to manage the rotation rules.
resource "aws_secretsmanager_secret_rotation" "this" {
  count     = var.manage_master_user_password ? 1 : 0
  secret_id = one(module.rds_sqlserver[*].sqlserver_all[0].aws_db_instance_this_mssql_all[0].master_user_secret[0].secret_arn)

  rotation_rules {
    automatically_after_days = 30
  }
}

module "rds_sqlserver" {

  source = "../../modules/sqlserver"

  #db instance
  identifier = var.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  kms_key_id    = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  license_model = var.license_model

  username                      = var.username
  password                      = var.password
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  port                          = var.port
  vpc_id                        = data.aws_ssm_parameter.vpc_id.value
  multi_az                      = var.multi_az
  iops                          = var.iops

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  snapshot_identifier         = var.snapshot_identifier
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.final_snapshot_identifier

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  replicate_source_db                   = var.replicate_source_db

  backup_window         = var.backup_window
  max_allocated_storage = var.max_allocated_storage
  monitoring_interval   = var.monitoring_interval
  monitoring_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rds-enhanced-monitoring-role"
  character_set_name    = var.character_set_name

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  timeouts                        = var.timeouts
  timezone                        = var.timezone
  deletion_protection             = var.deletion_protection
  restore_to_point_in_time        = var.restore_to_point_in_time
  db_instance_tags                = var.db_instance_tags

  #security group
  cidr_ingress_rules  = var.cidr_ingress_rules
  cidr_egress_rules   = var.cidr_egress_rules
  security_group_tags = var.security_group_tags

  #db parameter group
  family                  = var.family
  parameters              = var.parameters
  db_parameter_group_tags = var.db_parameter_group_tags

  #db subnet group
  subnet_ids = [data.aws_ssm_parameter.private_subnet3_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet1_id.value]

  db_subnet_group_tags = var.db_subnet_group_tags

  # db option group

  db_option_group_tags  = var.db_option_group_tags
  options               = var.options
  option_group_timeouts = var.option_group_timeouts
  # SSM
  key_id = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  #db cloudwatch metric alarms
  actions_alarm     = var.actions_alarm
  actions_ok        = var.actions_ok
  evaluation_period = var.evaluation_period
  statistic_period  = var.statistic_period

  cpu_credit_balance_too_low_threshold      = var.cpu_credit_balance_too_low_threshold
  cpu_utilization_too_high_threshold        = var.cpu_utilization_too_high_threshold
  disk_queue_depth_too_high_threshold       = var.disk_queue_depth_too_high_threshold
  disk_free_storage_space_too_low_threshold = var.disk_free_storage_space_too_low_threshold
  disk_burst_balance_too_low_threshold      = var.disk_burst_balance_too_low_threshold
  memory_freeable_too_low_threshold         = var.memory_freeable_too_low_threshold
  memory_swap_usage_too_high_threshold      = var.memory_swap_usage_too_high_threshold

  tags = var.tags

}

resource "aws_ssm_parameter" "db_subnet_group" {
  name        = "/rds/subnetgroup/${module.rds_sqlserver.db_instance_id}"
  type        = "String"
  description = "RDS db subnet group"
  value       = module.rds_sqlserver.db_subnet_group_id
}

resource "aws_ssm_parameter" "db_security_group" {
  name        = "/rds/securitygroup/${module.rds_sqlserver.db_instance_id}"
  type        = "String"
  description = "RDS db security group"
  value       = module.rds_sqlserver.security_group_id
}

resource "aws_ssm_parameter" "db_parameter_group" {
  name        = "/rds/parametergroup/instance/${module.rds_sqlserver.db_instance_id}"
  type        = "String"
  description = "RDS db parameter group"
  value       = module.rds_sqlserver.db_parameter_group_id
}

resource "aws_ssm_parameter" "primary_db_endpoint" {
  name        = "/rds/endpoint/primary/${module.rds_sqlserver.db_instance_id}"
  type        = "String"
  description = "RDS primary db endpoint"
  value       = module.rds_sqlserver.db_instance_endpoint
}

