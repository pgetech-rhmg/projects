<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM parameters in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |

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
| [aws_ssm_parameter.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.validate_securestring](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_pattern"></a> [allowed\_pattern](#input\_allowed\_pattern) | Regular expression used to validate the parameter value. | `string` | `""` | no |
| <a name="input_data_type"></a> [data\_type](#input\_data\_type) | Data type of the parameter. Valid values: text and aws:ec2:image for AMI format, see the Native parameter support for Amazon Machine Image IDs. | `string` | `"text"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the parameter. | `string` | `"AWS SSM Recource created by TFC "` | no |
| <a name="input_key_id"></a> [key\_id](#input\_key\_id) | KMS key ID or ARN for encrypting a SecureString. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the parameter | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_tier"></a> [tier](#input\_tier) | Parameter tier to assign to the parameter. Valid tiers are Standard, Advanced, and Intelligent-Tiering | `string` | `"Standard"` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of the parameter. Valid types are String, StringList and SecureString. | `string` | `"String"` | no |
| <a name="input_value"></a> [value](#input\_value) | Value of the parameter. This value is always marked as sensitive in the Terraform plan output, regardless of type. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the parameter. |
| <a name="output_name"></a> [name](#output\_name) | Name of the parameter. |
| <a name="output_type"></a> [type](#output\_type) | Type of the parameter. Valid types are String, StringList and SecureString. |
| <a name="output_value"></a> [value](#output\_value) | Value of the parameter. This value is always marked as sensitive in the Terraform plan output, regardless of type. |
| <a name="output_version"></a> [version](#output\_version) | Version of the parameter. |


<!-- END_TF_DOCS -->