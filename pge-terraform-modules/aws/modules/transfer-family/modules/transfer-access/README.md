<!-- BEGIN_TF_DOCS -->
# AWS Transfer Family Access module. Granting access to AD Groups.
Terraform module which creates SAF2.0 aws\_transfer\_access in AWS.

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
| [aws_transfer_access.transfer_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_access) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | The SID of a group in the directory connected to the Transfer Server (e.g., S-1-1-12-1234567890-123456789-1234567890-1234). | `string` | n/a | yes |
| <a name="input_home_directory"></a> [home\_directory](#input\_home\_directory) | The landing directory (folder) for a user when they log in to the server using their SFTP client. It should begin with a /. The first item in the path is the name of the home bucket and the rest is the home directory. | `string` | `null` | no |
| <a name="input_home_directory_mappings"></a> [home\_directory\_mappings](#input\_home\_directory\_mappings) | entry:<br>   Represents an entry and a target.<br>target:<br>  Represents the map target. | <pre>object({<br>    entry  = string<br>    target = string<br>  })</pre> | <pre>{<br>  "entry": null,<br>  "target": null<br>}</pre> | no |
| <a name="input_home_directory_type"></a> [home\_directory\_type](#input\_home\_directory\_type) | The type of landing directory (folder) you mapped for your users' home directory. Valid values are PATH and LOGICAL. | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | An IAM JSON policy document that scopes down user access to portions of their Amazon S3 bucket. | `string` | `null` | no |
| <a name="input_posix_profile"></a> [posix\_profile](#input\_posix\_profile) | gid:<br>  The POSIX group ID used for all EFS operations by this user.<br>uid:<br>  The POSIX user ID used for all EFS operations by this user.<br>secondary\_gids:<br>  The secondary POSIX group IDs used for all EFS operations by this user. | <pre>object({<br>    gid            = number<br>    uid            = number<br>    secondary_gids = list(string)<br>  })</pre> | <pre>{<br>  "gid": null,<br>  "secondary_gids": null,<br>  "uid": null<br>}</pre> | no |
| <a name="input_role"></a> [role](#input\_role) | Amazon Resource Name (ARN) of an IAM role that allows the service to controls your user’s access to your Amazon S3 bucket. | `string` | n/a | yes |
| <a name="input_server_id"></a> [server\_id](#input\_server\_id) | The Server ID of the Transfer Server (e.g., s-12345678). | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transfer_access_all"></a> [transfer\_access\_all](#output\_transfer\_access\_all) | Map of transfer\_access object |
| <a name="output_transfer_access_id"></a> [transfer\_access\_id](#output\_transfer\_access\_id) | The ID of the resource. |

<!-- END_TF_DOCS -->