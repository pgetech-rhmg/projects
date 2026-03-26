/*
 * # RDS Oracle module
 * Terraform module which creates SAF2.0 Oracle RDS Database
*/
#
#  Filename    : modules/rds/modules/oracle/main.tf
#  Date        : 3/2/2022
#  Author      : PGE
#  Description : RDS Oracle Module creation main file.
#  Notes       : If the password you pass in does not satisfy the minimum length as per SAF compliance which is min 16 chars,
#                a validation is put in place to meet the requirement, if password is null then a random generator Password will be stored in secrets manager. 
#                If argument manage_master_user_password is set to "true", then user provided password will be disregarded,
#                and AWS creates random password and creates a secret manager and stores this password


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


  json_secret = {
    username             = var.username
    password             = local.master_password
    dbname               = var.db_name
    engine               = "oracle"
    port                 = var.port
    dbInstanceIdentifier = local.identifier
    host                 = module.db_instance.db_instance_host
  }


  saf_options = [{
    option_name                    = "SSL"
    db_security_group_memberships  = []
    vpc_security_group_memberships = [module.main_security_group.sg_id]
    port                           = 2484
    version                        = ""
    option_settings = [
      {
        name  = "SQLNET.SSL_VERSION"
        value = "1.2"
      },
      {
        name  = "SQLNET.CIPHER_SUITE"
        value = "SSL_RSA_WITH_AES_256_CBC_SHA"
      },
      {
        name  = "FIPS.SSLFIPS_140"
        value = "FALSE"
      }
    ]
  }]
  options = concat(local.saf_options, var.options)

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
  db_option_group_tags     = merge(var.tags, var.db_option_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_instance_tags         = merge(var.tags, var.db_instance_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  main_security_group_tags = merge(var.tags, var.security_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  secretsmanager_tags      = merge(var.tags, var.secretsmanager_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_parameter_group_tags  = merge(var.tags, var.db_parameter_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  db_subnet_group_tags     = merge(var.tags, var.db_subnet_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

# Random string to use as master password
# Random string should exlude the characters: $@/|\"\'\\
resource "random_password" "master_password" {
  count = (var.manage_master_user_password == false && var.password == null) ? 1 : 0

  length           = var.random_password_length
  special          = false
  override_special = "!#%&*()-_=+[]{}<>:?"

}

module "db_subnet_group" {
  source = "../internal/db_subnet_group"

  name        = local.identifier
  description = "Subnet Group for RDS - ${local.identifier}"
  subnet_ids  = var.subnet_ids

  tags = local.db_subnet_group_tags

}

module "db_parameter_group" {
  source = "../internal/db_parameter_group"

  name        = local.identifier
  description = "Parameter group for DB instance ${local.identifier}"
  family      = var.family
  parameters  = var.parameters

  tags = local.db_parameter_group_tags

}

module "db_option_group" {
  source = "../internal/db_option_group"

  name                 = local.identifier
  engine_name          = var.engine
  major_engine_version = var.engine_version

  options  = local.options
  timeouts = var.option_group_timeouts

  tags = local.db_option_group_tags
}

resource "aws_db_instance_role_association" "s3_integration" {

  db_instance_identifier = module.db_instance.db_instance_identifier
  feature_name           = "S3_INTEGRATION"
  role_arn               = module.aws_iam_role.arn
}



module "db_instance" {
  source = "../internal/db_instance"

  identifier        = local.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  kms_key_id    = var.kms_key_id
  license_model = var.license_model

  db_name  = var.db_name
  username = var.username

  password                      = var.manage_master_user_password ? null : local.master_password
  port                          = var.port
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  domain                        = var.domain
  domain_iam_role_name          = var.domain_iam_role_name

  vpc_security_group_ids = [module.main_security_group.sg_id]
  db_subnet_group_name   = module.db_subnet_group.db_subnet_group_id
  parameter_group_name   = module.db_parameter_group.db_parameter_group_id
  option_group_name      = module.db_option_group.db_option_group_id

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
  storage_encrypted           = var.storage_encrypted
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

  nchar_character_set_name = var.nchar_character_set_name
  character_set_name       = var.character_set_name

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  timeouts = var.timeouts

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups
  replica_mode             = var.replica_mode

  restore_to_point_in_time = var.restore_to_point_in_time
  s3_import                = var.s3_import

  tags = local.db_instance_tags


}



module "aws_iam_role" {

  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  aws_service   = [local.aws_service]
  name          = local.s3_integration_role_name
  inline_policy = [templatefile("${path.module}/s3-integration-policy.json", { s3_bucket_arn = var.s3_bucket_arn })]
  tags          = local.module_tags
}


module "secrets_manager" {

  source  = "app.terraform.io/pgetech/secretsmanager/aws"
  version = "0.1.3"
  count   = !var.manage_master_user_password ? 1 : 0

  secretsmanager_name        = var.secretsmanager_name
  secretsmanager_description = "secrets manager for ${local.identifier} master password"
  kms_key_id                 = var.kms_key_id
  recovery_window_in_days    = var.recovery_window_in_days #this is set to 0 days for testing terraform destroy. It is recommended to use 7 days or higher based on business requirement.
  secret_string              = jsonencode(local.json_secret)
  secret_version_enabled     = var.secret_version_enabled
  rotation_enabled           = var.rotation_enabled
  rotation_lambda_arn        = local.rotation_lambda_arn
  rotation_after_days        = var.rotation_after_days
  tags                       = local.secretsmanager_tags

}
locals {
  rotation_lambda_arn = var.manage_master_user_password ? null : module.rotation_lambda_function[0].lambda_arn
}


#########################################
# Create Standalone Security Group
#########################################

module "main_security_group" {

  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name                         = "RDS-Oracle-SG-${local.identifier}"
  description                  = "Security Group for ${local.identifier}"
  vpc_id                       = var.vpc_id
  cidr_ingress_rules           = var.cidr_ingress_rules
  cidr_egress_rules            = var.cidr_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  tags                         = local.main_security_group_tags

}


module "rotation_lambda_iam_role" {

  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"
  count   = !var.manage_master_user_password ? 1 : 0

  aws_service   = ["lambda.amazonaws.com"]
  name          = "${var.lambda_function_name}_iam_role"
  inline_policy = [var.sm_rotation_policy]
  tags          = local.module_tags
}

module "rotation_lambda_function" {

  source        = "app.terraform.io/pgetech/lambda/aws"
  version       = "0.1.3"
  count         = !var.manage_master_user_password ? 1 : 0
  function_name = var.lambda_function_name
  source_code = {
    source_dir = var.source_dir
  }
  role                          = module.rotation_lambda_iam_role[0].arn
  description                   = var.lambda_description
  runtime                       = var.lambda_runtime
  tags                          = local.module_tags
  vpc_config_security_group_ids = [module.main_security_group.sg_id]
  vpc_config_subnet_ids         = var.subnet_ids
  handler                       = var.lambda_handler_name
  timeout                       = var.timeout
  environment_variables = {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.aws_region}.amazonaws.com"
    }
    kms_key_arn = var.kms_key_id
  }

  layers = [module.lambda_layer[0].layer_version_arn]
  depends_on = [
    module.lambda_layer
  ]
}

# Using the lambda layer version s3 module because the local version only permits up to 50mb of zip file
module "lambda_layer" {
  source                                 = "app.terraform.io/pgetech/lambda/aws//modules/lambda_layer_version_s3"
  version                                = "0.1.3"
  count                                  = !var.manage_master_user_password ? 1 : 0
  layer_version_description              = "cx_Oracle import layer for RDS Oracle Secrets Manager Rotation"
  layer_version_compatible_runtimes      = var.layer_version_compatible_runtimes
  layer_version_layer_name               = var.layer_version_layer_name
  layer_version_permission_principal     = var.layer_version_permission_principal
  s3_bucket                              = var.s3_bucket
  s3_key                                 = var.s3_key
  layer_version_permission_statement_id  = var.layer_version_permission_statement_id
  layer_version_compatible_architectures = var.layer_version_compatible_architectures
  layer_version_permission_action        = var.layer_version_permission_action
}

resource "aws_lambda_permission" "allow_sm_invoke" {
  count         = !var.manage_master_user_password ? 1 : 0
  statement_id  = "AllowExecutionFromSecretsManager-${local.identifier}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = module.secrets_manager[0].arn
  depends_on = [
    module.rotation_lambda_function
  ]

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




