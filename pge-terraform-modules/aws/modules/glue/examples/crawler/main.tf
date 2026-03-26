/*
 * # AWS Glue Crawler module Crawler example
*/
#
# Filename    : aws/modules/glue/examples/crawler/main.tf
# Date        : 10 August 2022
# Author      : TCS
# Description : The Terraform usage example creates aws glue crawler.
#

locals {
  optional_tags = var.optional_tags
  name          = "${var.name}-${random_string.name.result}"
  Order         = var.Order
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

#########################################
# Create Glue Crawler
#########################################
module "glue_security_configuration" {
  source = "../../../glue/modules/security-configuration/"

  glue_security_configuration_name          = local.name
  glue_cloudwatch_encryption_kms_key_arn    = module.kms_key.key_arn # kmsKeyArn can not be empty for cloudWatchEncryptionMode SSE_KMS
  glue_job_bookmarks_encryption_kms_key_arn = module.kms_key.key_arn # kmsKeyArn can only be empty for jobBookmarksEncryptionMode CSE_KMS
  glue_s3_encryption_kms_key_arn            = module.kms_key.key_arn # kmsKeyArn can not be empty for s3EncryptionMode SSE_KMS

}

# KMS Key

module "kms_key" {
  source  = "app.terraform.io/pgetech/kms/aws"
  version = "0.1.0"

  name     = local.name
  aws_role = var.aws_role
  kms_role = var.kms_role
  tags     = merge(module.tags.tags, local.optional_tags)
}
module "crawler_s3" {
  source = "../../modules/crawler"

  glue_crawler_name          = "${local.name}-s3"
  glue_crawler_database_name = var.glue_crawler_database_name
  glue_crawler_role          = module.iam_crawler_role.arn
  glue_crawler_table_prefix  = var.glue_crawler_table_prefix_s3
  glue_crawler_schedule      = var.glue_crawler_schedule

  # SAF rule no 1 SecurityConfiguration
  glue_crawler_security_configuration = module.glue_security_configuration.glue_security_configuration_id
  glue_crawler_schema_change_policy   = var.glue_crawler_schema_change_policy
  glue_crawler_lineage_configuration  = var.glue_crawler_lineage_configuration
  glue_crawler_recrawl_policy         = var.glue_crawler_recrawl_policy
  s3_target                           = var.s3_target

  #SAF rule no 17
  tags = merge(module.tags.tags, local.optional_tags)
}

module "crawler_dynamodb" {
  source = "../../modules/crawler"

  glue_crawler_name          = "${local.name}-dynamodb"
  glue_crawler_database_name = var.glue_crawler_database_name
  glue_crawler_role          = module.iam_crawler_role.arn
  glue_crawler_table_prefix  = var.glue_crawler_table_prefix_dynamodb

  # SAF rule no 1 SecurityConfiguration
  glue_crawler_security_configuration = module.glue_security_configuration.glue_security_configuration_id
  dynamodb_target                     = var.dynamodb_target

  #SAF rule no 17
  tags = merge(module.tags.tags, local.optional_tags)
}

module "crawler_s3_and_dynamodb" {
  source = "../../modules/crawler"

  glue_crawler_name          = "${local.name}-s3-dynamodb"
  glue_crawler_database_name = var.glue_crawler_database_name
  glue_crawler_role          = module.iam_crawler_role.arn
  glue_crawler_table_prefix  = var.glue_crawler_table_prefix_s3_dynamodb

  # SAF rule no 1 SecurityConfiguration
  glue_crawler_security_configuration = module.glue_security_configuration.glue_security_configuration_id
  s3_target                           = var.s3_target
  dynamodb_target                     = var.dynamodb_target

  #SAF rule no 17
  tags = merge(module.tags.tags, local.optional_tags)
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 3
  upper   = false
  special = false
}

#An IAM role, used by the crawler to access other resources.
module "iam_crawler_role" {
  #source  = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.0"

  #The iam role name for glue crawler must start with AWSGlueServiceRole
  name        = "AWSGlueServiceRole-${local.name}"
  policy_arns = var.policy_arns
  aws_service = var.aws_service
  tags        = merge(module.tags.tags, local.optional_tags)
}

resource "aws_lakeformation_permissions" "iam_crawler" {

  permissions = var.permissions
  principal   = module.iam_crawler_role.arn

  database {
    name       = var.database_name
    catalog_id = var.database_catalog_id
  }
  depends_on = [
    module.crawler_s3
  ]
}