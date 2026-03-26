/*
 * # RDS proxy module
 * Terraform module which creates SAF2.0  RDS Proxy
*/
#
#  Filename    : modules/rds/modules/rds_proxy/main.tf
#  Date        : 3/21/2024
#  Author      : PGE
#  Description : RDS proxy Module creation main file.
# RDS proxy is only supports Aurora MYSQL, Aurora POSTGRESQL, MYSQL and POSTGRESQL


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
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.1"
    }
  }
}


locals {

  is_dc_public_or_internal = (var.tags["DataClassification"] == "Internal" || var.tags["DataClassification"] == "Public") ? true : false
  proxy_tags               = merge(var.tags, var.proxy_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  cloudwatch_tags          = merge(var.tags, var.log_group_tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

data "aws_region" "current" {}
data "aws_partition" "current" {}

data "external" "validate_kms" {
  count   = (!local.is_dc_public_or_internal && var.log_group_kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassfication type ; exit 1"]
}

### workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}



################################################################################
# RDS Proxy
################################################################################

resource "aws_db_proxy" "this" {
  count = var.create ? 1 : 0

  dynamic "auth" {
    for_each = var.auth

    content {
      auth_scheme               = try(auth.value.auth_scheme, "SECRETS")
      client_password_auth_type = try(auth.value.client_password_auth_type, null)
      description               = try(auth.value.description, null)
      iam_auth                  = try(auth.value.iam_auth, null)
      secret_arn                = try(auth.value.secret_arn, null)
      username                  = try(auth.value.username, null)
    }
  }

  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = var.idle_client_timeout
  name                   = var.name
  require_tls            = var.require_tls
  role_arn               = var.role_arn
  vpc_security_group_ids = var.vpc_security_group_ids

  vpc_subnet_ids = var.vpc_subnet_ids

  tags = local.proxy_tags

  depends_on = [module.cloudwatch_log-group]
}

resource "aws_db_proxy_default_target_group" "this" {
  count = var.create ? 1 : 0

  db_proxy_name = aws_db_proxy.this[0].name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    init_query                   = var.init_query
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    session_pinning_filters      = var.session_pinning_filters
  }
}

resource "aws_db_proxy_target" "db_instance" {
  count = var.create && var.target_db_instance ? 1 : 0

  db_proxy_name          = aws_db_proxy.this[0].name
  target_group_name      = aws_db_proxy_default_target_group.this[0].name
  db_instance_identifier = var.db_instance_identifier
}

resource "aws_db_proxy_target" "db_cluster" {
  count = var.create && var.target_db_cluster ? 1 : 0

  db_proxy_name         = aws_db_proxy.this[0].name
  target_group_name     = aws_db_proxy_default_target_group.this[0].name
  db_cluster_identifier = var.db_cluster_identifier
}

resource "aws_db_proxy_endpoint" "this" {
  for_each = { for k, v in var.endpoints : k => v if var.create }

  db_proxy_name          = aws_db_proxy.this[0].name
  db_proxy_endpoint_name = each.value.name
  vpc_subnet_ids         = each.value.vpc_subnet_ids
  vpc_security_group_ids = lookup(each.value, "vpc_security_group_ids", null)
  target_role            = lookup(each.value, "target_role", null)

  tags = lookup(each.value, "tags", var.tags)
}



module "cloudwatch_log-group" {
  source            = "app.terraform.io/pgetech/cloudwatch/aws//modules/log-group"
  version           = "0.1.3"
  count             = var.create && var.manage_log_group ? 1 : 0
  name              = "/aws/rds/proxy/${var.name}"
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = local.cloudwatch_tags
}

