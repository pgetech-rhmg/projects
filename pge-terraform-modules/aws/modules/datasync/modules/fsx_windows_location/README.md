<!-- BEGIN_TF_DOCS -->
# AWS DataSync module
Terraform module which creates SAF2.0 DataSync FSx for Windows location resources in AWS.

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
| [aws_datasync_location_fsx_windows_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_fsx_windows_file_system) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the FSx Windows File System | `string` | `null` | no |
| <a name="input_filesystem_arn"></a> [filesystem\_arn](#input\_filesystem\_arn) | The ARN of the FSx Windows File System | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | The password to access the FSx Windows File System | `string` | n/a | yes |
| <a name="input_security_group_arns"></a> [security\_group\_arns](#input\_security\_group\_arns) | The ARNs of the security groups to associate with the FSx Windows File System. TF docs show this as optional, but it is required. | `list(string)` | n/a | yes |
| <a name="input_subdirectory"></a> [subdirectory](#input\_subdirectory) | The subdirectory in the FSx Windows File System | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | n/a | yes |
| <a name="input_user"></a> [user](#input\_user) | The username to access the FSx Windows File System | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the source FSx location |
| <a name="output_creation_time"></a> [creation\_time](#output\_creation\_time) | The creation time of the FSx Windows location |
| <a name="output_id"></a> [id](#output\_id) | The ID of the source FSx location |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags assigned to the FSx Windows location |
| <a name="output_uri"></a> [uri](#output\_uri) | The URI of the FSx location |


<!-- END_TF_DOCS -->