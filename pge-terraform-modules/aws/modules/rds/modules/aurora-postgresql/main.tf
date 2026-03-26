#
#  Filename    : modules/rds/modules/aurora-postgresql/main.tf
#  Date        : 5/26/2022
#  Author      : PGE
#  Description : AWS Aurora-Postgresql module
#
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
  master_password = (var.manage_master_user_password == false && var.master_password == null) ? random_password.master_password[0].result : var.master_password
  identifier      = lower(var.identifier)



  saf_cluster_parameters = [
    {
      name  = "rds.force_ssl",
      value = 1
    }
  ]

  cluster_parameters = concat(local.saf_cluster_parameters, var.cluster_parameters)
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  db_cluster_tags                 = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_cluster_instance_tags        = merge(var.tags, var.db_cluster_instance_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  main_security_group_tags        = merge(var.tags, var.security_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_cluster_parameter_group_tags = merge(var.tags, var.db_cluster_parameter_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_parameter_group_tags         = merge(var.tags, var.db_parameter_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_subnet_group_tags            = merge(var.tags, var.db_subnet_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  ssm_parameter_tags              = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}


module "db_cluster" {
  source = "../../"

  cluster_identifier = local.identifier
  kms_key_id         = var.kms_key_id
  ## to use IAM when using serverless V1 vs Serverless V2 refer to the AWS docs
  ### https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.IAM.AddRoleToDBCluster.html
  ### Serverless V1 can't have IAM role DB authetication associated with it
  scaling_configuration              = var.scaling_configuration
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration
  storage_type                       = var.storage_type
  allocated_storage                  = var.allocated_storage
  iops                               = var.iops

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode

  database_name               = var.database_name
  availability_zones          = var.availability_zones
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  db_cluster_parameter_group_name  = module.db_cluster_parameter_group.db_cluster_parameter_group_name
  db_instance_parameter_group_name = module.db_parameter_group.db_parameter_group_id
  db_subnet_group_name             = module.db_subnet_group.db_subnet_group_id

  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = true
  deletion_protection             = var.deletion_protection
  enable_http_endpoint            = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  final_snapshot_identifier      = var.final_snapshot_identifier
  global_cluster_identifier      = var.global_cluster_identifier
  enable_global_write_forwarding = var.enable_global_write_forwarding

  iam_database_authentication_enabled = true
  master_password                     = var.manage_master_user_password ? null : local.master_password
  master_username                     = var.master_username
  manage_master_user_password         = var.manage_master_user_password
  master_user_secret_kms_key_id       = var.master_user_secret_kms_key_id

  preferred_backup_window                       = var.preferred_backup_window
  preferred_maintenance_window                  = var.preferred_maintenance_window
  cluster_performance_insights_enabled          = var.cluster_performance_insights_enabled
  cluster_performance_insights_kms_key_id       = var.cluster_performance_insights_kms_key_id
  cluster_performance_insights_retention_period = var.cluster_performance_insights_retention_period
  replication_source_identifier                 = var.replication_source_identifier
  vpc_security_group_ids                        = [module.main_security_group.sg_id]

  domain               = var.domain
  domain_iam_role_name = var.domain_iam_role_name

  skip_final_snapshot = var.skip_final_snapshot
  snapshot_identifier = var.snapshot_identifier
  source_region       = var.source_region
  tags                = local.db_cluster_tags


}
module "db_cluster_instance" {
  source = "../internal/db_cluster_instance"

  cluster_instance_count = var.cluster_instance_count
  custom_instance_names  = var.custom_instance_names

  identifier         = local.identifier
  cluster_identifier = module.db_cluster.db_cluster_id

  instance_timeouts                     = var.instance_timeouts
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = var.instance_class
  apply_immediately                     = var.apply_immediately
  db_subnet_group_name                  = module.db_subnet_group.db_subnet_group_id
  db_parameter_group_name               = module.db_parameter_group.db_parameter_group_id
  monitoring_role_arn                   = var.monitoring_role_arn
  monitoring_interval                   = var.monitoring_interval
  promotion_tier                        = var.promotion_tier
  availability_zone                     = var.availability_zone
  preferred_maintenance_window          = var.preferred_maintenance_window
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  copy_tags_to_snapshot = true
  ca_cert_identifier    = var.ca_cert_identifier

  actions_alarm                             = var.actions_alarm
  actions_ok                                = var.actions_ok
  evaluation_period                         = var.evaluation_period
  anomaly_band_width                        = var.anomaly_band_width
  anomaly_period                            = var.anomaly_period
  create_anomaly_alarm                      = var.create_anomaly_alarm
  statistic_period                          = var.statistic_period
  cpu_credit_balance_too_low_threshold      = var.cpu_credit_balance_too_low_threshold
  cpu_utilization_too_high_threshold        = var.cpu_utilization_too_high_threshold
  disk_queue_depth_too_high_threshold       = var.disk_queue_depth_too_high_threshold
  disk_free_storage_space_too_low_threshold = var.disk_free_storage_space_too_low_threshold
  disk_burst_balance_too_low_threshold      = var.disk_burst_balance_too_low_threshold
  memory_freeable_too_low_threshold         = var.memory_freeable_too_low_threshold
  memory_swap_usage_too_high_threshold      = var.memory_swap_usage_too_high_threshold


  tags = local.db_cluster_instance_tags

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

module "db_cluster_parameter_group" {
  source = "../internal/db_cluster_parameter_group"

  name        = local.identifier
  description = "Cluster parameter group for DB instance ${local.identifier}"
  family      = var.family
  parameters  = local.cluster_parameters

  tags = local.db_cluster_parameter_group_tags

}

module "db_parameter_group" {
  source = "../internal/db_parameter_group"

  name        = local.identifier
  description = "Parameter group for DB instance ${local.identifier}"
  family      = var.family
  parameters  = var.parameters

  tags = local.db_parameter_group_tags

}

module "db_subnet_group" {
  source = "../internal/db_subnet_group"

  name        = local.identifier
  description = "Subnet Group for RDS - ${local.identifier}"
  subnet_ids  = var.subnet_ids

  tags = local.db_subnet_group_tags

}

# Random string to use as master password
# Random string should exclude the characters: $@/|\"\'\\
resource "random_password" "master_password" {
  count            = (var.manage_master_user_password == false && var.master_password == null) ? 1 : 0
  length           = var.random_password_length
  special          = false
  override_special = "!#%&*()-_=+[]{}<>:?"

}

module "ssm_parameter" {
  source      = "app.terraform.io/pgetech/ssm/aws"
  version     = "0.1.2"
  count       = var.create_ssm_parameter && !var.manage_master_user_password ? 1 : 0
  name        = "/rds/${module.db_cluster.db_cluster_cluster_identifier}/${var.master_username}"
  description = var.ssm_description
  value       = local.master_password
  key_id      = var.key_id
  tags        = local.ssm_parameter_tags
}

