<!-- BEGIN_TF_DOCS -->
# AWS SES module example
Terraform module example which creates SAF2.0 SES configuration set in AWS.
SES terraform resources don't support tags at this time.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_ses"></a> [ses](#module\_ses) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_ses_configuration_set_name"></a> [ses\_configuration\_set\_name](#input\_ses\_configuration\_set\_name) | Name of the configuration set. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_last_fresh_start"></a> [last\_fresh\_start](#output\_last\_fresh\_start) | Date and time at which the reputation metrics for the configuration set were last reset. Resetting these metrics is known as a fresh start. |
| <a name="output_ses_configuration_set_arn"></a> [ses\_configuration\_set\_arn](#output\_ses\_configuration\_set\_arn) | SES configuration set ARN. |
| <a name="output_ses_configuration_set_id"></a> [ses\_configuration\_set\_id](#output\_ses\_configuration\_set\_id) | SES configuration set name. |

<!-- END_TF_DOCS -->