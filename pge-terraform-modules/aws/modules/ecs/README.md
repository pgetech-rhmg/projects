<!-- BEGIN_TF_DOCS -->
# AWS ECS module
Terraform module which creates SAF2.0 ECS in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

### Important Note: Wiz Runtime Sensor Integration with ECS Fargate

To integrate the Wiz Runtime Sensor with your ECS Fargate container, follow the instructions provided in the [Wiz documentation](https://docs.wiz.io/docs/serverless-sensor-install-embedded).

#### Steps:
1. Modify the `ENTRYPOINT` of your container definition to include the Wiz Runtime Sensor.
2. Adjust the `ENTRYPOINT` to start the Runtime Sensor, which will then invoke your original entry point.
3. Concatenate both the original `ENTRYPOINT` and `CMD` values to ensure the Sensor is activated and your application is protected during container startup.

#### Example:
```json
ENTRYPOINT ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "ORIGINAL-ENTRYPOINT", "ORIGINAL-ARG1", "ORIGINAL-ARG2"]

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

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
| <a name="module_ecs_container_definition"></a> [ecs\_container\_definition](#module\_ecs\_container\_definition) | ./modules/ecs_container_definition | n/a |
| <a name="module_ecs_service_daemon"></a> [ecs\_service\_daemon](#module\_ecs\_service\_daemon) | ./modules/ecs_service_daemon | n/a |
| <a name="module_ecs_task_definition_wiz"></a> [ecs\_task\_definition\_wiz](#module\_ecs\_task\_definition\_wiz) | ./modules/ecs_task_definition | n/a |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.ecs_cluster_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_secretsmanager_secret.wiz_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.wiz_secret_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.wiz_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Enter the name of the cluster. | `string` | n/a | yes |
| <a name="input_daemon_deployment_type"></a> [daemon\_deployment\_type](#input\_daemon\_deployment\_type) | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS, EXTERNAL. Default: ECS. | `string` | `"ECS"` | no |
| <a name="input_daemon_desired_count"></a> [daemon\_desired\_count](#input\_daemon\_desired\_count) | Number of instances of the task definition to place and keep running. Defaults to 0. | `number` | `2` | no |
| <a name="input_ecs_cluster_capacity_base"></a> [ecs\_cluster\_capacity\_base](#input\_ecs\_cluster\_capacity\_base) | The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined. | `number` | `0` | no |
| <a name="input_ecs_cluster_capacity_providers"></a> [ecs\_cluster\_capacity\_providers](#input\_ecs\_cluster\_capacity\_providers) | Set of names of one or more capacity providers to associate with the cluster. | `list(string)` | `[]` | no |
| <a name="input_ecs_cluster_capacity_weight"></a> [ecs\_cluster\_capacity\_weight](#input\_ecs\_cluster\_capacity\_weight) | The relative percentage of the total number of launched tasks that should use the specified capacity provider. | `number` | `0` | no |
| <a name="input_ecs_default_capacity_provider"></a> [ecs\_default\_capacity\_provider](#input\_ecs\_default\_capacity\_provider) | The short name of the capacity provider. | `string` | `null` | no |
| <a name="input_ecs_service_launch_type"></a> [ecs\_service\_launch\_type](#input\_ecs\_service\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | `"EC2"` | no |
| <a name="input_execution_role_arn_wiz"></a> [execution\_role\_arn\_wiz](#input\_execution\_role\_arn\_wiz) | ARN of the execution role for the ECS task | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting logs | `string` | `null` | no |
| <a name="input_log_cloud_watch_log_group_name"></a> [log\_cloud\_watch\_log\_group\_name](#input\_log\_cloud\_watch\_log\_group\_name) | The name of the CloudWatch log group to send logs to. | `string` | n/a | yes |
| <a name="input_log_execute_command"></a> [log\_execute\_command](#input\_log\_execute\_command) | The log setting to use for redirecting logs for your execute command results. Valid values are NONE, DEFAULT, and OVERRIDE. | `string` | `"OVERRIDE"` | no |
| <a name="input_log_s3_bucket_name"></a> [log\_s3\_bucket\_name](#input\_log\_s3\_bucket\_name) | The name of the S3 bucket to send logs to. | `string` | `null` | no |
| <a name="input_log_s3_key_prefix"></a> [log\_s3\_key\_prefix](#input\_log\_s3\_key\_prefix) | An optional folder in the S3 bucket to place logs in. | `string` | `null` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "EC2"<br>]</pre> | no |
| <a name="input_scheduling_strategy"></a> [scheduling\_strategy](#input\_scheduling\_strategy) | Scheduling strategy to use for the service. The valid values are REPLICA and DAEMON. Defaults to REPLICA. | `string` | `"DAEMON"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs for the ECS service | `list(string)` | n/a | yes |
| <a name="input_setting_value"></a> [setting\_value](#input\_setting\_value) | The value to assign to the setting. Value values are enabled and disabled. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnet IDs for the ECS service | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |
| <a name="input_task_role_arn_wiz"></a> [task\_role\_arn\_wiz](#input\_task\_role\_arn\_wiz) | ARN of the task role for the ECS task | `string` | n/a | yes |
| <a name="input_wiz_registry_credentials"></a> [wiz\_registry\_credentials](#input\_wiz\_registry\_credentials) | The name given in the parameter store for the wiz\_registry\_credentials | `string` | `"wiz_registry_credentials"` | no |
| <a name="input_wiz_secret_credential"></a> [wiz\_secret\_credential](#input\_wiz\_secret\_credential) | The name given in the parameter store for the golden wiz\_secret\_credential | `string` | `"shared-wiz-access"` | no |
| <a name="input_wiz_volumes"></a> [wiz\_volumes](#input\_wiz\_volumes) | A set of volumes blocks that containers in your task may use. | <pre>list(object({<br>    host_path = string<br>    name      = string<br>  }))</pre> | <pre>[<br>  {<br>    "host_path": "/opt/wiz/sensor/host-store",<br>    "name": "wiz-host-cache"<br>  },<br>  {<br>    "host_path": "/sys/kernel/debug",<br>    "name": "sys-kernel-debug"<br>  }<br>]</pre> | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_all"></a> [ecs\_cluster\_all](#output\_ecs\_cluster\_all) | Map of ECS cluster object |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS Cluster. |
| <a name="output_ecs_cluster_capacity_providers_id"></a> [ecs\_cluster\_capacity\_providers\_id](#output\_ecs\_cluster\_capacity\_providers\_id) | Same as cluster\_name. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS Cluster. |
| <a name="output_ecs_cluster_tags_all"></a> [ecs\_cluster\_tags\_all](#output\_ecs\_cluster\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->