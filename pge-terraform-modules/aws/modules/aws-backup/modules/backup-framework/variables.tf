module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.0"
  tags    = var.tags
}

variable "framework_name" {
  description = " A name for the audit framework"
  type        = string
}

variable "framework_description" {
  description = " A description for the audit framework"
  type        = string
}

variable "framework_controls" {
  type = list(object({
    name = string
    input_parameters = optional(list(object({
      name = string
      value = string
    })))
    scope = optional(object ({
      compliance_resource_types = optional(list(string))
      tags                      = optional(map(string))
    }))
  }))
  description = "List of controls and their input parameters for the AWS Backup framework"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

variable "frameworks_report_bucket_name" {
  description = "Name of the bucket to collect the reports"
  default = null
}

variable "report_plan_name_prefix" {
  description = "Name for the compliance report plan"
  default = "compliance_report_plan"
}

variable "report_plan_description" {
  description = "Description for the compliance report plan"
  default = "Sample compliance report plan"
}

variable "s3_key_prefix" {
  description = "s3_key_prefix to store reports"
  default = "backup-reports"
}

variable "aws_role_for_s3_access" {
  description = "Role name to provide resource policy permissions to s3 bucket"
  default = "aws-service-role/reports.backup.amazonaws.com/AWSServiceRoleForBackupReports"
}

variable "report_templates" {
  description = "Choose one or more report types: BACKUP_JOB_REPORT, COPY_JOB_REPORT, RESTORE_JOB_REPORT, accounts or OUs list to include and other attributes"
  type        = list(object({
    report_type           = string
    accounts              = optional(list(string))
    organization_units    = optional(list(string))
    framework_arns        = optional(list(string))
    number_of_frameworks  = optional(number)
    regions               = optional(list(string))
    }))
}