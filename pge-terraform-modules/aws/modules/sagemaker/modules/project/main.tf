/*
* # AWS Sagemaker module
* # Terraform module which creates Sagemaker Project
*/
# Filename     : aws/modules/sagemaker/modules/project/main.tf 
# Date         : 6 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of Sagemaker Project

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


resource "aws_sagemaker_project" "project" {
  project_name        = var.project_name
  project_description = coalesce(var.project_description, format("%s sagemaker project", var.project_name))

  dynamic "service_catalog_provisioning_details" {
    for_each = var.service_catalog_provisioning_details
    content {
      path_id                  = lookup(service_catalog_provisioning_details.value, "path_id", null)
      product_id               = service_catalog_provisioning_details.value.product_id
      provisioning_artifact_id = lookup(service_catalog_provisioning_details.value, "provisioning_artifact_id", null)
      dynamic "provisioning_parameter" {
        for_each = lookup(service_catalog_provisioning_details.value, "provisioning_parameter", [])
        content {
          key   = provisioning_parameter.value.key
          value = lookup(provisioning_parameter.value, "value", null)
        }
      }
    }
  }
  tags = local.module_tags

}