<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM Maintenance-Window resource in AWS

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
| [aws_ssm_maintenance_window.window](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_maintenance_window_allow_unassociated_targets"></a> [maintenance\_window\_allow\_unassociated\_targets](#input\_maintenance\_window\_allow\_unassociated\_targets) | Whether targets must be registered with the Maintenance Window before tasks can be defined for those targets. | `bool` | `false` | no |
| <a name="input_maintenance_window_cutoff"></a> [maintenance\_window\_cutoff](#input\_maintenance\_window\_cutoff) | The number of hours before the end of the  Maintenance Window that Systems Manager stops scheduling new tasks for execution | `number` | `1` | no |
| <a name="input_maintenance_window_description"></a> [maintenance\_window\_description](#input\_maintenance\_window\_description) | A description for the maintenance window. | `string` | `"PGE targets maintenance window"` | no |
| <a name="input_maintenance_window_duration"></a> [maintenance\_window\_duration](#input\_maintenance\_window\_duration) | The duration of the  maintenence windows in hours | `number` | `3` | no |
| <a name="input_maintenance_window_enabled"></a> [maintenance\_window\_enabled](#input\_maintenance\_window\_enabled) | Whether the maintenance window is enabled. | `bool` | `true` | no |
| <a name="input_maintenance_window_end_date"></a> [maintenance\_window\_end\_date](#input\_maintenance\_window\_end\_date) | Timestamp in ISO-8601 extended format when to no longer run the maintenance window. | `string` | `null` | no |
| <a name="input_maintenance_window_name"></a> [maintenance\_window\_name](#input\_maintenance\_window\_name) | The name of the maintenance window | `string` | n/a | yes |
| <a name="input_maintenance_window_schedule"></a> [maintenance\_window\_schedule](#input\_maintenance\_window\_schedule) | The schedule of the  Maintenance Window in the form of a cron or rate expression | `string` | `"cron(15 10 ? * * *)"` | no |
| <a name="input_maintenance_window_schedule_timezone"></a> [maintenance\_window\_schedule\_timezone](#input\_maintenance\_window\_schedule\_timezone) | Timezone for schedule in Internet Assigned Numbers Authority (IANA) Time Zone Database format. For example: America/Los\_Angeles, etc/UTC, or Asia/Seoul. | `string` | `"US/Pacific"` | no |
| <a name="input_maintenance_window_start_date"></a> [maintenance\_window\_start\_date](#input\_maintenance\_window\_start\_date) | Timestamp in ISO-8601 extended format when to begin the maintenance window. | `string` | `null` | no |
| <a name="input_maintenance_window_target_description"></a> [maintenance\_window\_target\_description](#input\_maintenance\_window\_target\_description) | The description of the maintenance window target. | `string` | `"This is PGE maintenance window target"` | no |
| <a name="input_maintenance_window_target_name"></a> [maintenance\_window\_target\_name](#input\_maintenance\_window\_target\_name) | The name of the maintenance window target | `string` | `"EC2Instance"` | no |
| <a name="input_maintenance_window_target_owner_information"></a> [maintenance\_window\_target\_owner\_information](#input\_maintenance\_window\_target\_owner\_information) | User-provided value that will be included in any CloudWatch events raised while running tasks for these targets in this Maintenance Window. | `string` | `null` | no |
| <a name="input_maintenance_window_target_resource_type"></a> [maintenance\_window\_target\_resource\_type](#input\_maintenance\_window\_target\_resource\_type) | The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE\_GROUP | `string` | `null` | no |
| <a name="input_maintenance_windows_targets"></a> [maintenance\_windows\_targets](#input\_maintenance\_windows\_targets) | The map of tags for targetting which EC2 instances will be scaned | <pre>list(object({<br>    key : string<br>    values : list(string)<br>    }<br>    )<br>  )</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_window_id"></a> [window\_id](#output\_window\_id) | SSM Patch Manager patch group ID |
| <a name="output_window_target_id"></a> [window\_target\_id](#output\_window\_target\_id) | SSM Patch Manager patch group ID |


<!-- END_TF_DOCS -->