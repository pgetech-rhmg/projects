/*
* # AWS Sagemaker module
* # Terraform module which creates user_profile in sagemaker domain
*/
# Filename     : aws/modules/sagemaker/modules/user_profile/main.tf 
# Date         : 19 Sep 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of user_profile

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
  count   = (var.tags["DataClassification"] != "Internal" && var.tags["DataClassification"] != "Public" && var.s3_kms_key_id == null) ? 1 : 0
  program = ["sh", "-c", ">&2 echo kms key id is mandatory for the DataClassification type; exit 1"]
}

resource "aws_sagemaker_user_profile" "user_profile" {
  user_profile_name = var.user_profile_name
  domain_id         = var.domain_id
  tags              = local.module_tags
  user_settings {
    execution_role  = var.execution_role
    security_groups = var.security_groups
    dynamic "sharing_settings" {
      #Below optional block will run only if value of 'notebook_output_option' is provided as 'Allowed'
      for_each = var.notebook_output_option == "Allowed" ? [true] : []
      content {
        notebook_output_option = var.notebook_output_option
        s3_kms_key_id          = null # replace with module.s3_kms_key_id.key_arn, after key creation #var.s3_kms_key_id
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
      for_each = var.jupyter_server_app_settings_lifecycle_config_arn != null ? [true] : []
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
}