<!-- BEGIN_TF_DOCS -->
# AWS Glue Job module.
Terraform module which creates SAF2.0 Glue Job in AWS.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.92.0 |

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
| [aws_glue_job.glue_job](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_job_command"></a> [glue\_job\_command](#input\_glue\_job\_command) | The command of the job. Includes 'name', 'script\_location' and 'python\_version'. | `list(map(string))` | n/a | yes |
| <a name="input_glue_job_connections"></a> [glue\_job\_connections](#input\_glue\_job\_connections) | The list of connections used for this job. | `list(string)` | `[]` | no |
| <a name="input_glue_job_default_arguments"></a> [glue\_job\_default\_arguments](#input\_glue\_job\_default\_arguments) | The map of default arguments for this job. You can specify arguments here that your own job-execution script consumes, as well as arguments that AWS Glue itself consumes. For information about how to specify and consume your own Job arguments, see the Calling AWS Glue APIs in Python topic in the developer guide. For information about the key-value pairs that AWS Glue consumes to set up your job, see the Special Parameters Used by AWS Glue topic in the developer guide. | `map(string)` | `{}` | no |
| <a name="input_glue_job_description"></a> [glue\_job\_description](#input\_glue\_job\_description) | Description of the job. | `string` | `null` | no |
| <a name="input_glue_job_glue_version"></a> [glue\_job\_glue\_version](#input\_glue\_job\_glue\_version) | The version of glue to use, for example '1.0'. For information about available versions, see the AWS Glue Release Notes. | `string` | `null` | no |
| <a name="input_glue_job_max_capacity"></a> [glue\_job\_max\_capacity](#input\_glue\_job\_max\_capacity) | The maximum number of AWS Glue data processing units (DPUs) that can be allocated when this job runs. Required when pythonshell is set, accept either 0.0625 or 1.0. Use number\_of\_workers and worker\_type arguments instead with glue\_version 2.0 and above. | `number` | `null` | no |
| <a name="input_glue_job_max_retries"></a> [glue\_job\_max\_retries](#input\_glue\_job\_max\_retries) | The maximum number of times to retry this job if it fails. | `number` | `null` | no |
| <a name="input_glue_job_name"></a> [glue\_job\_name](#input\_glue\_job\_name) | The name you assign to this job. It must be unique in your account. | `string` | n/a | yes |
| <a name="input_glue_job_number_of_workers"></a> [glue\_job\_number\_of\_workers](#input\_glue\_job\_number\_of\_workers) | The number of workers of a defined workerType that are allocated when a job runs. | `number` | `null` | no |
| <a name="input_glue_job_role_arn"></a> [glue\_job\_role\_arn](#input\_glue\_job\_role\_arn) | The ARN of the IAM role associated with this job. | `string` | n/a | yes |
| <a name="input_glue_job_security_configuration"></a> [glue\_job\_security\_configuration](#input\_glue\_job\_security\_configuration) | The name of the Security Configuration to be associated with the job. | `string` | n/a | yes |
| <a name="input_glue_job_timeout"></a> [glue\_job\_timeout](#input\_glue\_job\_timeout) | The job timeout in minutes. The default is 2880 minutes (48 hours) for glueetl and pythonshell jobs, and null (unlimted) for gluestreaming jobs. | `number` | `2880` | no |
| <a name="input_glue_job_worker_type"></a> [glue\_job\_worker\_type](#input\_glue\_job\_worker\_type) | The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X. | `string` | `null` | no |
| <a name="input_max_concurrent_runs"></a> [max\_concurrent\_runs](#input\_max\_concurrent\_runs) | The maximum number of concurrent runs allowed for a job. The default is 1. | `number` | `1` | no |
| <a name="input_non_overridable_arguments"></a> [non\_overridable\_arguments](#input\_non\_overridable\_arguments) | Non-overridable arguments for this job, specified as name-value pairs. | `map(string)` | `{}` | no |
| <a name="input_notify_delay_after"></a> [notify\_delay\_after](#input\_notify\_delay\_after) | Notification property of the job. After a job run starts, the number of minutes to wait before sending a job run delay notification. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to populate on the created table. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_glue_job"></a> [aws\_glue\_job](#output\_aws\_glue\_job) | A map of aws\_glue\_job object. |
| <a name="output_glue_job_arn"></a> [glue\_job\_arn](#output\_glue\_job\_arn) | Amazon Resource Name (ARN) of Glue Job |
| <a name="output_glue_job_id"></a> [glue\_job\_id](#output\_glue\_job\_id) | Job name |
| <a name="output_glue_job_tags_all"></a> [glue\_job\_tags\_all](#output\_glue\_job\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->