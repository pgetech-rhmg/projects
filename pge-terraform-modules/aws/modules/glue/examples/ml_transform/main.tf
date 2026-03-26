/*
* # AWS GLUE with usage example
* Terraform module which creates SAF2.0 Glue ML Transform resources in AWS.
*/
#
# Filename    : modules/glue/examples/ml_transform/main.tf
# Date        : 30 August 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue ml transform.

locals {
  name = "${var.name}-${random_string.name.result}"
  Order         = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 5
  special = false
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = local.Order
}

module "glue_ml_transform" {
  source = "../../../glue/modules/ml-transform"

  ml_transform_name          = local.name
  glue_database_name         = var.glue_database_name
  table_name                 = var.table_name
  transform_type             = var.transform_type
  accuracy_cost_trade_off    = var.accuracy_cost_trade_off
  precision_recall_trade_off = var.precision_recall_trade_off
  primary_key_column_name    = var.primary_key_column_name
  role_arn                   = module.ml_transform_iam_role.arn
  glue_version               = var.glue_version
  max_retries                = var.max_retries

  ml_transform = {
    worker_type       = var.worker_type
    number_of_workers = var.number_of_workers
    max_capacity      = var.max_capacity
  }

  tags = merge(module.tags.tags, var.optional_tags)

  depends_on = [
    module.ml_transform_iam_role,
    resource.aws_lakeformation_permissions.iam_ml
  ]
}

# IAM Role for Glue ml transform

module "ml_transform_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = local.name
  aws_service = var.role_service
  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
  tags        = merge(module.tags.tags, var.optional_tags)
}

resource "aws_lakeformation_permissions" "iam_ml" {
  permissions = var.permissions
  principal   = module.ml_transform_iam_role.arn
  database {
    name       = var.database_name
    catalog_id = var.database_catalog_id
  }
}