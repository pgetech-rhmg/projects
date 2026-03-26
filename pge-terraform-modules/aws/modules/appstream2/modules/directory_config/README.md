<!-- BEGIN_TF_DOCS -->
# AWS AppStream Directory Config Module

✅ WHEN TO USE: For runtime domain joining with base images

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
| [aws_appstream_directory_config.directory_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_directory_config) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | User name of the account. This account must have the following privileges: create computer objects, join computers to the domain, and change/reset the password on descendant computer objects for the organizational units specified. | `string` | n/a | yes |
| <a name="input_account_password"></a> [account\_password](#input\_account\_password) | Password for the account. | `string` | n/a | yes |
| <a name="input_directory_name"></a> [directory\_name](#input\_directory\_name) | Fully qualified name of the directory. | `string` | n/a | yes |
| <a name="input_organizational_unit_names"></a> [organizational\_unit\_names](#input\_organizational\_unit\_names) | Distinguished names of the organizational units for computer accounts. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appstream_all"></a> [appstream\_all](#output\_appstream\_all) | Map of all appstream\_directory attributes |
| <a name="output_appstream_created_time"></a> [appstream\_created\_time](#output\_appstream\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the directory config was created. |
| <a name="output_appstream_directory_config"></a> [appstream\_directory\_config](#output\_appstream\_directory\_config) | Unique identifier (ID) of the appstream directory config. |


<!-- END_TF_DOCS -->