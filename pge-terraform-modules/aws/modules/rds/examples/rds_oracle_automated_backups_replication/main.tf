/*
 * # RDS Oracle module with automated backup replication example
 * Terraform module which creates SAF2.0 Oracle RDS Database with automated backup replication
 * Pre-Requisites:
 *    1. Directory Service and it's domain are shared within your account.  Your security group egress cidr should reflect the VPC of the Managed AD account.
 *    2. IAM Role rds-directoryservice-kerberos-access-role exists within your account (should be automatically deployed to PG&E accounts), if not available work with respective team in PG&E.
 *    3. S3 integration requires an s3 bucket has been previously created and the arn passed in this module as a variable
 *    4. S3 key must exist/ uploaded to S3 bucket before running the module
 *    5. To have automated replication, multi region KMS must be created before running the module
 *    6. RDS VPC Endpoint exists for the account.  If not, you can deploy one in the account as shown with the rds_vpc_endpoint example module (rds/examples/rds_vpc_endpoint)
 *    7. if the DataClassification is not internal or public, passing null KMS will result in error, hence create the KMS key using the module in the code, its a 2 step process
        a. first comment all the code except for kms module, run terraform apply, this create the KMS key and stores in state file.
        b. uncomment remaining code, replace null for kms for all the arguments with the module created value.

#  Notes       
#      If the password you pass in does not satisfy the minimum length as per SAF compliance which is min 16 chars,
#      a validation is put in place to meet the requirement, Password will be stored in secrets manager. 
#      If argument manage_master_user_password is set to "true", then user provided password will be disregarded,
#      and AWS creates random password and creates a secret manager and stores this password, rotation is enabled and default is 7 days.
*/

#
#  Filename    : modules/rds/examples/rds_oracle_automated_backups_replication/main.tf
#  Date        : 9/20/2023
#  Author      : PGE
#  Description : RDS Oracle Module with automated backup replication creation main file.
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

locals {
  ad_domain_id     = data.aws_directory_service_directory.shared.id
  ad_iam_role_name = data.aws_iam_role.rds_managed_ad.arn != null ? data.aws_iam_role.rds_managed_ad.id : null

  create               = (local.ad_domain_id != null) && (local.ad_iam_role_name != null) ? 1 : 0
  lambda_function_name = "${var.lambda_function_name}_${var.identifier}"

  #ports and protocol
  ingress = [
    { port : 1521, protocol : "tcp" },
    { port : 2484, protocol : "tcp" },
    { port : 443, protocol : "tcp" },
  ]

  #Necessary for SAF compliance, you need your outbound security group rule to
  #contain a rule with the ManagedAD VPC Cidr.  In this case it is 10.90.124.0/23
  managed_ad_cidr = "10.90.124.0/23"

}
locals {
  aws_role = var.aws_role

  account_num = var.account_num
  user        = var.user

}
data "aws_directory_service_directory" "shared" {
  directory_id = var.domain
}
data "aws_iam_role" "rds_managed_ad" {
  name = var.domain_iam_role_name
}
data "aws_ssm_parameter" "private_subnet1_id" {
  name = "/vpc/2/privatesubnet1/id"
}
data "aws_ssm_parameter" "private_subnet2_id" {
  name = "/vpc/2/privatesubnet2/id"
}
data "aws_ssm_parameter" "private_subnet3_id" {
  name = "/vpc/2/privatesubnet3/id"
}
data "aws_ssm_parameter" "vpc_cidr_1" {
  name = "/vpc/cidr"
}
data "aws_ssm_parameter" "vpc_cidr_2" {
  name = "/vpc/2/cidr"
}
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}
data "aws_caller_identity" "current" {}



# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key

module "kms_key" {
  source       = "app.terraform.io/pgetech/kms/aws"
  version      = "0.1.2"
  name         = var.kms_name
  description  = var.kms_description
  multi_region = true
  tags         = var.tags
  aws_role     = var.aws_role
  kms_role     = var.kms_role
}

# uncomment the following lines to create the replica kms key and must be used in conjunction with kms module
# This resource creates a multi region replica in a different region, to be used for automated backups replication
resource "aws_kms_replica_key" "replica" {
  description             = "Multi-Region replica key"
  deletion_window_in_days = 30
  primary_key_arn         = module.kms_key.key_arn
  tags                    = var.tags
  provider                = aws.replica
}

module "rds_automated_backups_replication" {
  source                 = "../../modules/rds_automated_backups_replication"
  source_db_instance_arn = local.create == 1 ? module.oracle_rds[0].db_instance_arn : null
  # Before executing this module, ensure the KMS key is created to pass it to this module
  kms_key_arn = aws_kms_replica_key.replica.arn # mandatory, per SAF compliance var.storage_encrypted is always set to true
  providers = {
    aws = aws.replica
  }
}

resource "aws_security_group_rule" "ingress" {

  count             = length(local.ingress)
  type              = "ingress"
  from_port         = local.ingress[count.index].port
  to_port           = local.ingress[count.index].port
  protocol          = local.ingress[count.index].protocol
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value, local.managed_ad_cidr]
  security_group_id = one(module.oracle_rds[*].security_group_id)
}

resource "aws_security_group_rule" "egress" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value, local.managed_ad_cidr]
  security_group_id = one(module.oracle_rds[*].security_group_id)
}

# Use the output of the `master_user_secret` object, which includes `secret_arn`,
# to manage the rotation rules.
resource "aws_secretsmanager_secret_rotation" "this" {
  count     = var.manage_master_user_password ? 1 : 0
  secret_id = one(module.oracle_rds[*].oracle_all[0].aws_db_instance_this_all[0].master_user_secret[0].secret_arn)

  rotation_rules {
    automatically_after_days = 30
  }
}

module "oracle_rds" {
  count = local.create

  source     = "../../modules/oracle"
  aws_region = var.aws_region

  # db_instance
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  # if the Dataclassification is not internal or Public, ensure the KMS key is created before running this module
  kms_key_id          = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  replicate_source_db = var.replicate_source_db
  license_model       = var.license_model
  source_dir          = "${path.module}/${var.source_dir}"

  engine                           = var.engine
  engine_version                   = var.engine_version
  skip_final_snapshot              = var.skip_final_snapshot
  snapshot_identifier              = var.snapshot_identifier
  final_snapshot_identifier        = var.final_snapshot_identifier
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix
  instance_class                   = var.instance_class

  db_name                       = var.db_name
  username                      = var.username
  password                      = var.password
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  identifier                    = var.identifier
  port                          = var.port
  availability_zone             = var.availability_zone
  multi_az                      = var.multi_az
  nchar_character_set_name      = var.nchar_character_set_name
  replica_mode                  = var.replica_mode
  iops                          = var.iops

  #monitoring role arn is automatically deployed to all PG&E accounts
  monitoring_role_arn                   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rds-enhanced-monitoring-role"
  monitoring_interval                   = var.monitoring_interval
  apply_immediately                     = var.apply_immediately
  maintenance_window                    = var.maintenance_window
  timeouts                              = var.timeouts
  backup_retention_period               = var.backup_retention_period
  backup_window                         = var.backup_window
  restore_to_point_in_time              = var.restore_to_point_in_time
  character_set_name                    = var.character_set_name
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  deletion_protection                   = var.deletion_protection
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  max_allocated_storage                 = var.max_allocated_storage
  ca_cert_identifier                    = var.ca_cert_identifier
  delete_automated_backups              = var.delete_automated_backups
  s3_import                             = var.s3_import
  s3_bucket_arn                         = var.s3_bucket_arn
  domain                                = local.ad_domain_id
  domain_iam_role_name                  = local.ad_iam_role_name
  storage_encrypted                     = var.storage_encrypted

  # tag variables
  tags                    = var.tags
  db_instance_tags        = var.db_instance_tags
  db_option_group_tags    = var.db_option_group_tags
  db_parameter_group_tags = var.db_parameter_group_tags
  db_subnet_group_tags    = var.db_subnet_group_tags

  # db_subnet_group
  subnet_ids = [
    data.aws_ssm_parameter.private_subnet3_id.value,
    data.aws_ssm_parameter.private_subnet2_id.value,
    data.aws_ssm_parameter.private_subnet1_id.value
  ]


  # db_parameter_group
  family     = var.family
  parameters = var.parameters

  # db_option_group
  options               = var.options
  option_group_timeouts = var.option_group_timeouts

  # secrets manager
  random_password_length  = var.random_password_length
  recovery_window_in_days = var.recovery_window_in_days
  secretsmanager_tags     = var.secretsmanager_tags
  rotation_enabled        = var.rotation_enabled
  # security group
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  security_group_tags = var.security_group_tags

  # Cloudwatch metric alarms
  evaluation_period                         = var.evaluation_period
  statistic_period                          = var.statistic_period
  cpu_utilization_too_high_threshold        = var.cpu_utilization_too_high_threshold
  actions_alarm                             = var.actions_alarm
  actions_ok                                = var.actions_ok
  cpu_credit_balance_too_low_threshold      = var.cpu_credit_balance_too_low_threshold
  disk_queue_depth_too_high_threshold       = var.disk_queue_depth_too_high_threshold
  disk_free_storage_space_too_low_threshold = var.disk_free_storage_space_too_low_threshold
  disk_burst_balance_too_low_threshold      = var.disk_burst_balance_too_low_threshold
  memory_freeable_too_low_threshold         = var.memory_freeable_too_low_threshold
  memory_swap_usage_too_high_threshold      = var.memory_swap_usage_too_high_threshold



  # Below variables are not required to be passed in if you are using the managed master password is set to true

  # secrets manager rotation lambda
  lambda_function_name = local.lambda_function_name
  lambda_description   = var.lambda_description
  lambda_handler_name  = var.lambda_handler_name
  lambda_runtime       = var.lambda_runtime
  sm_rotation_policy   = templatefile("${path.module}/custom_policy_sm_rotation_lambda.json", { account_num = data.aws_caller_identity.current.account_id, aws_region = var.aws_region, sm_rotation_lambda_name = local.lambda_function_name })
  timeout              = var.timeout

  # Lambda Layer version s3 variables
  layer_version_compatible_runtimes      = var.layer_version_compatible_runtimes
  layer_version_layer_name               = var.layer_version_layer_name
  layer_version_permission_principal     = var.layer_version_permission_principal
  s3_bucket                              = var.s3_bucket
  s3_key                                 = var.s3_key
  layer_version_permission_statement_id  = var.layer_version_permission_statement_id
  layer_version_compatible_architectures = var.layer_version_compatible_architectures
  layer_version_permission_action        = var.layer_version_permission_action


}

