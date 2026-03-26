/*
 * # RDS Aurora mysql module
 * Terraform module which creates an RDS Aurora mysql Database.
 * Pre-Requisites:
 *    1. IAM Role rds-enhanced-monitoring-role exists within your account (should be automatically deployed to PG&E accounts)
 *    2. RDS VPC Endpoint exists for the account.  If not, you can deploy one in the account as shown with the rds_vpc_endpoint example module (rds/examples/rds_vpc_endpoint)
 * Notes:
 *   1. At this time, this module is not fully SAF 2.0 Compliant.  Compliance will be implemented at a later date.
 *   2. This module will also create various SSM Parameters to store data pertaining to the DB Cluster and it's instances.
 *   3. This module includes logic to pass in private subnets and vpc(/vpc/privatesubnet1/id, /vpc/privatesubnet2/id,
 *      /vpc/privatesubnet3/id, /vpc/id).  Be sure that the account in which you are using has adequate IP space for the subnets stored in Parameter Store.
 *   4. Serverless v1 clusters do not support managed master user password, Aurora Serverless v2 is supported for MySQL 8.0 onwards & PostgreSQL 13 onwards.
 *   5. if the DataClassification is not internal or public, passing null KMS will result in error, hence create the KMS key using the module in the code, its a 2 step process
        a. first comment all the code except for kms module, run terraform apply, this create the KMS key and stores in state file.
        b. uncomment remaining code, replace null for kms for all the arguments with the module created value.
        
*/
#
#  Filename    : modules/rds/examples/rds_aurora_mysql/main.tf
#  Date        : 7/01/2022
#  Author      : PGE 
#  Description : Example of AWS Aurora mysql module
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
  #ports and protocol
  ingress = [
    { port : 3306, protocol : "tcp" }
  ]

}

locals {
  aws_role = var.aws_role
  kms_role = var.kms_role
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

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  selected_availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
# module "kms_key" {
#   source      = "app.terraform.io/pgetech/kms/aws"
#   version     = "0.1.2"
#   name        = var.kms_name
#   description = var.kms_description
#   tags        = var.tags
#   aws_role    = local.aws_role
#   kms_role    = local.kms_role
# }


resource "aws_security_group_rule" "ingress" {

  count             = length(local.ingress)
  type              = "ingress"
  from_port         = local.ingress[count.index].port
  to_port           = local.ingress[count.index].port
  protocol          = local.ingress[count.index].protocol
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
  security_group_id = module.aurora-mysql.security_group_id
}

resource "aws_security_group_rule" "egress" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
  security_group_id = module.aurora-mysql.security_group_id
}

# Use the output of the `master_user_secret` object, which includes `secret_arn`,
# to manage the rotation rules.
resource "aws_secretsmanager_secret_rotation" "this" {
  count     = var.manage_master_user_password ? 1 : 0
  secret_id = one(module.aurora-mysql[*].aurora-mysql-all[0].aws_rds_cluster_all.master_user_secret[0].secret_arn)

  rotation_rules {
    automatically_after_days = 30
  }
}


module "aurora-mysql" {
  source     = "../../modules/aurora-mysql"
  identifier = var.identifier

  # db cluster
  kms_key_id = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public

  engine_version = var.engine_version
  engine_mode    = var.engine_mode

  database_name = var.database_name

  master_username               = var.master_username
  master_password               = var.master_password
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  preferred_backup_window       = var.preferred_backup_window
  preferred_maintenance_window  = var.preferred_maintenance_window

  availability_zones          = local.selected_availability_zones
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  deletion_protection             = var.deletion_protection
  enable_http_endpoint            = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot       = var.skip_final_snapshot

  # db_cluster_instance
  monitoring_role_arn                           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rds-enhanced-monitoring-role"
  db_cluster_instance_tags                      = var.db_cluster_instance_tags
  cluster_instance_count                        = var.cluster_instance_count
  instance_class                                = var.instance_class
  performance_insights_enabled                  = var.performance_insights_enabled
  performance_insights_kms_key_id               = var.performance_insights_kms_key_id
  performance_insights_retention_period         = var.performance_insights_retention_period
  cluster_performance_insights_enabled          = var.cluster_performance_insights_enabled
  cluster_performance_insights_kms_key_id       = var.cluster_performance_insights_kms_key_id
  cluster_performance_insights_retention_period = var.cluster_performance_insights_retention_period

  # security group
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  security_group_tags = var.security_group_tags

  # db_cluster_parameter_group
  cluster_parameters              = var.cluster_parameters
  db_cluster_parameter_group_tags = var.db_cluster_parameter_group_tags

  # db_parameter_group
  family                  = var.family
  parameters              = var.parameters
  db_parameter_group_tags = var.db_parameter_group_tags

  # db_subnet_group
  subnet_ids           = [data.aws_ssm_parameter.private_subnet3_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet1_id.value]
  db_subnet_group_tags = var.db_subnet_group_tags

  tags = var.tags

  #ssm_parameter
  key_id          = null # replace with module.kms_key.key_arn, after key creation if the DataClassificaiton is neither internal nor public
  ssm_description = var.ssm_description

  # cloudwatch metrics
  cpu_credit_balance_too_low_threshold = var.cpu_credit_balance_too_low_threshold
}

#SSM Params to store
resource "aws_ssm_parameter" "replica" {
  name        = "/rds/endpoint/replica/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster readonly endpoint"
  tags        = var.tags
  value       = module.aurora-mysql.db_cluster_reader_endpoint
}

resource "aws_ssm_parameter" "primary" {
  name        = "/rds/endpoint/primary/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster endpoint"
  tags        = var.tags
  value       = module.aurora-mysql.db_cluster_endpoint
}

resource "aws_ssm_parameter" "cluster_arn" {
  name        = "/rds/arn/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster ARN"
  tags        = var.tags
  value       = module.aurora-mysql.db_cluster_arn
}

resource "aws_ssm_parameter" "cluster_subnet_group" {
  name        = "/rds/subnetgroup/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB subnet group"
  tags        = var.tags
  value       = module.aurora-mysql.db_subnet_group_id
}

resource "aws_ssm_parameter" "cluster_security_group" {
  name        = "/rds/securitygroup/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB security group"
  value       = module.aurora-mysql.security_group_id
}

resource "aws_ssm_parameter" "cluster_param_group" {
  name        = "/rds/parametergroup/cluster/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster parameter group"
  tags        = var.tags
  value       = module.aurora-mysql.db_cluster_parameter_group_id
}

resource "aws_ssm_parameter" "instance_param_group" {
  name        = "/rds/parametergroup/instance/${module.aurora-mysql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "RDS instance parameter group"
  tags        = var.tags
  value       = module.aurora-mysql.db_parameter_group_id
}
