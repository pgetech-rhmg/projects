<!-- BEGIN_TF_DOCS -->
# AWS AppStream User Module

✅ WHEN TO USE: For USERPOOL authentication with AppStream-managed users

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
| [aws_appstream_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | Authentication type for the user. You must specify USERPOOL. | `string` | n/a | yes |
| <a name="input_enabled_user"></a> [enabled\_user](#input\_enabled\_user) | Specifies whether the user in the user pool is enabled. | `bool` | `true` | no |
| <a name="input_first_name"></a> [first\_name](#input\_first\_name) | First name, or given name, of the user. | `string` | `null` | no |
| <a name="input_last_name"></a> [last\_name](#input\_last\_name) | Last name, or surname, of the user. | `string` | `null` | no |
| <a name="input_send_email_notification"></a> [send\_email\_notification](#input\_send\_email\_notification) | Send an email notification. | `bool` | `false` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | Email address of the user. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appstream_user_all"></a> [appstream\_user\_all](#output\_appstream\_user\_all) | map of all appstream user attributes |
| <a name="output_appstream_user_arn"></a> [appstream\_user\_arn](#output\_appstream\_user\_arn) | ARN of the appstream user. |
| <a name="output_appstream_user_created_time"></a> [appstream\_user\_created\_time](#output\_appstream\_user\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the user was created. |
| <a name="output_appstream_user_id"></a> [appstream\_user\_id](#output\_appstream\_user\_id) | Unique ID of the appstream user. |


<!-- END_TF_DOCS -->