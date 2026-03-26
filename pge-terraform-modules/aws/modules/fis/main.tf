/*
 * # AWS FIS Experiment Template Module
 * Terraform usage example which creates an FIS experiment template in AWS.
 * AWS FIS (Fault Injection Simulator) is a fully managed service 
 * that enables you to perform fault injection experiments on your AWS workloads.
 */
#  Filename    : aws/modules/fis/main.tf
#  Date        : 05 May 2025
#  Author      : pge
#  Description : The Terraform module creates an FIS experiment template.
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

# Local variables for tags and namespace
locals {
  module_tags = merge(var.tags, { tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })

  # Role ARN Selection Logic:
  # - If var.fis_role_name is provided (not empty), use the existing role's ARN from data source
  # - If var.fis_role_name is empty, use the ARN from the newly created role via fis_role module
  # This ensures the FIS experiment template always has a valid IAM role ARN with proper permissions
  role_arn = var.fis_role_name != "" ? data.aws_iam_role.fis[0].arn : module.fis_role[0].arn
}

# Workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# Data Sources - Centralized location for all data lookups
# Data block to fetch existing IAM role if it exists
data "aws_iam_role" "fis" {
  count = var.fis_role_name != "" ? 1 : 0
  name  = var.fis_role_name
}

# Data block to fetch existing S3 bucket if validation is enabled
data "aws_s3_bucket" "fis_logs_s3_bucket" {
  count  = var.validate_s3_bucket && var.log_type == "s3" ? 1 : 0
  bucket = var.s3_bucket_name
}

# Data block to fetch existing CloudWatch Log Group if it exists
data "aws_cloudwatch_log_group" "this" {
  count = var.log_type == "cloudwatch" && var.cloudwatch_log_group_name != "" ? 1 : 0
  name  = var.cloudwatch_log_group_name
}

# Module to create IAM Role (conditionally created)
module "fis_role" {
  source  = "app.terraform.io/pgetech/iam/aws"
  version = "0.1.1"

  count       = length(var.fis_role_name) == 0 ? 1 : 0
  name        = var.fis_role_name == "" ? "fis-role-${var.fis_experiment_name}" : var.fis_role_name
  aws_service = coalesce(var.aws_service, ["fis.amazonaws.com"])
  tags        = local.module_tags
  inline_policy = concat(
    # Load comprehensive FIS IAM policy from root module if it exists
    fileexists("${path.module}/fis_iam_policy.json") ? [templatefile("${path.module}/fis_iam_policy.json", {})] : [],
    # Add any additional custom policies passed via variable
    var.inline_policy
  )
}

# Define the FIS Experiment Template
resource "aws_fis_experiment_template" "experiment_template" {
  # role_arn: The IAM role ARN that FIS will assume to execute the experiment
  # This role must have permissions for:
  # - FIS actions (fis:*)
  # - Target resource actions (e.g., ec2:* for EC2 experiments)  
  # - Logging permissions (S3 or CloudWatch based on log_type configuration)
  # Value comes from local.role_arn which selects between existing or newly created role
  role_arn    = local.role_arn
  description = var.description
  # Note "Name" tag is added for easier experiment identification
  tags = merge(local.module_tags, { Name = var.fis_experiment_name })

  dynamic "stop_condition" {
    for_each = var.stop_condition

    content {
      source = stop_condition.value.source
      value  = stop_condition.value.value
    }
  }

  dynamic "action" {
    for_each = var.action

    content {
      name        = action.value.name
      action_id   = action.value.action_id
      description = action.value.description
      start_after = action.value.start_after

      dynamic "parameter" {
        for_each = action.value.parameter

        content {
          key   = parameter.key
          value = parameter.value
        }
      }

      dynamic "target" {
        for_each = action.value.target

        content {
          key   = target.value.key
          value = target.value.value
        }
      }
    }
  }

  # Target configuration
  dynamic "target" {
    for_each = var.target

    content {
      name           = target.value.name
      resource_type  = target.value.resource_type
      selection_mode = target.value.selection_mode
      resource_arns  = target.value.resource_arns
      parameters     = try(target.value.parameters, null)

      dynamic "filter" {
        for_each = coalesce(target.value.filter, [])

        content {
          path   = filter.value.path
          values = filter.value.values
        }
      }

      dynamic "resource_tag" {
        for_each = target.value.resource_tags

        content {
          key   = resource_tag.value.key
          value = resource_tag.value.value
        }
      }
    }
  }

  # Log configuration (either S3 or CloudWatch)
  dynamic "log_configuration" {
    for_each = var.log_type == "s3" || var.log_type == "cloudwatch" ? [{}] : []

    content {
      log_schema_version = var.log_schema_version

      # Include CloudWatch Logs configuration only if log_type is "cloudwatch"
      dynamic "cloudwatch_logs_configuration" {
        for_each = var.log_type == "cloudwatch" && (var.cloudwatch_log_group_arn != "" || var.cloudwatch_log_group_name != "") ? [{}] : []

        content {
          log_group_arn = var.cloudwatch_log_group_arn != "" ? "${var.cloudwatch_log_group_arn}:*" : "${data.aws_cloudwatch_log_group.this[0].arn}:*"
        }
      }

      # Include S3 configuration only if log_type is "s3"
      dynamic "s3_configuration" {
        for_each = var.log_type == "s3" && var.s3_bucket_name != "" ? [{}] : []

        content {
          bucket_name = var.s3_bucket_name # Use the bucket name directly to avoid dependency issues
          prefix      = var.s3_logging.prefix
        }
      }
    }
  }

  experiment_options {
    account_targeting            = var.experiment_options.account_targeting
    empty_target_resolution_mode = var.experiment_options.empty_target_resolution_mode
  }

  # Experiment report configuration with default values
  dynamic "experiment_report_configuration" {
    for_each = var.experiment_report_configuration != null ? [var.experiment_report_configuration] : []

    content {
      dynamic "data_sources" {
        for_each = experiment_report_configuration.value.data_sources != null ? [experiment_report_configuration.value.data_sources] : []

        content {
          dynamic "cloudwatch_dashboard" {
            for_each = try(data_sources.value.cloudwatch_dashboard, [])

            content {
              dashboard_arn = cloudwatch_dashboard.value.dashboard_arn
            }
          }
        }
      }

      dynamic "outputs" {
        for_each = experiment_report_configuration.value.outputs != null ? [experiment_report_configuration.value.outputs] : []

        content {
          dynamic "s3_configuration" {
            for_each = outputs.value.s3_configuration != null ? [outputs.value.s3_configuration] : []

            content {
              bucket_name = s3_configuration.value.bucket_name
              prefix      = try(s3_configuration.value.prefix, "")
            }
          }
        }
      }

      post_experiment_duration = try(experiment_report_configuration.value.post_experiment_duration, "PT5M")
      pre_experiment_duration  = try(experiment_report_configuration.value.pre_experiment_duration, "PT5M")
    }
  }
}