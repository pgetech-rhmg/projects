/*
AWS Redshift Serverless module
Terraform module which creates Redshift Serverless resources
Filename     : aws/modules/redshift-serverless/main.tf 
Date         : 05 Feb 2026
Author       : PGE
Description  : Terraform module for creation of Redshift Serverless Namespace and Workgroup
*/
terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">=2.3.1"
    }
  }
}

locals {
  namespace = "ccoe-tf-developers"
}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}

# Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "this" {
  namespace_name = var.namespace_name

  admin_username       = var.admin_username
  admin_user_password  = var.manage_admin_password == false ? var.admin_user_password : null
  db_name              = var.db_name
  default_iam_role_arn = var.default_iam_role_arn
  iam_roles            = var.iam_role_arns
  kms_key_id           = var.kms_key_id
  log_exports          = var.log_exports

  tags = local.module_tags
}

# Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "this" {
  namespace_name = aws_redshiftserverless_namespace.this.namespace_name
  workgroup_name = var.workgroup_name

  base_capacity            = var.base_capacity
  max_capacity             = var.max_capacity
  publicly_accessible      = var.publicly_accessible
  subnet_ids               = var.subnet_ids
  security_group_ids       = var.security_group_ids
  enhanced_vpc_routing     = var.enhanced_vpc_routing
  port                     = var.port

  dynamic "config_parameter" {
    for_each = var.config_parameters
    content {
      parameter_key   = config_parameter.value.parameter_key
      parameter_value = config_parameter.value.parameter_value
    }
  }

  tags = local.module_tags
}
