<!-- BEGIN_TF_DOCS -->
# AWS Fsx windows and lustre backup
Terraform module which creates SAF2.0 fsx windows and lustre backup in AWS.

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_fsx_backup.fsx_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_backup) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_file_system_id"></a> [file\_system\_id](#input\_file\_system\_id) | The ID of the file system to back up. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags. | `map(string)` | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | aws\_fsx\_backup provides the following Timeouts configuration options: create & delete. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsx_backup_arn"></a> [fsx\_backup\_arn](#output\_fsx\_backup\_arn) | Amazon Resource Name of the backup. |
| <a name="output_fsx_backup_id"></a> [fsx\_backup\_id](#output\_fsx\_backup\_id) | Identifier of the backup |
| <a name="output_fsx_backup_kms_key_id"></a> [fsx\_backup\_kms\_key\_id](#output\_fsx\_backup\_kms\_key\_id) | The ID of the AWS Key Management Service (AWS KMS) key used to encrypt the backup of the Amazon FSx file system's data at rest. |
| <a name="output_fsx_backup_owner_id"></a> [fsx\_backup\_owner\_id](#output\_fsx\_backup\_owner\_id) | AWS account identifier that created the file system. |
| <a name="output_fsx_backup_tags_all"></a> [fsx\_backup\_tags\_all](#output\_fsx\_backup\_tags\_all) | AWS account identifier that created the file system. |
| <a name="output_fsx_backup_type"></a> [fsx\_backup\_type](#output\_fsx\_backup\_type) | The type of the file system backup. |


<!-- END_TF_DOCS -->