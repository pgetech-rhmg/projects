/*
* # AWS sagemaker notebook instnace module
* # Terraform module which creates Sagemaker notebook instnace
Filename     : aws/modules/sagemaker/modules/notebook_instnace/main.tf
Date         : August 25 2022 
Author       : TCS
Description  : Terraform sub-module for creation of notebook_instnace in sagemaker
*/
terraform {
  required_version = ">=1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
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

data "external" "validate_kms" {
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}


resource "aws_sagemaker_notebook_instance" "ni" {
  name                         = var.instance_name
  role_arn                     = var.role_arn
  instance_type                = var.instance_type
  platform_identifier          = var.platform_identifier
  volume_size                  = var.volume_size
  subnet_id                    = var.subnet_id
  security_groups              = var.security_groups
  additional_code_repositories = var.additional_code_repositories
  default_code_repository      = var.default_code_repository
  direct_internet_access       = var.direct_internet_access
  kms_key_id                   = var.kms_key_id
  lifecycle_config_name        = var.lifecycle_config_name
  root_access                  = var.root_access

  instance_metadata_service_configuration {
    minimum_instance_metadata_service_version = var.metadata_service_version
  }

  tags = local.module_tags
}