<!-- BEGIN_TF_DOCS -->
# AWS ECS module
Terraform module which creates SAF2.0 ECS in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
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
| [aws_ecs_task_set.ecs_task_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id) | The short name or ARN of the cluster that hosts the service to create the task set in. | `string` | n/a | yes |
| <a name="input_ecs_service_id"></a> [ecs\_service\_id](#input\_ecs\_service\_id) | The short name or ARN of the ECS service. | `string` | n/a | yes |
| <a name="input_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#input\_ecs\_task\_definition\_arn) | The family and revision (family:revision) or full ARN of the task definition that you want to run in your service. | `string` | n/a | yes |
| <a name="input_ecs_task_launch_type"></a> [ecs\_task\_launch\_type](#input\_ecs\_task\_launch\_type) | The launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | `"EC2"` | no |
| <a name="input_ecs_task_set_capacity_provider_strategy"></a> [ecs\_task\_set\_capacity\_provider\_strategy](#input\_ecs\_task\_set\_capacity\_provider\_strategy) | The capacity provider strategy to use for the service. | `map(string)` | `null` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | The external ID associated with the task set. | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to allow deleting the task set without waiting for scaling down to 0. You can force a task set to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the tasks before deleting the task set. This bypasses that behavior and potentially leaves resources dangling. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |
| <a name="input_task_load_balancer"></a> [task\_load\_balancer](#input\_task\_load\_balancer) | Details on load balancers that are used with a task set. | `list(map(string))` | n/a | yes |
| <a name="input_task_security_groups"></a> [task\_security\_groups](#input\_task\_security\_groups) | The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. Maximum of 5. | `list(string)` | n/a | yes |
| <a name="input_task_service_registries"></a> [task\_service\_registries](#input\_task\_service\_registries) | The service discovery registries for the service. The maximum number of service\_registries blocks is 1. | `map(string)` | `null` | no |
| <a name="input_task_set_platform_version"></a> [task\_set\_platform\_version](#input\_task\_set\_platform\_version) | The platform version on which to run your service. Only applicable for launch\_type set to FARGATE. Defaults to LATEST. | `string` | `"LATEST"` | no |
| <a name="input_task_set_scale_unit"></a> [task\_set\_scale\_unit](#input\_task\_set\_scale\_unit) | The unit of measure for the scale value. Default: PERCENT. | `string` | `"PERCENT"` | no |
| <a name="input_task_set_scale_value"></a> [task\_set\_scale\_value](#input\_task\_set\_scale\_value) | The value, specified as a percent total of a service's desiredCount, to scale the task set. Defaults to 0 if not specified. Accepted values are numbers between 0.0 and 100.0. | `number` | `0` | no |
| <a name="input_task_subnets"></a> [task\_subnets](#input\_task\_subnets) | The subnets associated with the task or service. Maximum of 16. | `list(string)` | n/a | yes |
| <a name="input_task_target_group_arn"></a> [task\_target\_group\_arn](#input\_task\_target\_group\_arn) | The ARN of the Load Balancer target group to associate with the service. | `string` | n/a | yes |
| <a name="input_wait_until_stable"></a> [wait\_until\_stable](#input\_wait\_until\_stable) | Whether terraform should wait until the task set has reached STEADY\_STATE. | `bool` | `false` | no |
| <a name="input_wait_until_stable_timeout"></a> [wait\_until\_stable\_timeout](#input\_wait\_until\_stable\_timeout) | Wait timeout for task set to reach STEADY\_STATE. Valid time units include ns, us (or µs), ms, s, m, and h. Default 10m. | `string` | `"10m"` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_task_id"></a> [ecs\_task\_id](#output\_ecs\_task\_id) | The task\_set\_id, service and cluster separated by commas (,). |
| <a name="output_ecs_task_set_all"></a> [ecs\_task\_set\_all](#output\_ecs\_task\_set\_all) | Map of ECS task-set object |
| <a name="output_ecs_task_set_arn"></a> [ecs\_task\_set\_arn](#output\_ecs\_task\_set\_arn) | The Amazon Resource Name (ARN) that identifies the task set. |
| <a name="output_ecs_task_set_id"></a> [ecs\_task\_set\_id](#output\_ecs\_task\_set\_id) | The status of the task set. |
| <a name="output_ecs_task_set_stability_status"></a> [ecs\_task\_set\_stability\_status](#output\_ecs\_task\_set\_stability\_status) | The stability status. This indicates whether the task set has reached a steady state. |
| <a name="output_ecs_task_set_status"></a> [ecs\_task\_set\_status](#output\_ecs\_task\_set\_status) | The status of the task set. |
| <a name="output_ecs_task_set_tags_all"></a> [ecs\_task\_set\_tags\_all](#output\_ecs\_task\_set\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->