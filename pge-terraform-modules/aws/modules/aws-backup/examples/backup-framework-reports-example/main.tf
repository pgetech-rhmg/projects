/*
 * AWS backup Audit Manager framework and reports example
 * Terraform module which creates SAF2.0 AWS Backup Audit Manager Frameworks and reports
*/

# Filename    : aws/modules/ram/examples/backup-framework-reports-example/main.tf
# Date        : 27 Mar 2025
# Author      : Balaji Desikachari (B5DB@pge.com)
# Description : Create AWS Backup Audit framework and reports
#

locals {
  optional_tags = var.optional_tags
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

#########################################
# Backup Audit Manager
#########################################

module "aws-backup-audit-manager" {
  source = "./aws-backup/modules/backup-framework/"

  framework_name = "ransomware_vault_audit_framework"
  framework_description = "A framework to audit the LAG & classic vault controls."
  framework_controls = [
    {
      name = "BACKUP_RECOVERY_POINT_MINIMUM_RETENTION_CHECK"
      input_parameters = [
        {
          name = "requiredRetentionDays"
          value = "35"
        }
      ]
      scope = {
        tags = var.scope_tags
      }
    },
    {
      name = "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
      scope = {
        tags = var.scope_tags
      }
    },
    {
      name = "BACKUP_RECOVERY_POINT_ENCRYPTED"
      scope = {
        tags = var.scope_tags
      }
    },    
    {
      name = "BACKUP_LAST_RECOVERY_POINT_CREATED"
      input_parameters = [
        {
          name = "recoveryPointAgeUnit"
          value = "days"
        },
        {
          name  = "recoveryPointAgeValue"
          value = "1"
        }
      ]
      scope = {
        tags = var.scope_tags
      }
    }   
  ]
  tags   = merge(module.tags.tags, local.optional_tags)

  report_plan_name_prefix = "ransomware"
  report_plan_description = "Ransomware protection reports"
  report_templates = [
    { 
      report_type = "BACKUP_JOB_REPORT"
    },
    {
      report_type = "COPY_JOB_REPORT"
    },
    {
      report_type = "RESOURCE_COMPLIANCE_REPORT"
      accounts    = var.accounts
    }
    
  ]
}

