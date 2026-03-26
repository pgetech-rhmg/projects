/*
 * # AWS Backup Audit Manager module
 * Terraform module which creates Audit manager framework and reports
*/
#
# Filename    : modules/audit-manager/main.tf
# Date        : 17 Apr 2025
# Author      : Balaji Desikachari (b5db@pge.com)
# Description : The modules creates AWS Backup Audit Manager resources
#

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
  reports_bucket_name = var.frameworks_report_bucket_name == null ? "${data.aws_caller_identity.current.account_id}-backup-reports-${data.aws_region.current.name}" : var.frameworks_report_bucket_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#workspace identifier module
module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

resource "random_string" "name" {
  length  = 5
  upper   = false
  special = false
}

resource "aws_backup_framework" "audit_framework" {
  name        = var.framework_name
  description = var.framework_description
  tags          = local.module_tags


  timeouts {
    delete = "6m"
    update = "6m"
  }
  
  lifecycle {  
    # Create new resource before destroying old one
    create_before_destroy = true
  }

  dynamic "control" {
    for_each = var.framework_controls 
    content {
      name = control.value.name

      dynamic "input_parameter" {
        for_each = control.value.input_parameters != null ? control.value.input_parameters : []
        content {
          name = input_parameter.value["name"]
          value = input_parameter.value["value"]
        }
      }

      dynamic "scope" {
        for_each = control.value.scope != null ? [control.value.scope] : []
        content {
          compliance_resource_types = scope.value.compliance_resource_types
          tags                      = scope.value.tags
        }
      }
    }
  }
}

module "reports_bucket" {
  source      = "app.terraform.io/pgetech/s3/aws"
  bucket_name = local.reports_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  policy      = templatefile("${path.module}/s3_bucket_user_policy.json", { aws_role = var.aws_role_for_s3_access, account_num = data.aws_caller_identity.current.account_id, bucket_name = local.reports_bucket_name })
  tags        = local.module_tags
}

resource "aws_backup_report_plan" "backup_report_plan" {
  for_each = { for idx, rpt in var.report_templates : idx => rpt }

  name = lower("${var.report_plan_name_prefix}_${each.value.report_type}")
  description = var.report_plan_description

  report_delivery_channel {
    s3_bucket_name = local.reports_bucket_name
    formats = ["CSV"]
    s3_key_prefix = var.s3_key_prefix
  }

  dynamic "report_setting" {
    for_each = each.value != null ? [each.value] : []
    content {
      report_template = report_setting.value["report_type"]
      organization_units = lookup(report_setting.value, "organization_units", null)
      accounts = lookup(report_setting.value, "accounts", null)
      framework_arns = lookup(report_setting.value, "framework_arns", null)
      number_of_frameworks =  lookup(report_setting.value, "number_of_frameworks", null)
      regions =  lookup(report_setting.value, "regions", null)
    }
  }
  tags = local.module_tags
}

