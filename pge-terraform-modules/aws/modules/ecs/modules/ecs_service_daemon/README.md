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
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone_rebalancing"></a> [availability\_zone\_rebalancing](#input\_availability\_zone\_rebalancing) | Automatically redistributes tasks within a service across Availability Zones Valid values: ENABLED, DISABLED. Default: DISABLED. | `string` | `"DISABLED"` | no |
| <a name="input_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#input\_capacity\_provider\_strategy) | Capacity provider strategies to use for the service. Can be one or more. These can be updated without destroying and recreating the service only if force\_new\_deployment = true and not changing from 0 capacity\_provider\_strategy blocks to greater than 0, or vice versa. | `map(string)` | `null` | no |
| <a name="input_deployment_circuit_breaker"></a> [deployment\_circuit\_breaker](#input\_deployment\_circuit\_breaker) | Configuration block for deployment circuit breaker. | `map(string)` | `null` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the DAEMON scheduling strategy. | `number` | `null` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment. | `number` | `null` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS, EXTERNAL. Default: ECS. | `string` | `"ECS"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running. Defaults to 0. | `number` | `0` | no |
| <a name="input_ecs_service_cluster_id"></a> [ecs\_service\_cluster\_id](#input\_ecs\_service\_cluster\_id) | ARN of an ECS cluster. | `string` | n/a | yes |
| <a name="input_ecs_service_launch_type"></a> [ecs\_service\_launch\_type](#input\_ecs\_service\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | `"EC2"` | no |
| <a name="input_ecs_service_placement_constraints"></a> [ecs\_service\_placement\_constraints](#input\_ecs\_service\_placement\_constraints) | Rules that are taken into consideration during task placement. Updates to this configuration will take effect next task deployment unless force\_new\_deployment is enabled. Maximum number of placement\_constraints is 10. | `map(string)` | `null` | no |
| <a name="input_ecs_service_task_definition_arn"></a> [ecs\_service\_task\_definition\_arn](#input\_ecs\_service\_task\_definition\_arn) | Family and revision (family:revision) or full ARN of the task definition that you want to run in your service. Required unless using the EXTERNAL deployment controller. If a revision is not specified, the latest ACTIVE revision is used. | `string` | n/a | yes |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Specifies whether to enable Amazon ECS managed tags for the tasks within the service. | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Specifies whether to enable Amazon ECS Exec for the tasks within the service. | `bool` | `false` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g., myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered\_placement\_strategy and placement\_constraints updates. | `bool` | `false` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers. | `number` | `null` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the awsvpc network mode. If using awsvpc network mode, do not specify this role. If your account has already created the Amazon ECS service-linked role, that role is used by default for your service unless you specify a role here. | `string` | `null` | no |
| <a name="input_ordered_placement_strategy"></a> [ordered\_placement\_strategy](#input\_ordered\_placement\_strategy) | Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. Updates to this configuration will take effect next task deployment unless force\_new\_deployment is enabled. The maximum number of ordered\_placement\_strategy blocks is 5. | `map(string)` | `null` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION. | `string` | `null` | no |
| <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy) | Scheduling strategy to use for the service. The valid values are REPLICA and DAEMON. Defaults to REPLICA. | `string` | `"REPLICA"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Provide name for the service | `string` | n/a | yes |
| <a name="input_service_platform_version"></a> [service\_platform\_version](#input\_service\_platform\_version) | Platform version on which to run your service. Only applicable for launch\_type set to FARGATE. Defaults to LATEST. | `string` | `"LATEST"` | no |
| <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries) | Service discovery registries for the service. The maximum number of service\_registries blocks is 1. | `map(string)` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets associated with the task or service. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | If true, Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing. Default false. | `bool` | `false` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_service_all"></a> [ecs\_service\_all](#output\_ecs\_service\_all) | Map of ECS service object |
| <a name="output_ecs_service_cluster_daemon"></a> [ecs\_service\_cluster\_daemon](#output\_ecs\_service\_cluster\_daemon) | Amazon Resource Name (ARN) of cluster which the service runs on. |
| <a name="output_ecs_service_desired_count_daemon"></a> [ecs\_service\_desired\_count\_daemon](#output\_ecs\_service\_desired\_count\_daemon) | Number of instances of the task definition. |
| <a name="output_ecs_service_iam_role_daemon"></a> [ecs\_service\_iam\_role\_daemon](#output\_ecs\_service\_iam\_role\_daemon) | ARN of IAM role used for ELB. |
| <a name="output_ecs_service_id_daemon"></a> [ecs\_service\_id\_daemon](#output\_ecs\_service\_id\_daemon) | ARN that identifies the service. |
| <a name="output_ecs_service_name_daemon"></a> [ecs\_service\_name\_daemon](#output\_ecs\_service\_name\_daemon) | Name of the service. |
| <a name="output_ecs_service_tags_all_daemon"></a> [ecs\_service\_tags\_all\_daemon](#output\_ecs\_service\_tags\_all\_daemon) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->