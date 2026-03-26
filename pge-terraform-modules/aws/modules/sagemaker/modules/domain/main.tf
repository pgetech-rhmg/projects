/*
* # AWS Sagemaker module
* # Terraform module which creates Sagemaker domain
*/
# Filename     : aws/modules/sagemaker/modules/domain/main.tf 
# Date         : 15 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of Sagemaker domain

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


resource "aws_sagemaker_domain" "domain" {
  domain_name = var.domain_name
  #As per SAF Rules
  auth_mode  = "IAM"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  kms_key_id = var.kms_key_id
  #As per SAF Rules
  app_network_access_type = "VpcOnly"
  tags                    = local.module_tags
  tag_propagation         = var.tag_propagation

  default_user_settings {
    execution_role  = var.execution_role
    security_groups = var.security_groups
    dynamic "sharing_settings" {
      #Below optional block will run only if value of 'notebook_output_option' is provided as 'Allowed'
      for_each = var.notebook_output_option == "Allowed" ? [true] : []
      content {
        notebook_output_option = var.notebook_output_option
        s3_kms_key_id          = var.kms_key_id
        s3_output_path         = var.s3_output_path
      }
    }
    dynamic "tensor_board_app_settings" {
      #Below optional block will run only if value of 'tensor_board_app_settings_instance_type' is provided
      #Though in terraform registry 'instance_type' is optional ,it is a mandatory argument and will throw an error if skipped
      for_each = var.tensor_board_app_settings_instance_type != null ? [true] : []
      content {
        default_resource_spec {
          instance_type               = var.tensor_board_app_settings_instance_type
          lifecycle_config_arn        = var.tensor_board_app_settings_lifecycle_config_arn
          sagemaker_image_arn         = var.tensor_board_app_settings_sagemaker_image_arn
          sagemaker_image_version_arn = var.tensor_board_app_settings_sagemaker_image_version_arn
        }
      }
    }
    dynamic "jupyter_server_app_settings" {
      #Below optional block will run only if value of 'jupyter_server_app_settings_instance_type' is provided
      #JupyterServer apps only support the 'system' value & we cannot explicitly specify an instance type as of now 
      for_each = var.jupyter_server_app_settings_instance_type != null ? [true] : []
      content {
        default_resource_spec {
          instance_type               = var.jupyter_server_app_settings_instance_type
          lifecycle_config_arn        = var.jupyter_server_app_settings_lifecycle_config_arn
          sagemaker_image_arn         = var.jupyter_server_app_settings_sagemaker_image_arn
          sagemaker_image_version_arn = var.jupyter_server_app_settings_sagemaker_image_version_arn
        }
        lifecycle_config_arns = var.jupyter_server_app_settings_lifecycle_config_arns
      }
    }
    dynamic "kernel_gateway_app_settings" {
      #Below optional block will run only if value of 'kernel_gateway_app_settings_instance_type' is provided
      #Though in terraform registry 'instance_type' is optional ,it is a mandatory argument and will throw an error if skipped
      for_each = var.kernel_gateway_app_settings_instance_type != null ? [true] : []
      content {
        default_resource_spec {
          instance_type               = var.kernel_gateway_app_settings_instance_type
          lifecycle_config_arn        = var.kernel_gateway_app_settings_lifecycle_config_arn
          sagemaker_image_arn         = var.kernel_gateway_app_settings_sagemaker_image_arn
          sagemaker_image_version_arn = var.kernel_gateway_app_settings_sagemaker_image_version_arn
        }
        lifecycle_config_arns = var.kernel_gateway_app_settings_lifecycle_config_arns
        dynamic "custom_image" {
          #Below optional block will run only if value of 'app_image_config_name' is provided
          for_each = var.app_image_config_name != null ? [true] : []
          content {
            app_image_config_name = var.app_image_config_name
            image_name            = var.image_name
            image_version_number  = var.image_version_number
          }
        }
      }
    }
  }

  # Default Space Settings - Controls default settings for SageMaker Studio Spaces
  dynamic "default_space_settings" {
    # Only include default_space_settings if at least one space setting is provided
    for_each = (var.default_space_execution_role != null ||
      var.default_space_security_groups != null ||
      var.default_space_jupyter_server_app_settings_instance_type != null ||
    var.default_space_kernel_gateway_app_settings_instance_type != null) ? [true] : []
    content {
      execution_role  = var.default_space_execution_role != null ? var.default_space_execution_role : var.execution_role
      security_groups = var.default_space_security_groups != null ? var.default_space_security_groups : var.security_groups

      dynamic "jupyter_server_app_settings" {
        # Include JupyterServer settings if instance type is provided
        for_each = var.default_space_jupyter_server_app_settings_instance_type != null ? [true] : []
        content {
          default_resource_spec {
            instance_type = var.default_space_jupyter_server_app_settings_instance_type
          }
        }
      }

      dynamic "kernel_gateway_app_settings" {
        # Include KernelGateway settings if instance type is provided
        for_each = var.default_space_kernel_gateway_app_settings_instance_type != null ? [true] : []
        content {
          default_resource_spec {
            instance_type = var.default_space_kernel_gateway_app_settings_instance_type
          }
        }
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.home_efs_file_system != null ? [true] : []
    #Below optional block will run only if value of 'home_efs_file_system' is provided
    content {
      home_efs_file_system = var.home_efs_file_system
    }
  }
}