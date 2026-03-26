<!-- BEGIN_TF_DOCS -->
# AWS SSM module
Terraform module which creates SAF2.0 SSM Maintenance Window resource in AWS

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
| <a name="module_aws_sns_iam_role"></a> [aws\_sns\_iam\_role](#module\_aws\_sns\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_maintenance-window"></a> [maintenance-window](#module\_maintenance-window) | ../../modules/maintenance-window | n/a |
| <a name="module_maintenance-window-tasks-automation"></a> [maintenance-window-tasks-automation](#module\_maintenance-window-tasks-automation) | ../../modules/maintenance-window-tasks-automation | n/a |
| <a name="module_maintenance-window-tasks-lambda"></a> [maintenance-window-tasks-lambda](#module\_maintenance-window-tasks-lambda) | ../../modules/maintenance-window-tasks-lambda | n/a |
| <a name="module_maintenance-window-tasks-run-command"></a> [maintenance-window-tasks-run-command](#module\_maintenance-window-tasks-run-command) | ../../modules/maintenance-window-tasks-run-command | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_object.object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_iam_policy_document.inline_policy_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order number for the asset. | `string` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory. | `string` | n/a | yes |
| <a name="input_automation_maintenance_window_task_arn"></a> [automation\_maintenance\_window\_task\_arn](#input\_automation\_maintenance\_window\_task\_arn) | The ARN of the task to execute. | `string` | n/a | yes |
| <a name="input_automation_maintenance_window_task_max_concurrency"></a> [automation\_maintenance\_window\_task\_max\_concurrency](#input\_automation\_maintenance\_window\_task\_max\_concurrency) | The maximum number of targets this task can be run for in parallel | `number` | n/a | yes |
| <a name="input_automation_maintenance_window_task_max_errors"></a> [automation\_maintenance\_window\_task\_max\_errors](#input\_automation\_maintenance\_window\_task\_max\_errors) | The maximum number of errors allowed before this task stops being scheduled | `number` | n/a | yes |
| <a name="input_automation_maintenance_window_task_name"></a> [automation\_maintenance\_window\_task\_name](#input\_automation\_maintenance\_window\_task\_name) | The name of the maintenance window task | `string` | n/a | yes |
| <a name="input_automation_maintenance_window_task_priority"></a> [automation\_maintenance\_window\_task\_priority](#input\_automation\_maintenance\_window\_task\_priority) | The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel. Default 1 | `number` | n/a | yes |
| <a name="input_automation_maintenance_window_task_type"></a> [automation\_maintenance\_window\_task\_type](#input\_automation\_maintenance\_window\_task\_type) | The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN\_COMMAND or STEP\_FUNCTIONS | `string` | n/a | yes |
| <a name="input_automation_task_invocation_automation_parameters"></a> [automation\_task\_invocation\_automation\_parameters](#input\_automation\_task\_invocation\_automation\_parameters) | The parameters for an AUTOMATION task type. | `list(any)` | n/a | yes |
| <a name="input_automation_task_target_key"></a> [automation\_task\_target\_key](#input\_automation\_task\_target\_key) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume. | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | s3 bucket name | `string` | n/a | yes |
| <a name="input_cloudwatch_output_enabled"></a> [cloudwatch\_output\_enabled](#input\_cloudwatch\_output\_enabled) | Enables Systems Manager to send command output to CloudWatch Logs. | `bool` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | The KMS key to encrypt data in store. | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_lambda_maintenance_window_task_arn"></a> [lambda\_maintenance\_window\_task\_arn](#input\_lambda\_maintenance\_window\_task\_arn) | The ARN of the task to execute. | `string` | n/a | yes |
| <a name="input_lambda_maintenance_window_task_name"></a> [lambda\_maintenance\_window\_task\_name](#input\_lambda\_maintenance\_window\_task\_name) | The name of the maintenance window task | `string` | n/a | yes |
| <a name="input_lambda_maintenance_window_task_priority"></a> [lambda\_maintenance\_window\_task\_priority](#input\_lambda\_maintenance\_window\_task\_priority) | The priority of the task in the Maintenance Window, the lower the number the higher the priority. Tasks in a Maintenance Window are scheduled in priority order with tasks that have the same priority scheduled in parallel. Default 1 | `number` | n/a | yes |
| <a name="input_lambda_maintenance_window_task_type"></a> [lambda\_maintenance\_window\_task\_type](#input\_lambda\_maintenance\_window\_task\_type) | The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN\_COMMAND or STEP\_FUNCTIONS | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_output_s3_key_prefix"></a> [output\_s3\_key\_prefix](#input\_output\_s3\_key\_prefix) | The Amazon S3 bucket subfolder | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application | `string` | n/a | yes |
| <a name="input_scan_maintenance_window_cutoff"></a> [scan\_maintenance\_window\_cutoff](#input\_scan\_maintenance\_window\_cutoff) | The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution | `number` | n/a | yes |
| <a name="input_scan_maintenance_window_duration"></a> [scan\_maintenance\_window\_duration](#input\_scan\_maintenance\_window\_duration) | The duration of the maintenance windows in hours | `number` | n/a | yes |
| <a name="input_scan_maintenance_window_name"></a> [scan\_maintenance\_window\_name](#input\_scan\_maintenance\_window\_name) | The name of the maintenance window. | `string` | n/a | yes |
| <a name="input_scan_maintenance_window_schedule"></a> [scan\_maintenance\_window\_schedule](#input\_scan\_maintenance\_window\_schedule) | The schedule of the Maintenance Window in the form of a cron or rate expression | `string` | n/a | yes |
| <a name="input_scan_maintenance_window_target_resource_type"></a> [scan\_maintenance\_window\_target\_resource\_type](#input\_scan\_maintenance\_window\_target\_resource\_type) | The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE\_GROUP | `string` | n/a | yes |
| <a name="input_scan_maintenance_window_task_arn"></a> [scan\_maintenance\_window\_task\_arn](#input\_scan\_maintenance\_window\_task\_arn) | The ARN of the task to execute. | `string` | n/a | yes |
| <a name="input_scan_maintenance_window_task_max_concurrency"></a> [scan\_maintenance\_window\_task\_max\_concurrency](#input\_scan\_maintenance\_window\_task\_max\_concurrency) | The maximum number of targets this task can be run for in parallel | `number` | n/a | yes |
| <a name="input_scan_maintenance_window_task_max_errors"></a> [scan\_maintenance\_window\_task\_max\_errors](#input\_scan\_maintenance\_window\_task\_max\_errors) | The maximum number of errors allowed before this task stops being scheduled | `number` | n/a | yes |
| <a name="input_scan_maintenance_window_task_name"></a> [scan\_maintenance\_window\_task\_name](#input\_scan\_maintenance\_window\_task\_name) | The name of the maintenance window task | `string` | n/a | yes |
| <a name="input_scan_maintenance_window_task_type"></a> [scan\_maintenance\_window\_task\_type](#input\_scan\_maintenance\_window\_task\_type) | The type of task being registered. Valid values: AUTOMATION, LAMBDA, RUN\_COMMAND or STEP\_FUNCTIONS | `string` | n/a | yes |
| <a name="input_scan_maintenance_windows_targets"></a> [scan\_maintenance\_windows\_targets](#input\_scan\_maintenance\_windows\_targets) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | <pre>list(object({<br>    key : string<br>    values : list(string)<br>    }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_scan_task_run_command_parameters"></a> [scan\_task\_run\_command\_parameters](#input\_scan\_task\_run\_command\_parameters) | The parameters for the RUN\_COMMAND task execution | <pre>list(object({<br>    name : string<br>    values : list(string)<br>    }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_scan_task_target_key"></a> [scan\_task\_target\_key](#input\_scan\_task\_target\_key) | The targets (either instances or window target ids). Instances are specified using Key=InstanceIds,Values=instanceid1,instanceid2. Window target ids are specified using Key=WindowTargetIds,Values=window target id1, window target id2. | `string` | n/a | yes |
| <a name="input_sns_iam_aws_service"></a> [sns\_iam\_aws\_service](#input\_sns\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_sns_iam_name"></a> [sns\_iam\_name](#input\_sns\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_maintenance_window_id"></a> [maintenance\_window\_id](#output\_maintenance\_window\_id) | SSM Patch Manager patch group ID |
| <a name="output_maintenance_window_target_id"></a> [maintenance\_window\_target\_id](#output\_maintenance\_window\_target\_id) | SSM Patch Manager patch group ID |
| <a name="output_maintenance_window_tasks_automation_arn"></a> [maintenance\_window\_tasks\_automation\_arn](#output\_maintenance\_window\_tasks\_automation\_arn) | The ARN of the maintenance window task |
| <a name="output_maintenance_window_tasks_automation_id"></a> [maintenance\_window\_tasks\_automation\_id](#output\_maintenance\_window\_tasks\_automation\_id) | The ID of the maintenance window task |
| <a name="output_maintenance_window_tasks_automation_window_task_id"></a> [maintenance\_window\_tasks\_automation\_window\_task\_id](#output\_maintenance\_window\_tasks\_automation\_window\_task\_id) | The ID of the maintenance window task |
| <a name="output_maintenance_window_tasks_lambda_arn"></a> [maintenance\_window\_tasks\_lambda\_arn](#output\_maintenance\_window\_tasks\_lambda\_arn) | The ARN of the maintenance window task |
| <a name="output_maintenance_window_tasks_lambda_id"></a> [maintenance\_window\_tasks\_lambda\_id](#output\_maintenance\_window\_tasks\_lambda\_id) | The ID of the maintenance window task |
| <a name="output_maintenance_window_tasks_lambda_window_task_id"></a> [maintenance\_window\_tasks\_lambda\_window\_task\_id](#output\_maintenance\_window\_tasks\_lambda\_window\_task\_id) | The ID of the maintenance window task |
| <a name="output_maintenance_window_tasks_run_command_arn"></a> [maintenance\_window\_tasks\_run\_command\_arn](#output\_maintenance\_window\_tasks\_run\_command\_arn) | The ARN of the maintenance window task |
| <a name="output_maintenance_window_tasks_run_command_id"></a> [maintenance\_window\_tasks\_run\_command\_id](#output\_maintenance\_window\_tasks\_run\_command\_id) | The ID of the maintenance window task |
| <a name="output_maintenance_window_tasks_run_command_window_task_id"></a> [maintenance\_window\_tasks\_run\_command\_window\_task\_id](#output\_maintenance\_window\_tasks\_run\_command\_window\_task\_id) | The ID of the maintenance window task |


<!-- END_TF_DOCS -->