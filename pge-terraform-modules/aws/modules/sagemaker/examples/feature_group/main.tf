/*
* # AWS Sagemaker feature group example
* # Terraform module example usage for Sagemaker feature group
*/
#
#  Filename    : aws/modules/sagemaker/examples/feature_group/main.tf
#  Date        : 13 Sep 2022
#  Author      : TCS
#  Description : The terraform usage example creates feature group

locals {
  name = "${var.name}-${random_string.name.result}"
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
  Order              = var.Order
}

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

module "feature_group" {
  source = "../../modules/feature_group"

  feature_group_name = local.name
  kms_key_id = null # replace with module.kms_key.key_arn, after key creation 
  feature_name = {
    event_time_feature_name        = var.event_time_feature_name
    record_identifier_feature_name = var.record_identifier_feature_name
  }
  role_arn           = module.sagemaker_iam_role.arn
  tags               = merge(module.tags.tags, var.optional_tags)
  feature_definition = var.feature_definition
  #If the user wants only online_store_config then offline_store_config block should be commented
  offline_store_config = {
    disable_glue_table_creation = true
    s3_storage_config = {
      s3_uri     = var.s3_uri
      kms_key_id = null # replace with module.kms_key.key_arn, after key creation 
    }
    data_catalog_config = {
      database   = var.database
      table_name = var.table_name
      catalog    = var.catalog
    }
  }
  #If the user wants only offline_store_config then enable_online_store config set to false
  online_store_config = {
    enable_online_store = true
    security_config = {
      kms_key_id = null # replace with module.kms_key.key_arn, after key creation 
    }
  }
}

module "sagemaker_iam_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  name        = var.name
  aws_service = var.role_service
  #AWS_Managed_Policy
  policy_arns = var.iam_policy_arns
  tags        = merge(module.tags.tags, var.optional_tags)
}


# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
# uncomment the following lines to create the kms key
#module "kms_key" {
# source  = "app.terraform.io/pgetech/kms/aws"
# version = "0.1.0"

#  name     = "cmk-${local.name}"
# policy   = file("${path.module}/kms_policy.json")
#  kms_role = var.kms_role
#  aws_role = var.aws_role
#  tags     = merge(module.tags.tags, var.optional_tags)
#}