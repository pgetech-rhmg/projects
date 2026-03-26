<!-- BEGIN_TF_DOCS -->
# PG&E Mrad Pinpoint Module
 MRAD specific Pinpoint module to provision SAF compliant resources

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
| <a name="module_mrad-common"></a> [mrad-common](#module\_mrad-common) | app.terraform.io/pgetech/mrad-common/aws | ~> 1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_pinpoint_apns_channel.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pinpoint_apns_channel) | resource |
| [aws_pinpoint_apns_sandbox_channel.sandbox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pinpoint_apns_sandbox_channel) | resource |
| [aws_pinpoint_app.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pinpoint_app) | resource |
| [aws_pinpoint_email_channel.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pinpoint_email_channel) | resource |
| [aws_pinpoint_sms_channel.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/pinpoint_sms_channel) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number - predefined in TFC | `string` | n/a | yes |
| <a name="input_apns_bundle_id"></a> [apns\_bundle\_id](#input\_apns\_bundle\_id) | APNS Bundle ID | `string` | `""` | no |
| <a name="input_apns_team_id"></a> [apns\_team\_id](#input\_apns\_team\_id) | APNS Team ID | `string` | `""` | no |
| <a name="input_apns_token_key"></a> [apns\_token\_key](#input\_apns\_token\_key) | APNS Token Key | `string` | `""` | no |
| <a name="input_apns_token_key_id"></a> [apns\_token\_key\_id](#input\_apns\_token\_key\_id) | APNS Token Key ID | `string` | `""` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the Pinpoint application | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume - predefined in TFC | `string` | n/a | yes |
| <a name="input_email_from"></a> [email\_from](#input\_email\_from) | Email address used as sender | `string` | `""` | no |
| <a name="input_email_identity"></a> [email\_identity](#input\_email\_identity) | SES verified identity for email sending | `string` | `""` | no |
| <a name="input_enable_email"></a> [enable\_email](#input\_enable\_email) | Enable Email channel | `bool` | `false` | no |
| <a name="input_enable_push"></a> [enable\_push](#input\_enable\_push) | Enable Push Notifications | `bool` | `false` | no |
| <a name="input_enable_sms"></a> [enable\_sms](#input\_enable\_sms) | Enable SMS channel | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pinpoint_app_id"></a> [pinpoint\_app\_id](#output\_pinpoint\_app\_id) | The ID of the Pinpoint application |


<!-- END_TF_DOCS -->