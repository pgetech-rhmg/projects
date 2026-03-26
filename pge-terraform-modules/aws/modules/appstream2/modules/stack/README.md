<!-- BEGIN_TF_DOCS -->
# AWS appstream stack module.
Terraform module which creates SAF2.0 Appstream2.0 in AWS.

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
| [aws_appstream_stack.stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_stack) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_endpoints"></a> [access\_endpoints](#input\_access\_endpoints) | Set of configuration blocks defining the interface VPC endpoints. Users of the stack can connect to AppStream 2.0 only through the specified endpoints. | `list(any)` | `[]` | no |
| <a name="input_application_settings"></a> [application\_settings](#input\_application\_settings) | Settings for application settings persistence. | `list(any)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the AppStream stack. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Stack name to display. | `string` | `null` | no |
| <a name="input_embed_host_domains"></a> [embed\_host\_domains](#input\_embed\_host\_domains) | Domains where AppStream 2.0 streaming sessions can be embedded in an iframe. You must approve the domains that you want to host embedded AppStream 2.0 streaming sessions. | `list(string)` | `null` | no |
| <a name="input_feedback_url"></a> [feedback\_url](#input\_feedback\_url) | URL that users are redirected to after they click the Send Feedback link. If no URL is specified, no Send Feedback link is displayed. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the AppStream stack. | `string` | n/a | yes |
| <a name="input_redirect_url"></a> [redirect\_url](#input\_redirect\_url) | URL that users are redirected to after their streaming session ends. | `string` | `null` | no |
| <a name="input_storage_connectors"></a> [storage\_connectors](#input\_storage\_connectors) | Type of storage connector. | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |
| <a name="input_user_settings"></a> [user\_settings](#input\_user\_settings) | Configuration block for the actions that are enabled or disabled for users during their streaming sessions. | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appstream_stack_all"></a> [appstream\_stack\_all](#output\_appstream\_stack\_all) | map of all appstream\_stack attributes |
| <a name="output_appstream_stack_arn"></a> [appstream\_stack\_arn](#output\_appstream\_stack\_arn) | ARN of the appstream stack. |
| <a name="output_appstream_stack_created_time"></a> [appstream\_stack\_created\_time](#output\_appstream\_stack\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the stack was created. |
| <a name="output_appstream_stack_id"></a> [appstream\_stack\_id](#output\_appstream\_stack\_id) | Unique ID of the appstream stack. |


<!-- END_TF_DOCS -->