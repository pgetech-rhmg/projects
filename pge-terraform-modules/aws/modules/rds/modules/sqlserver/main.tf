#
#  Filename    : modules/rds/modules/sqlserver/main.tf
#  Date        : 5/26/2022
#  Author      : PGE
#  Description : AWS SQL Server module
#  Notes       : If the master password you pass in does not satisfy the minimum length as per SAF compliance,
#                the module will generate one for you.  Master Password will be stored
#                in Parameter Store in the format of /rds/<db_identifier>/<username>
terraform {
  required_version = ">= 1.1.0"

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
  master_password = (var.manage_master_user_password == false && var.password == null) ? random_password.master_password[0].result : var.password
  #identifier that will be used for all resources. Appends random string onto the end of the identifier passed in by user.
  identifier = "${lower(var.identifier)}-${random_string.name.result}"

  default_parameters = [
    {
      name  = "rds.sqlserver_audit",
      value = "fedramp_hipaa"
    }
  ]
  parameters = concat(local.default_parameters, var.parameters)

  aws_service              = "rds.amazonaws.com"
  s3_integration_role_name = "${local.identifier}-s3-integration-role"

}
#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags              = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_instance_tags         = merge(var.tags, var.db_instance_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  main_security_group_tags = merge(var.tags, var.security_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_parameter_group_tags  = merge(var.tags, var.db_parameter_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_subnet_group_tags     = merge(var.tags, var.db_subnet_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_option_group_tags     = merge(var.tags, var.db_option_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

resource "aws_db_instance_role_association" "s3_integration" {

  count = var.create_iam_role_association ? 1 : 0

  db_instance_identifier = module.db_instance.db_instance_identifier
  feature_name           = "S3_INTEGRATION"
  role_arn               = module.aws_iam_role[0].arn
}

module "aws_iam_role" {

  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  count = var.create_iam_role_association ? 1 : 0

  aws_service   = [local.aws_service]
  name          = local.s3_integration_role_name
  inline_policy = [templatefile("${path.module}/s3-integration-policy.json", { s3_bucket_arn = var.s3_bucket_arn })]
  tags          = local.module_tags
}

module "db_instance" {
  source = "../internal/db_instance"

  identifier = local.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  kms_key_id    = var.kms_key_id
  license_model = var.license_model

  username                      = var.username
  password                      = var.manage_master_user_password ? null : local.master_password
  port                          = var.port
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  db_name                       = var.db_name
  vpc_security_group_ids        = [module.main_security_group.sg_id]
  db_subnet_group_name          = module.db_subnet_group.db_subnet_group_id
  parameter_group_name          = module.db_parameter_group.db_parameter_group_id
  option_group_name             = module.db_option_group.db_option_group_id

  domain               = var.domain
  domain_iam_role_name = var.domain_iam_role_name

  availability_zone   = var.availability_zone
  multi_az            = var.multi_az
  iops                = var.iops
  storage_throughput  = var.storage_throughput
  publicly_accessible = false
  ca_cert_identifier  = var.ca_cert_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  snapshot_identifier         = var.snapshot_identifier
  backup_retention_period     = var.backup_retention_period

  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier        = var.final_snapshot_identifier
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  replicate_source_db = var.replicate_source_db

  backup_window         = var.backup_window
  max_allocated_storage = var.max_allocated_storage
  monitoring_interval   = var.monitoring_interval
  monitoring_role_arn   = var.monitoring_role_arn

  character_set_name              = var.character_set_name
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  timeouts                        = var.timeouts
  deletion_protection             = var.deletion_protection
  delete_automated_backups        = var.delete_automated_backups

  restore_to_point_in_time = var.restore_to_point_in_time
  timezone                 = var.timezone

  tags = local.db_instance_tags

}


module "main_security_group" {

  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name                         = "security-group-${local.identifier}"
  description                  = "Security Group for ${local.identifier}"
  vpc_id                       = var.vpc_id
  cidr_ingress_rules           = var.cidr_ingress_rules
  cidr_egress_rules            = var.cidr_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  tags                         = local.main_security_group_tags

}


module "db_parameter_group" {
  source = "../internal/db_parameter_group"

  name        = local.identifier
  description = "Parameter group for DB instance ${local.identifier}"
  family      = var.family
  parameters  = local.parameters

  tags = local.db_parameter_group_tags

}

module "db_subnet_group" {
  source = "../internal/db_subnet_group"

  name        = local.identifier
  description = "Subnet Group for RDS - ${local.identifier}"
  subnet_ids  = var.subnet_ids

  tags = local.db_subnet_group_tags

}

module "db_option_group" {
  source = "../internal/db_option_group"

  name                 = local.identifier
  engine_name          = var.engine
  major_engine_version = var.engine_version

  options  = var.options
  timeouts = var.option_group_timeouts

  tags = local.db_option_group_tags
}

#Cloudwatch Metric Alarms Module
module "db_cloudwatch_metric_alarms" {
  source = "../internal/db_cloudwatch_metric_alarms"

  tags = local.module_tags

  actions_alarm                             = var.actions_alarm
  actions_ok                                = var.actions_ok
  db_instance_id                            = module.db_instance.db_instance_id
  evaluation_period                         = var.evaluation_period
  anomaly_band_width                        = var.anomaly_band_width
  anomaly_period                            = var.anomaly_period
  statistic_period                          = var.statistic_period
  db_instance_class                         = var.instance_class
  cpu_credit_balance_too_low_threshold      = var.cpu_credit_balance_too_low_threshold
  cpu_utilization_too_high_threshold        = var.cpu_utilization_too_high_threshold
  disk_queue_depth_too_high_threshold       = var.disk_queue_depth_too_high_threshold
  disk_free_storage_space_too_low_threshold = var.disk_free_storage_space_too_low_threshold
  disk_burst_balance_too_low_threshold      = var.disk_burst_balance_too_low_threshold
  memory_freeable_too_low_threshold         = var.memory_freeable_too_low_threshold
  memory_swap_usage_too_high_threshold      = var.memory_swap_usage_too_high_threshold
  # create_low_disk_burst_alarm 
  create_low_disk_burst_alarm = var.create_low_disk_burst_alarm
}
# Random string to use as master password
# Random string should exlude the characters: $@/|\"\'\\
resource "random_password" "master_password" {
  count = (var.manage_master_user_password == false && var.password == null) ? 1 : 0

  length           = var.random_password_length
  special          = false
  override_special = "!#%&*()-_=+[]{}<>:?"

}

module "ssm_parameter" {
  source      = "app.terraform.io/pgetech/ssm/aws"
  version     = "0.1.2"
  count       = var.create_ssm_parameter && !var.manage_master_user_password ? 1 : 0
  name        = "/rds/${local.identifier}/${var.username}"
  description = "RDS instance master password when not using managed master user password setting in the module"
  value       = local.master_password
  key_id      = var.key_id
  tags        = local.module_tags
}

