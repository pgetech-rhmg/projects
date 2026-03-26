/*
* # AWS Sagemaker module
* # Terraform module which creates app_image_config
# Filename     : aws/modules/sagemaker/modules/app_image_config/main.tf 
# Date         : 30 Aug 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of app_image_config
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


resource "aws_sagemaker_app_image_config" "app_image_config" {
  app_image_config_name = var.app_image_config_name
  dynamic "kernel_gateway_image_config" {
    for_each = can(var.kernel_gateway_image_config.kernel_spec.name) ? [var.kernel_gateway_image_config] : []
    content {
      kernel_spec {
        name         = kernel_gateway_image_config.value.kernel_spec.name
        display_name = try(kernel_gateway_image_config.value.kernel_spec.display_name, null)
      }
      file_system_config {
        default_gid = try(kernel_gateway_image_config.value.file_system_config.default_gid, null)
        default_uid = try(kernel_gateway_image_config.value.file_system_config.default_uid, null)
        mount_path  = try(kernel_gateway_image_config.value.file_system_config.mount_path, null)
      }
    }
  }
  tags = local.module_tags
}