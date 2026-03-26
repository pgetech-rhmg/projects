/*
* # AWS Sagemaker module
* # Terraform module which creates Sagemaker flow definition.
*/
# Filename     : aws/modules/sagemaker/modules/flow_definition/main.tf 
# Date         : 16 September 2022
# Author       : TCS
# Description  : Terraform sub-module for creation of flow definition

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

resource "aws_sagemaker_flow_definition" "flow_definition" {

  flow_definition_name = var.flow_definition_name
  role_arn             = var.iam_role_arn

  human_loop_config {
    human_task_ui_arn                     = var.human_task_ui_arn
    task_availability_lifetime_in_seconds = var.task_availability_lifetime_in_seconds
    task_count                            = var.task_count
    task_description                      = coalesce(var.task_description, format("%s human worker task - Managed by Terraform", var.flow_definition_name))
    task_keywords                         = var.task_keywords
    task_time_limit_in_seconds            = var.task_time_limit_in_seconds
    task_title                            = var.task_title
    workteam_arn                          = var.workteam_arn

    dynamic "public_workforce_task_price" {
      #The 'public_workforce_task_price' dynamic block is optional and execute only once.
      #Below optional block will run only if value is provided to the variable 'public_workforce_task_price'. The variable 'public_workforce_task_price' is a map.
      #As per SAF
      #  Amazon SageMaker Ground Truth and Amazon Augmented AI work teams fall into one of three workforce types: public (with Amazon Mechanical Turk), private, and vendor.
      #Ground Truth must not use Mechanical Turk because it exposes PG&E data to outsiders.
      #So the 'public_workforce_task_price' dynamic block will not work if the values are provided since the workteam is private.

      for_each = var.public_workforce_task_price != null ? [var.public_workforce_task_price] : []
      content {
        dynamic "amount_in_usd" {
          #The 'amount_in_usd' optional block, can iterate only once when the end user pass value for the variable 'public_workforce_task_price'.
          for_each = lookup(public_workforce_task_price.value, "amount_in_usd", {}) != {} ? [lookup(public_workforce_task_price.value, "amount_in_usd")] : []
          content {
            cents                     = lookup(amount_in_usd.value, "cents", null)
            dollars                   = lookup(amount_in_usd.value, "dollars", null)
            tenth_fractions_of_a_cent = lookup(amount_in_usd.value, "tenth_fractions_of_a_cent", null)
          }
        }
      }
    }
  }

  dynamic "human_loop_activation_config" {
    #The 'human_loop_activation_config' dynamic block is optional and execute only once.
    #Below optional block will run only if value is provided to the variable 'human_loop_activation_config'. The variable 'human_loop_activation_config' is a map.
    for_each = var.human_loop_activation_config != null ? [var.human_loop_activation_config] : []
    content {
      dynamic "human_loop_activation_conditions_config" {
        #The 'human_loop_activation_conditions_config' required block, can iterate only once when the end user pass value for the variable 'public_workforce_task_price'.
        for_each = [human_loop_activation_config.value.human_loop_activation_conditions_config]
        content {
          human_loop_activation_conditions = human_loop_activation_conditions_config.value.human_loop_activation_conditions
        }
      }
    }
  }

  dynamic "human_loop_request_source" {
    #The 'human_loop_request_source' dynamic block is optional and execute only once.
    #Below optional block will run only if value is provided to the variable 'human_loop_request_source'. The variable 'human_loop_request_source' is a map.
    for_each = var.human_loop_request_source != null ? [var.human_loop_request_source] : []
    content {
      aws_managed_human_loop_request_source = human_loop_request_source.value.aws_managed_human_loop_request_source
    }
  }

  output_config {
    #If the user needs to provide some specific folder within the s3 bucket, pass the value like: "${module.s3.s3.bucket}/test-folder"
    s3_output_path = "s3://${var.s3_output_path}/"
    kms_key_id     = var.kms_key_id
  }
  tags = local.module_tags
}