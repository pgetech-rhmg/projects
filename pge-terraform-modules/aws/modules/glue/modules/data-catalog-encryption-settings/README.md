<!-- BEGIN_TF_DOCS -->
# AWS Glue data catalog encryption settings module.
Terraform module which creates SAF2.0 Glue data catalog encryption settings in AWS.
This module to be executed first to enable glue catalog encyption.
When the encryption is turned on , all the future data catalog objects are encrypted.
The encryption settings are applied for the entire data catalog which includes:
Databases, Tables, Partitions,Table Versions, Connections, User-defined Functions.

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
| [aws_glue_data_catalog_encryption_settings.glue_data_catalog_encryption_settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_data_catalog_encryption_settings) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | The ID of the Data Catalog to set the security configuration for. If none is provided, the AWS account ID is used by default. | `string` | `null` | no |
| <a name="input_connection_password_aws_kms_key_id"></a> [connection\_password\_aws\_kms\_key\_id](#input\_connection\_password\_aws\_kms\_key\_id) | A KMS key ARN that is used to encrypt the connection password. If connection password protection is enabled, the caller of CreateConnection and UpdateConnection needs at least kms:Encrypt permission on the specified AWS KMS key, to encrypt passwords before storing them in the Data Catalog. | `string` | n/a | yes |
| <a name="input_encryption_at_rest_sse_aws_kms_key_id"></a> [encryption\_at\_rest\_sse\_aws\_kms\_key\_id](#input\_encryption\_at\_rest\_sse\_aws\_kms\_key\_id) | The ARN of the AWS KMS key to use for encryption at rest. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_data_catalog_encryption_settings"></a> [aws\_glue\_data\_catalog\_encryption\_settings](#output\_aws\_glue\_data\_catalog\_encryption\_settings) | The map of aws\_glue\_data\_catalog\_encryption\_settings. |
| <a name="output_catalog_encryption_settings_id"></a> [catalog\_encryption\_settings\_id](#output\_catalog\_encryption\_settings\_id) | The ID of the Data Catalog to set the security configuration for. |


<!-- END_TF_DOCS -->