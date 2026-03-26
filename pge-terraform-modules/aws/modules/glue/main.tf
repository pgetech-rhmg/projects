/*
 * # AWS Glue Job module.
 * Terraform module which creates SAF2.0 Glue Job in AWS.
*/

#
#  Filename    : aws/modules/glue/main.tf
#  Date        : 21 July 2022
#  Author      : TCS
#  Description : Glue Job Creation


terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Module      : Creation of Glue Job
# Description : This terraform module creates a Glue job.

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



resource "aws_glue_job" "glue_job" {

  name     = var.glue_job_name
  role_arn = var.glue_job_role_arn

  dynamic "command" {
    for_each = var.glue_job_command
    content {
      name            = lookup(command.value, "name", "glueetl")
      python_version  = lookup(command.value, "python_version", null)
      script_location = command.value.script_location
    }
  }

  connections = var.glue_job_connections

  # SAF Rule to enable continuous logging and to enable continous monitoring.
  default_arguments = merge(
    var.glue_job_default_arguments,
    {
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-metrics"                   = ""
    }
  )

  non_overridable_arguments = var.non_overridable_arguments
  description               = coalesce(var.glue_job_description, var.glue_job_name)

  dynamic "execution_property" {
    for_each = var.max_concurrent_runs != null ? [true] : []
    content {
      max_concurrent_runs = var.max_concurrent_runs
    }
  }

  glue_version = var.glue_job_glue_version
  max_capacity = var.glue_job_max_capacity
  max_retries  = var.glue_job_max_retries

  dynamic "notification_property" {
    for_each = var.notify_delay_after != null ? [true] : []
    content {
      notify_delay_after = var.notify_delay_after
    }
  }

  timeout                = var.glue_job_timeout
  security_configuration = var.glue_job_security_configuration
  worker_type            = var.glue_job_worker_type
  number_of_workers      = var.glue_job_number_of_workers
  tags                   = local.module_tags

}
