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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| <a name="module_ecs_container_definition"></a> [ecs\_container\_definition](#module\_ecs\_container\_definition) | ../ecs_container_definition | n/a |
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.ecs_cluster_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_secretsmanager_secret.wiz_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Enter the name of the cluster | `string` | n/a | yes |
| <a name="input_ecs_cluster_capacity_base"></a> [ecs\_cluster\_capacity\_base](#input\_ecs\_cluster\_capacity\_base) | The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined. | `number` | `0` | no |
| <a name="input_ecs_cluster_capacity_providers"></a> [ecs\_cluster\_capacity\_providers](#input\_ecs\_cluster\_capacity\_providers) | Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | `[]` | no |
| <a name="input_ecs_cluster_capacity_weight"></a> [ecs\_cluster\_capacity\_weight](#input\_ecs\_cluster\_capacity\_weight) | The relative percentage of the total number of launched tasks that should use the specified capacity provider. | `number` | `0` | no |
| <a name="input_ecs_default_cluster_capacity_provider"></a> [ecs\_default\_cluster\_capacity\_provider](#input\_ecs\_default\_cluster\_capacity\_provider) | The short name of the capacity provider. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting logs | `string` | `null` | no |
| <a name="input_log_cloud_watch_log_group_name"></a> [log\_cloud\_watch\_log\_group\_name](#input\_log\_cloud\_watch\_log\_group\_name) | The name of the CloudWatch log group to send logs to. | `string` | n/a | yes |
| <a name="input_log_execute_command"></a> [log\_execute\_command](#input\_log\_execute\_command) | The log setting to use for redirecting logs for your execute command results. Valid values are NONE, DEFAULT, and OVERRIDE. | `string` | `"OVERRIDE"` | no |
| <a name="input_log_s3_bucket_name"></a> [log\_s3\_bucket\_name](#input\_log\_s3\_bucket\_name) | The name of the S3 bucket to send logs to. | `string` | `null` | no |
| <a name="input_log_s3_key_prefix"></a> [log\_s3\_key\_prefix](#input\_log\_s3\_key\_prefix) | An optional folder in the S3 bucket to place logs in. | `string` | `null` | no |
| <a name="input_setting_value"></a> [setting\_value](#input\_setting\_value) | The value to assign to the setting. Value values are enabled and disabled. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |
| <a name="input_wiz_container_cpu"></a> [wiz\_container\_cpu](#input\_wiz\_container\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container\_cpu of all containers in a task will need to be lower than the task-level cpu value | `number` | `"0"` | no |
| <a name="input_wiz_container_image"></a> [wiz\_container\_image](#input\_wiz\_container\_image) | The image used to start the container. Images in the Docker Hub registry available by default | `string` | `"wizio.azurecr.io/sensor-serverless:v1"` | no |
| <a name="input_wiz_container_memory_reservation"></a> [wiz\_container\_memory\_reservation](#input\_wiz\_container\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `"50"` | no |
| <a name="input_wiz_container_name"></a> [wiz\_container\_name](#input\_wiz\_container\_name) | The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, \_ allowed) | `string` | `"wiz-sensor"` | no |
| <a name="input_wiz_environment"></a> [wiz\_environment](#input\_wiz\_environment) | The environment variables to pass to the container. This is a list of maps. map\_environment overrides environment | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_wiz_essential"></a> [wiz\_essential](#input\_wiz\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `false` | no |
| <a name="input_wiz_linux_parameters"></a> [wiz\_linux\_parameters](#input\_wiz\_linux\_parameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html | <pre>object({<br>    capabilities = object({<br>      add  = list(string)<br>      drop = list(string)<br>    })<br>    devices = list(object({<br>      containerPath = string<br>      hostPath      = string<br>      permissions   = list(string)<br>    }))<br>    initProcessEnabled = bool<br>    maxSwap            = number<br>    sharedMemorySize   = number<br>    swappiness         = number<br>    tmpfs = list(object({<br>      containerPath = string<br>      mountOptions  = list(string)<br>      size          = number<br>    }))<br>  })</pre> | <pre>{<br>  "capabilities": {<br>    "add": [],<br>    "drop": []<br>  },<br>  "devices": [],<br>  "initProcessEnabled": false,<br>  "maxSwap": null,<br>  "sharedMemorySize": null,<br>  "swappiness": null,<br>  "tmpfs": []<br>}</pre> | no |
| <a name="input_wiz_logDriver"></a> [wiz\_logDriver](#input\_wiz\_logDriver) | identify the logDriver | `string` | `"awslogs"` | no |
| <a name="input_wiz_mount_points"></a> [wiz\_mount\_points](#input\_wiz\_mount\_points) | Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly` | <pre>list(object({<br>    containerPath = string<br>    sourceVolume  = string<br>    readOnly      = bool<br>  }))</pre> | `[]` | no |
| <a name="input_wiz_port_mappings"></a> [wiz\_port\_mappings](#input\_wiz\_port\_mappings) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br>    containerPort = number<br>    hostPort      = number<br>    protocol      = string<br>  }))</pre> | `[]` | no |
| <a name="input_wiz_privileged"></a> [wiz\_privileged](#input\_wiz\_privileged) | When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type. | `bool` | `false` | no |
| <a name="input_wiz_readonly_root_filesystem"></a> [wiz\_readonly\_root\_filesystem](#input\_wiz\_readonly\_root\_filesystem) | Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `true` | no |
| <a name="input_wiz_registry_credentials"></a> [wiz\_registry\_credentials](#input\_wiz\_registry\_credentials) | The name given in the parameter store for the wiz\_registry\_credentials | `string` | `"wiz_registry_credentials"` | no |
| <a name="input_wiz_volumes"></a> [wiz\_volumes](#input\_wiz\_volumes) | A set of volumes blocks that containers in your task may use. | <pre>list(object({<br>    host_path = string<br>    name      = string<br>  }))</pre> | `[]` | no |
| <a name="input_wiz_volumes_from"></a> [wiz\_volumes\_from](#input\_wiz\_volumes\_from) | A list of VolumesFrom maps which contain "sourceContainer" (name of the container that has the volumes to mount) and "readOnly" (whether the container can write to the volume) | <pre>list(object({<br>    sourceContainer = string<br>    readOnly        = bool<br>  }))</pre> | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_all"></a> [ecs\_cluster\_all](#output\_ecs\_cluster\_all) | Map of ECS cluster object |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS Cluster. |
| <a name="output_ecs_cluster_capacity_providers_id"></a> [ecs\_cluster\_capacity\_providers\_id](#output\_ecs\_cluster\_capacity\_providers\_id) | Same as cluster\_name. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS Cluster. |
| <a name="output_ecs_cluster_tags_all"></a> [ecs\_cluster\_tags\_all](#output\_ecs\_cluster\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_wiz_container_definition_json"></a> [wiz\_container\_definition\_json](#output\_wiz\_container\_definition\_json) | n/a |
| <a name="output_wiz_container_name"></a> [wiz\_container\_name](#output\_wiz\_container\_name) | The name of the wiz container from the ecs\_container\_definition module |

<!-- END_TF_DOCS -->