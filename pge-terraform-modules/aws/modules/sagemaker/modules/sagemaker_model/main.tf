/*
* # AWS Sagemaker module
* # Terraform module which creates Sagemaker Model
*/
# Filename     : aws/modules/sagemaker/modules/aws_sagemaker_model/main.tf 
# Date         : 13 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of aws_sagemaker_model

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



resource "aws_sagemaker_model" "sagemaker_model" {
  name                     = var.name
  execution_role_arn       = var.execution_role_arn
  enable_network_isolation = true
  tags                     = local.module_tags
  vpc_config {
    security_group_ids = var.security_group_ids
    subnets            = var.subnet_ids
  }

  # primary_container conflicts with container so the for_each condition looks for value of primary_container and execute the below dynamic block.
  # Using "{}" instead of "null" in for_each due the given key does not identify an element in this collection value.  
  dynamic "primary_container" {
    for_each = var.containers.primary_container != {} ? [var.containers.primary_container] : []
    content {
      image              = primary_container.value.image
      mode               = lookup(primary_container.value, "mode", "SingleModel")
      model_data_url     = lookup(primary_container.value, "model_data_url", null)
      container_hostname = lookup(primary_container.value, "container_hostname", null)
      environment        = lookup(primary_container.value, "environment", {})

      dynamic "image_config" {
        for_each = lookup(primary_container.value, "image_config", {}) != {} ? [lookup(primary_container.value, "image_config", {})] : []
        content {
          repository_access_mode = "Vpc"

          dynamic "repository_auth_config" {
            for_each = lookup(primary_container.value, "repository_auth_config", {}) != {} ? [lookup(primary_container.value, "repository_auth_config", {})] : []
            content {
              repository_credentials_provider_arn = repository_auth_config.value.repository_credentials_provider_arn
            }
          }
        }
      }
    }
  }

  # container conflicts with primary_container so the for_each condition looks for value of container and executes the below dynamic block.
  # Using "{}" instead of "null" in for_each due the given key does not identify an element in this collection value.
  dynamic "container" {
    for_each = var.containers.container
    content {
      image              = container.value.image
      mode               = lookup(container.value, "mode", "SingleModel")
      model_data_url     = lookup(container.value, "model_data_url", null)
      container_hostname = lookup(container.value, "container_hostname", null)
      environment        = lookup(container.value, "environment", null)

      dynamic "image_config" {
        for_each = lookup(container.value, "image_config", {}) != {} ? [lookup(container.value, "image_config", {})] : []
        content {
          repository_access_mode = "Vpc"

          dynamic "repository_auth_config" {
            for_each = lookup(container.value, "repository_auth_config", {}) != {} ? [lookup(container.value, "repository_auth_config", {})] : []
            content {
              repository_credentials_provider_arn = repository_auth_config.value.repository_credentials_provider_arn
            }
          }
        }
      }
    }
  }

  dynamic "inference_execution_config" {
    for_each = var.inference_execution_config != {} ? [var.inference_execution_config] : []
    content {
      mode = inference_execution_config.value.mode
    }
  }
}
  