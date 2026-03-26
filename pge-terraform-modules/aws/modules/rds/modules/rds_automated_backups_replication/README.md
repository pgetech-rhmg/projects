<!-- BEGIN_TF_DOCS -->
# rds\_automated\_backups\_replication module
Terraform module which creates SAF2.0 db\_instance\_automated\_backups\_replication resource.
This module can only be used in conjunction with Oracle and sqlserver modules
and is not intended to be used as a standalone module.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance_automated_backups_replication.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance_automated_backups_replication) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The KMS encryption key ARN in the destination AWS Region | `string` | `null` | no |
| <a name="input_pre_signed_url"></a> [pre\_signed\_url](#input\_pre\_signed\_url) | A URL that contains a Signature Version 4 signed request for the StartDBInstanceAutomatedBackupsReplication action to be called in the AWS Region of the source DB instance | `string` | `null` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | The retention period for the replicated automated backups | `number` | `7` | no |
| <a name="input_source_db_instance_arn"></a> [source\_db\_instance\_arn](#input\_source\_db\_instance\_arn) | The ARN of the source DB instance for the replicated automated backups | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_automated_backups_replication_id"></a> [db\_instance\_automated\_backups\_replication\_id](#output\_db\_instance\_automated\_backups\_replication\_id) | The automated backups replication id |


<!-- END_TF_DOCS -->