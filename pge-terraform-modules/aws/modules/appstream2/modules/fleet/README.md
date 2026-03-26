<!-- BEGIN_TF_DOCS -->
# AWS AppStream2.0 fleet module
Terraform module which creates fleet for AppStream2.0

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appstream_fleet.fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appstream_fleet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description to display. | `string` | `null` | no |
| <a name="input_desired_instances"></a> [desired\_instances](#input\_desired\_instances) | Desired number of streaming instances. | `number` | n/a | yes |
| <a name="input_disconnect_timeout_in_seconds"></a> [disconnect\_timeout\_in\_seconds](#input\_disconnect\_timeout\_in\_seconds) | Amount of time that a streaming session remains active after users disconnect. | `number` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Human-readable friendly name for the AppStream fleet. | `string` | `null` | no |
| <a name="input_domain_join_info"></a> [domain\_join\_info](#input\_domain\_join\_info) | Configuration block for the name of the directory and organizational unit (OU) to use to join the fleet to a Microsoft Active Directory domain. | <pre>object({<br>    directory_name                         = string<br>    organizational_unit_distinguished_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_fleet_type"></a> [fleet\_type](#input\_fleet\_type) | Fleet type. Valid values are: ON\_DEMAND, ALWAYS\_ON,ELASTIC | `string` | `"ON_DEMAND"` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of the IAM role to apply to the fleet. | `string` | `null` | no |
| <a name="input_idle_disconnect_timeout_in_seconds"></a> [idle\_disconnect\_timeout\_in\_seconds](#input\_idle\_disconnect\_timeout\_in\_seconds) | Amount of time that users can be idle (inactive) before they are disconnected from their streaming session and the disconnect\_timeout\_in\_seconds time interval begins. | `number` | `null` | no |
| <a name="input_image_arn"></a> [image\_arn](#input\_image\_arn) | ARN of the public, private, or shared image to use. | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the image used to create the fleet. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use when launching fleet instances. | `string` | n/a | yes |
| <a name="input_max_user_duration_in_seconds"></a> [max\_user\_duration\_in\_seconds](#input\_max\_user\_duration\_in\_seconds) | Maximum amount of time that a streaming session can remain active, in seconds. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the fleet. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Identifiers of the security groups for the fleet or image builder. | `list(string)` | n/a | yes |
| <a name="input_stream_view"></a> [stream\_view](#input\_stream\_view) | AppStream 2.0 view that is displayed to your users when they stream from the fleet. When APP is specified, only the windows of applications opened by users display. When DESKTOP is specified, the standard desktop that is provided by the operating system displays. If not specified, defaults to APP. | `string` | `"APP"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Identifiers of the subnets to which a network interface is attached from the fleet instance or image builder instance. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resources tags | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all"></a> [all](#output\_all) | Map of all appstream fleet attributes |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the appstream fleet. |
| <a name="output_compute_capacity"></a> [compute\_capacity](#output\_compute\_capacity) | Describes the capacity status for a fleet. |
| <a name="output_created_time"></a> [created\_time](#output\_created\_time) | Date and time, in UTC and extended RFC 3339 format, when the fleet was created. |
| <a name="output_id"></a> [id](#output\_id) | Unique identifier (ID) of the appstream fleet. |
| <a name="output_state"></a> [state](#output\_state) | State of the fleet. Can be STARTING, RUNNING, STOPPING or STOPPED |


<!-- END_TF_DOCS -->