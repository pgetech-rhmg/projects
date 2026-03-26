<!-- BEGIN_TF_DOCS -->
# AWS Redshift
Terraform module which creates SAF2.0 Redshift usage limits in AWS

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.1 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_redshift_snapshot_copy_grant.test_tf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_snapshot_copy_grant) | resource |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The unique identifier for the customer master key (CMK) that the grant applies to. Specify the key ID or the Amazon Resource Name (ARN) of the CMK. To specify a CMK in a different AWS account, you must use the key ARN. If not specified, the default key is used. | `string` | n/a | yes |
| <a name="input_snapshot_copy_grant_name"></a> [snapshot\_copy\_grant\_name](#input\_snapshot\_copy\_grant\_name) | A friendly name for identifying the grant. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_redshift_snapshot_copy_grant_all"></a> [aws\_redshift\_snapshot\_copy\_grant\_all](#output\_aws\_redshift\_snapshot\_copy\_grant\_all) | A map of aws redshift snapshot copy grant resource attributes references |
| <a name="output_snapshot_grant_copy_arn"></a> [snapshot\_grant\_copy\_arn](#output\_snapshot\_grant\_copy\_arn) | Amazon Resource Name (ARN) of snapshot copy grant |
| <a name="output_snapshot_grant_copy_id"></a> [snapshot\_grant\_copy\_id](#output\_snapshot\_grant\_copy\_id) | ID of snapshot copy grant |

<!-- END_TF_DOCS -->