<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM Maintenance-Window Run-Command Task resource in AWS

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
| [aws_ssm_maintenance_window_task.task_patches](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_maintenance_window_id"></a> [maintenance\_window\_id](#input\_maintenance\_window\_id) | The Id of the maintenance window to register the task with | `string` | n/a | yes |
| <a name="input_maintenance_window_task_arn"></a> [maintenance\_window\_task\_arn](#input\_maintenance\_window\_task\_arn) | The ARN of the task to execute | `string` | `"AWS-RunPatchBaseline"` | no |
| <a name="input_maintenance_window_task_cutoff_behavior"></a> [maintenance\_window\_task\_cutoff\_behavior](#input\_maintenance\_window\_task\_cutoff\_behavior) | The role that should be assumed when executing the task. If a role is not provided, Systems Manager uses your account's service-linked role. If no service-linked role for Systems Manager exists in your account, it is created for you | `string` | `null` | no |
| <a name="input_maintenance_window_task_description"></a> [maintenance\_window\_task\_description](#input\_maintenance\_window\_task\_description) | The description of the maintenance window task | `string` | `"This is a PGE maintenance window task"` | no |
| <a name="input_maintenance_window_task_max_concurrency"></a> [maintenance\_window\_task\_max\_concurrency](#input\_maintenance\_window\_task\_max\_concurrency) | The maximum number of targets this task can be run for in parallel | `number` | `null` | no |
| <a name="input_maintenance_window_task_max_errors"></a> [maintenance\_window\_task\_max\_errors](#input\_maintenance\_window\_task\_max\_errors) | The maximum number of errors allowed before this task stops being scheduled | `number` | `null` | no |
| <a name="input_maintenance_window_task_name"></a> [maintenance\_window\_task\_name](#input\_maintenance\_window\_task\_name) | The name of the maintenance window task | `string` | `"pge-maintenance-window-task"` | no |
| <a name="input_maintenance_window_task_priority"></a> [maintenance\_window\_task\_priority](#input\_maintenance\_window\_task\_priority) | The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel. Default 1 | `number` | `1` | no |
| <a name="input_maintenance_window_task_service_role_arn"></a> [maintenance\_window\_task\_service\_role\_arn](#input\_maintenance\_window\_task\_service\_role\_arn) | The role that should be assumed when executing the task. If a role is not provided, Systems Manager uses your account's service-linked role. If no service-linked role for Systems Manager exists in your account, it is created for you | `string` | `null` | no |
| <a name="input_maintenance_window_task_type"></a> [maintenance\_window\_task\_type](#input\_maintenance\_window\_task\_type) | The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN\_COMMAND or STEP\_FUNCTIONS | `string` | `"RUN_COMMAND"` | no |
| <a name="input_maintenance_windows_run_command"></a> [maintenance\_windows\_run\_command](#input\_maintenance\_windows\_run\_command) | The parameters for a RUN\_COMMAND task type. | `list(any)` | `[]` | no |
| <a name="input_maintenance_windows_targets"></a> [maintenance\_windows\_targets](#input\_maintenance\_windows\_targets) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | <pre>list(object({<br>    key : string<br>    values : list(string)<br>    }<br>    )<br>  )</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all"></a> [all](#output\_all) | The map of all output attributes |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the maintenance window task |
| <a name="output_id"></a> [id](#output\_id) | The ID of the maintenance window task |
| <a name="output_window_task_id"></a> [window\_task\_id](#output\_window\_task\_id) | The ID of the maintenance window task |


<!-- END_TF_DOCS -->