<!-- BEGIN_TF_DOCS -->
# AWS Backup module
Terraform module which creates SAF2.0 AWS-Backup Audit framework and reports

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_framework.audit_framework](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_report_plan.backup_report_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_framework_name"></a> [framework_name](#input_framework_name) | A name for the audit framework | `string` | n/a | yes |
| <a name="input_framework_description"></a> [framework_description](#input_framework_description) | A description for the audit framework | `string` | n/a | yes |
| <a name="input_framework_controls"></a> [framework_controls](#input_framework_controls) | List of controls and their input parameters for the AWS Backup framework | ```list(object({    name = string    input_parameters = optional(list(object({      name = string      value = string    })))    scope = optionalobject({      compliance_resource_types = optional(list(string))      tags = optional(map(string))    }))  }))```| n/a | yes |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |
| <a name="input_frameworks_report_bucket_name"></a> [frameworks_report_bucket_name](#input_frameworks_report_bucket_name) | Name of the bucket to collect the reports | `string` | `null` | no |
| <a name="input_report_plan_name_prefix"></a> [report_plan_name_prefix](#input_report_plan_name_prefix) | Name for the compliance report plan | `string` | `"compliance_report_plan"` | no |
| <a name="input_report_plan_description"></a> [report_plan_description](#input_report_plan_description) | Description for the compliance report plan | `string` | `"Sample compliance report plan"` | no |
| <a name="input_s3_key_prefix"></a> [s3_key_prefix](#input_s3_key_prefix) | s3_key_prefix to store reports | `string` | `"backup-reports"` | no |
| <a name="input_aws_role_for_s3_access"></a> [aws_role_for_s3_access](#input_aws_role_for_s3_access) | Role name to provide resource policy permissions to s3 bucket | `string` | `"aws-service-role/reports.backup.amazonaws.com/AWSServiceRoleForBackupReports"` | no |
| <a name="input_report_templates"></a> [report_templates](#input_report_templates) | Choose one or more report types: BACKUP_JOB_REPORT, COPY_JOB_REPORT, RESTORE_JOB_REPORT, accounts or OUs list to include and other attributes | ``` list(object({  report_type = string  accounts = optional(list(string))  rganization_units = optional(list(string))  framework_arns = optional(list(string))  number_of_frameworks = optional(number)  regions = optional(list(string))}))``` | n/a | yes |
  
## Outputs

| Name | Description |
|------|-------------|


<!-- END_TF_DOCS -->