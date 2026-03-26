/*
 * # RDS Aurora Postgresql rds proxy module
 * Terraform module which creates an RDS Aurora Postgresql Database and RDS proxy
 * Pre-Requisites:
 *    1. IAM Role rds-enhanced-monitoring-role exists within your account (should be automatically deployed to PG&E accounts)
 *    2. RDS VPC Endpoint exists for the account.  If not, you can deploy one in the account as shown with the rds_vpc_endpoint example module (rds/examples/rds_vpc_endpoint)
 * Notes:
 *   1. This module will also create various SSM Parameters to store data pertaining to the DB Cluster and it's instances.
 *   2. This module includes logic to pass in private subnets and vpc(/vpc/2/privatesubnet1/id, /vpc/2/privatesubnet2/id,
 *      /vpc/2/privatesubnet3/id, /vpc/id).  Be sure that the account in which you are using has adequate IP space for the subnets stored in Parameter Store.
 *   3. Serverless v1 clusters do not support managed master user password, Aurora Serverless v2 is supported for MySQL 8.0 onwards & PostgreSQL 13 onwards.
 *   4. if the DataClassification is not internal or public, passing null KMS will result in error, hence create the KMS key using the module in the code, its a 2 step process
        a. first comment all the code except for kms module, run terraform apply, this create the KMS key and stores in state file.
        b. uncomment remaining code, replace null for kms for all the arguments with the module created value.
*/
#
#  Filename    : modules/rds/examples/rds_aurora_postgresql_cluster_proxy/main.tf
#  Date        : 3/21/2024
#  Author      : PGE
#  Description : Example of AWS Aurora Postgresql cluster proxy module
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
    { port : 5432, protocol : "tcp" }
  ]

}

locals {
  aws_role   = var.aws_role
  kms_role   = var.kms_role
  name       = "db-proxy-postgresql"
  identifier = "${lower(local.name)}-${random_string.name.result}"
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

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
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
  security_group_id = module.aurora-postgresql.security_group_id
}

resource "aws_security_group_rule" "egress" {

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
  security_group_id = module.aurora-postgresql.security_group_id
}



module "aurora-postgresql" {
  source     = "../../modules/aurora-postgresql"
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

  # availability_zones          = var.availability_zones
  availability_zones          = local.selected_availability_zones
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  deletion_protection             = var.deletion_protection
  enable_http_endpoint            = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot       = var.skip_final_snapshot

  # db_cluster_instance
  monitoring_role_arn                   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/rds-enhanced-monitoring-role"
  db_cluster_instance_tags              = var.db_cluster_instance_tags
  cluster_instance_count                = var.cluster_instance_count
  instance_class                        = var.instance_class
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

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

################################################################################
# RDS Proxy
################################################################################

module "rds_proxy" {
  source = "../../modules/rds_proxy"
  create = var.create
  name   = local.name

  vpc_subnet_ids         = [data.aws_ssm_parameter.private_subnet3_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet1_id.value]
  vpc_security_group_ids = [module.main_security_group.sg_id]

  endpoints = {
    read_write = {
      name                   = "read-write-endpoint"
      vpc_subnet_ids         = [data.aws_ssm_parameter.private_subnet3_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet1_id.value]
      vpc_security_group_ids = [module.main_security_group.sg_id]
      tags                   = var.tags
    },
    read_only = {
      name                   = "read-only-endpoint"
      vpc_subnet_ids         = [data.aws_ssm_parameter.private_subnet3_id.value, data.aws_ssm_parameter.private_subnet2_id.value, data.aws_ssm_parameter.private_subnet1_id.value]
      vpc_security_group_ids = [module.main_security_group.sg_id]
      target_role            = "READ_ONLY"
      tags                   = var.tags
    }
  }

  auth = {
    "root" = {
      description = "Cluster generated master user password"

      secret_arn = var.manage_master_user_password ? module.aurora-postgresql.cluster_master_user_secret[0].secret_arn : var.secretsmanager_arn
    }
  }

  role_arn      = module.aws_iam_role[0].arn
  engine_family = "POSTGRESQL"
  debug_logging = true

  # Target Aurora cluster
  target_db_cluster     = true
  db_cluster_identifier = module.aurora-postgresql.db_cluster_id

  tags = var.tags
}

## iam policy to be used with iam role
data "aws_iam_policy_document" "this" {
  count = var.create && var.create_iam_role ? 1 : 0

  statement {
    sid    = "ListSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetRandomPassword",
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "GetSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = ["*"]
  }
}

module "aws_iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.1"
  count       = var.create && var.create_iam_role ? 1 : 0
  name        = "iam-${local.identifier}"
  aws_service = var.aws_service
  #Customer Managed Policy
  inline_policy = [data.aws_iam_policy_document.this[0].json]
  tags          = var.tags
}

## Security group for RDS proxy
module "main_security_group" {

  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.2"

  name        = "security-group-${local.identifier}"
  description = "Security Group for ${local.identifier}"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 5432,
    to               = 5432,
    protocol         = "TCP",
    cidr_blocks      = [data.aws_ssm_parameter.vpc_cidr_1.value, data.aws_ssm_parameter.vpc_cidr_2.value]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS proxy Ingress rule"
    }
  ]
  cidr_egress_rules = [{
    from             = 0,
    to               = 0,
    protocol         = "-1",
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "RDS proxy egress rule"
    }
  ]

  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  tags                         = var.tags

}

#SSM Params to store
resource "aws_ssm_parameter" "replica" {
  name        = "/rds/endpoint/replica/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster readonly endpoint"
  tags        = var.tags
  value       = module.aurora-postgresql.db_cluster_reader_endpoint
}

resource "aws_ssm_parameter" "primary" {
  name        = "/rds/endpoint/primary/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster endpoint"
  tags        = var.tags
  value       = module.aurora-postgresql.db_cluster_endpoint
}

resource "aws_ssm_parameter" "cluster_arn" {
  name        = "/rds/arn/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster ARN"
  tags        = var.tags
  value       = module.aurora-postgresql.db_cluster_arn
}

resource "aws_ssm_parameter" "cluster_subnet_group" {
  name        = "/rds/subnetgroup/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB subnet group"
  tags        = var.tags
  value       = module.aurora-postgresql.db_subnet_group_id
}

resource "aws_ssm_parameter" "cluster_security_group" {
  name        = "/rds/securitygroup/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB security group"
  tags        = var.tags
  value       = module.aurora-postgresql.security_group_id
}

resource "aws_ssm_parameter" "cluster_param_group" {
  name        = "/rds/parametergroup/cluster/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "DB cluster parameter group"
  tags        = var.tags
  value       = module.aurora-postgresql.db_cluster_parameter_group_id
}

resource "aws_ssm_parameter" "instance_param_group" {
  name        = "/rds/parametergroup/instance/${module.aurora-postgresql.db_cluster_cluster_identifier}"
  type        = "String"
  description = "RDS instance parameter group"
  tags        = var.tags
  value       = module.aurora-postgresql.db_parameter_group_id
}

