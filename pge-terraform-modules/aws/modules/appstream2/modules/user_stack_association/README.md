<!-- BEGIN_TF_DOCS -->
# AWS AppStream User Stack Association Module

✅ WHEN TO USE: For USERPOOL authentication with manual user-stack associations

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.0 |
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
| [aws_appstream_user_stack_association.user_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_user_stack_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | Authentication type for the user. | `string` | n/a | yes |
| <a name="input_send_email_notification"></a> [send\_email\_notification](#input\_send\_email\_notification) | Specifies whether a welcome email is sent to a user after the user is created in the user pool. | `bool` | `null` | no |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Name of the stack that is associated with the user. | `string` | n/a | yes |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | Email address of the user who is associated with the stack. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id_user_all"></a> [id\_user\_all](#output\_id\_user\_all) | Map of all id\_user attributes |
| <a name="output_id_user_stack"></a> [id\_user\_stack](#output\_id\_user\_stack) | Unique ID of the appstream User Stack association. |


<!-- END_TF_DOCS -->