<!-- BEGIN_TF_DOCS -->
# AWS SES module
Terraform module which creates SAF2.0 SES configuration set in AWS.
SES terraform resources don't support tags at this time.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.68.0 |

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
| [aws_ses_configuration_set.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_configuration_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_redirect_domain"></a> [custom\_redirect\_domain](#input\_custom\_redirect\_domain) | Custom subdomain that is used to redirect email recipients to the Amazon SES event tracking domain. | `string` | `""` | no |
| <a name="input_reputation_metrics_enabled"></a> [reputation\_metrics\_enabled](#input\_reputation\_metrics\_enabled) | Whether or not Amazon SES publishes reputation metrics for the configuration set, such as bounce and complaint rates, to Amazon CloudWatch. The default value is false | `bool` | `false` | no |
| <a name="input_sending_enabled"></a> [sending\_enabled](#input\_sending\_enabled) | Whether email sending is enabled or disabled for the configuration set. The default value is true. | `bool` | `true` | no |
| <a name="input_ses_configuration_set_name"></a> [ses\_configuration\_set\_name](#input\_ses\_configuration\_set\_name) | Name of the configuration set. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_last_fresh_start"></a> [last\_fresh\_start](#output\_last\_fresh\_start) | Date and time at which the reputation metrics for the configuration set were last reset. Resetting these metrics is known as a fresh start. |
| <a name="output_ses_configuration_set_all"></a> [ses\_configuration\_set\_all](#output\_ses\_configuration\_set\_all) | Map of SES configuration output |
| <a name="output_ses_configuration_set_arn"></a> [ses\_configuration\_set\_arn](#output\_ses\_configuration\_set\_arn) | SES configuration set ARN. |
| <a name="output_ses_configuration_set_id"></a> [ses\_configuration\_set\_id](#output\_ses\_configuration\_set\_id) | SES configuration set name. |

<!-- END_TF_DOCS -->