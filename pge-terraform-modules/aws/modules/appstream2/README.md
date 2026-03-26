<!-- BEGIN_TF_DOCS -->
# AWS appstream2.0 Image\_builder module.
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.24.0 |

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
| [aws_appstream_image_builder.image_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_image_builder) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appstream_agent_version"></a> [appstream\_agent\_version](#input\_appstream\_agent\_version) | The version of the AppStream 2.0 agent to use for this image builder. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description to display. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Human-readable friendly name for the AppStream image builder. | `string` | `null` | no |
| <a name="input_domain_join_info"></a> [domain\_join\_info](#input\_domain\_join\_info) | Configuration block for the name of the directory and organizational unit (OU) to use to join the image builder to a Microsoft Active Directory domain. | <pre>object({<br/>    directory_name                         = string<br/>    organizational_unit_distinguished_name = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | Type of interface endpoint. | `string` | `null` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of the IAM role to apply to the image builder. | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the image used to create the image builder. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use when launching the image builder. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the image builder. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Identifiers of the security groups for the image builder or image builder | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Identifiers of the subnets to which a network interface is attached from the image builder instance or image builder instance. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |
| <a name="input_vpce_id"></a> [vpce\_id](#input\_vpce\_id) | Identifier (ID) of the VPC in which the interface endpoint is used. Set to null for internet access. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appstream_image_all"></a> [appstream\_image\_all](#output\_appstream\_image\_all) | Map of appstream\_image attributes |
| <a name="output_appstream_image_arn"></a> [appstream\_image\_arn](#output\_appstream\_image\_arn) | ARN of the appstream image builder. |
| <a name="output_appstream_image_created_time"></a> [appstream\_image\_created\_time](#output\_appstream\_image\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the image builder was created. |
| <a name="output_appstream_image_id"></a> [appstream\_image\_id](#output\_appstream\_image\_id) | The name of the image builder. |
| <a name="output_appstream_image_state"></a> [appstream\_image\_state](#output\_appstream\_image\_state) | State of the image builder. Can be: PENDING, UPDATING\_AGENT, RUNNING, STOPPING, STOPPED, REBOOTING, SNAPSHOTTING, DELETING, FAILED, UPDATING, PENDING\_QUALIFICATION |

<!-- END_TF_DOCS -->