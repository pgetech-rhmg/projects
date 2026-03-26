<!-- BEGIN_TF_DOCS -->
# AWS ECS with FARGATE usage example
Terraform module which creates SAF2.0 ECS with FARGATE in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

### Important Note: Wiz Runtime Sensor Integration with ECS Fargate

To integrate the Wiz Runtime Sensor with your ECS Fargate container, follow the instructions provided in the [Wiz documentation](https://docs.wiz.io/docs/serverless-sensor-install-embedded).

#### Steps:
1. Modify the `ENTRYPOINT` of your container definition to include the Wiz Runtime Sensor.
2. Adjust the `ENTRYPOINT` to start the Runtime Sensor, which will then invoke your original entry point.
3. Concatenate both the original `ENTRYPOINT` and `CMD` values to ensure the Sensor is activated and your application is protected during container startup.

#### Example:
ENTRYPOINT ["/opt/wiz/sensor/wiz-sensor", "daemon", "--", "ORIGINAL-ENTRYPOINT", "ORIGINAL-ARG1", "ORIGINAL-ARG2"]

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0  |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0  |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

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
| <a name="module_alb"></a> [alb](#module\_alb) | app.terraform.io/pgetech/alb/aws | 0.1.2 |
| <a name="module_container"></a> [container](#module\_container) | ../../modules/ecs_container_definition | n/a |
| <a name="module_ecs_account_setting_default"></a> [ecs\_account\_setting\_default](#module\_ecs\_account\_setting\_default) | ../../modules/ecs_account_setting_default | n/a |
| <a name="module_ecs_dashboard"></a> [ecs\_dashboard](#module\_ecs\_dashboard) | ../../modules/ecs_cloudwatch | n/a |
| <a name="module_ecs_fargate"></a> [ecs\_fargate](#module\_ecs\_fargate) | ../../modules/ecs_fargate | n/a |
| <a name="module_ecs_fargate_alarms"></a> [ecs\_fargate\_alarms](#module\_ecs\_fargate\_alarms) | ../../modules/ecs_fargate_alarms | n/a |
| <a name="module_ecs_iam_role"></a> [ecs\_iam\_role](#module\_ecs\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | ../../modules/ecs_service | n/a |
| <a name="module_ecs_task_definition"></a> [ecs\_task\_definition](#module\_ecs\_task\_definition) | ../../modules/ecs_task_definition | n/a |
| <a name="module_fluentbit_container"></a> [fluentbit\_container](#module\_fluentbit\_container) | ../../modules/ecs_container_definition | n/a |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_secretsmanager"></a> [secretsmanager](#module\_secretsmanager) | app.terraform.io/pgetech/secretsmanager/aws | 0.1.3 |
| <a name="module_secretsmanager_kms_key"></a> [secretsmanager\_kms\_key](#module\_secretsmanager\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_security_group_alb"></a> [security\_group\_alb](#module\_security\_group\_alb) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_ecs"></a> [security\_group\_ecs](#module\_security\_group\_ecs) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_ecs_service"></a> [security\_group\_ecs\_service](#module\_security\_group\_ecs\_service) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.jfrog_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.wiz_registry_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.wiz_secret_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.latest_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.wiz_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.alb_cidr1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.alb_cidr2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.alb_cidr3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_cidr1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_cidr2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_cidr3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [template_file.fargate_ecs](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.kms_policy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_HTTPCode_ELB_5XX_threshold"></a> [HTTPCode\_ELB\_5XX\_threshold](#input\_HTTPCode\_ELB\_5XX\_threshold) | Threshold for ELB 5XX alert | `string` | `"25"` | no |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_alb_sg_description"></a> [alb\_sg\_description](#input\_alb\_sg\_description) | vpc id for security group | `string` | `"Security group for example usage with ecs"` | no |
| <a name="input_availability_zone_rebalancing"></a> [availability\_zone\_rebalancing](#input\_availability\_zone\_rebalancing) | Automatically redistributes tasks within a service across Availability Zones Valid values: ENABLED, DISABLED. Default: DISABLED. | `string` | `"DISABLED"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the certificate to attach to the listener. | `list(map(string))` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Enter the name of the cluster | `string` | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | The command that is passed to the container | `list(string)` | `null` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container\_cpu of all containers in a task will need to be lower than the task-level cpu value | `number` | n/a | yes |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | The environment variables to pass to the container. This is a list of maps. map\_environment overrides environment | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The image used to start the container. Images in the Docker Hub registry available by default | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container\_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container\_memory of all containers in a task will need to be lower than the task memory value | `number` | n/a | yes |
| <a name="input_container_memory_reservation"></a> [container\_memory\_reservation](#input\_container\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `100` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, \_ allowed) | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | n/a | yes |
| <a name="input_cpu_alert_threshold"></a> [cpu\_alert\_threshold](#input\_cpu\_alert\_threshold) | Threshold which will trigger a alert when the cpu crosses | `string` | `"80"` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS, EXTERNAL. Default: ECS. | `string` | `"ECS"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running. Defaults to 0. | `number` | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | Docker registry from which the image will be deployed | `string` | `"JFROG"` | no |
| <a name="input_ecs_account_name"></a> [ecs\_account\_name](#input\_ecs\_account\_name) | Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights. | `string` | `"taskLongArnFormat"` | no |
| <a name="input_ecs_account_setting_value"></a> [ecs\_account\_setting\_value](#input\_ecs\_account\_setting\_value) | State of the setting. Valid values are enabled and disabled. | `string` | `"enabled"` | no |
| <a name="input_ecs_cluster_capacity_providers"></a> [ecs\_cluster\_capacity\_providers](#input\_ecs\_cluster\_capacity\_providers) | Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | <pre>[<br>  "FARGATE",<br>  "FARGATE_SPOT"<br>]</pre> | no |
| <a name="input_ecs_default_cluster_capacity_provider"></a> [ecs\_default\_cluster\_capacity\_provider](#input\_ecs\_default\_cluster\_capacity\_provider) | The short name of the capacity provider. | `string` | `"FARGATE"` | no |
| <a name="input_ecs_iam_aws_service"></a> [ecs\_iam\_aws\_service](#input\_ecs\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | <pre>[<br>  "ecs.amazonaws.com",<br>  "ecs-tasks.amazonaws.com"<br>]</pre> | no |
| <a name="input_ecs_iam_policy_arns"></a> [ecs\_iam\_policy\_arns](#input\_ecs\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",<br>  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"<br>]</pre> | no |
| <a name="input_ecs_service_launch_type"></a> [ecs\_service\_launch\_type](#input\_ecs\_service\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | `"FARGATE"` | no |
| <a name="input_ecs_sg_description"></a> [ecs\_sg\_description](#input\_ecs\_sg\_description) | vpc id for security group | `string` | `"Security group for example usage with ecs"` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that is passed to the container | `list(string)` | <pre>[<br>  "java",<br>  "-jar",<br>  "/spring-petclinic/spring-petclinic.jar",<br>  "--server.port=8081"<br>]</pre> | no |
| <a name="input_essential"></a> [essential](#input\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `true` | no |
| <a name="input_extra_hosts"></a> [extra\_hosts](#input\_extra\_hosts) | A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps | <pre>list(object({<br>    ipAddress = string<br>    hostname  = string<br>  }))</pre> | `null` | no |
| <a name="input_fluentbit_awslogs_group"></a> [fluentbit\_awslogs\_group](#input\_fluentbit\_awslogs\_group) | identify the awslogs\_region | `string` | `"firelens-container"` | no |
| <a name="input_fluentbit_awslogs_region"></a> [fluentbit\_awslogs\_region](#input\_fluentbit\_awslogs\_region) | identify the awslogs\_region | `string` | `"us-west-2"` | no |
| <a name="input_fluentbit_awslogs_stream_prefix"></a> [fluentbit\_awslogs\_stream\_prefix](#input\_fluentbit\_awslogs\_stream\_prefix) | identify the awslogs\_stream\_prefix | `string` | `"oxdi-test"` | no |
| <a name="input_fluentbit_container_image"></a> [fluentbit\_container\_image](#input\_fluentbit\_container\_image) | The image used to start the container. Images in the Docker Hub registry available by default | `string` | n/a | yes |
| <a name="input_fluentbit_container_memory_reservation"></a> [fluentbit\_container\_memory\_reservation](#input\_fluentbit\_container\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `50` | no |
| <a name="input_fluentbit_container_name"></a> [fluentbit\_container\_name](#input\_fluentbit\_container\_name) | The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, \_ allowed) | `string` | n/a | yes |
| <a name="input_fluentbit_entrypoint"></a> [fluentbit\_entrypoint](#input\_fluentbit\_entrypoint) | The entry point that is passed to the container | `list(string)` | `null` | no |
| <a name="input_fluentbit_logDriver"></a> [fluentbit\_logDriver](#input\_fluentbit\_logDriver) | identify the logDriver | `string` | `"awslogs"` | no |
| <a name="input_from_port"></a> [from\_port](#input\_from\_port) | from\_port | `number` | `0` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname to use for your container. | `string` | `null` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | port for application | `number` | n/a | yes |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | port for application | `number` | n/a | yes |
| <a name="input_interactive"></a> [interactive](#input\_interactive) | When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated. | `bool` | `null` | no |
| <a name="input_jfrog_password"></a> [jfrog\_password](#input\_jfrog\_password) | password of Jfrog password stored in aws\_ssm\_parameter | `string` | `"jfrog/credentials"` | no |
| <a name="input_kms_description_for_secretsmanager"></a> [kms\_description\_for\_secretsmanager](#input\_kms\_description\_for\_secretsmanager) | The description of the key as viewed in AWS console. | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_lb_listener_http"></a> [lb\_listener\_http](#input\_lb\_listener\_http) | A list of maps describing HTTP listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | A list of maps describing HTTPS listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_target_group_name"></a> [lb\_target\_group\_name](#input\_lb\_target\_group\_name) | Name of the target group for blue | `string` | n/a | yes |
| <a name="input_lb_target_group_name2"></a> [lb\_target\_group\_name2](#input\_lb\_target\_group\_name2) | Name of the target group for green | `string` | n/a | yes |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Configuration block for load balancers. | `any` | n/a | yes |
| <a name="input_logDriver"></a> [logDriver](#input\_logDriver) | identify the logDriver | `string` | `"awsfirelens"` | no |
| <a name="input_log_group_name_prefix"></a> [log\_group\_name\_prefix](#input\_log\_group\_name\_prefix) | To identify the log group name | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | n/a | yes |
| <a name="input_memory_alert_threshold"></a> [memory\_alert\_threshold](#input\_memory\_alert\_threshold) | Threshold which will trigger a alert when the memory crosses | `string` | `"80"` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly` | <pre>list(object({<br>    containerPath = string<br>    sourceVolume  = string<br>    readOnly      = bool<br>  }))</pre> | <pre>[<br>  {<br>    "containerPath": "/host-store",<br>    "readOnly": false,<br>    "sourceVolume": "sensor-host-store"<br>  }<br>]</pre> | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_parameter_alb_cidr_id1"></a> [parameter\_alb\_cidr\_id1](#input\_parameter\_alb\_cidr\_id1) | alb cidr block stored in aws\_ssm\_parameter | `string` | `"/vpc/securitygroup/inbound/pgecidr1"` | no |
| <a name="input_parameter_alb_cidr_id2"></a> [parameter\_alb\_cidr\_id2](#input\_parameter\_alb\_cidr\_id2) | alb cidr block stored in aws\_ssm\_parameter | `string` | `"/vpc/securitygroup/inbound/pgecidr2"` | no |
| <a name="input_parameter_alb_cidr_id3"></a> [parameter\_alb\_cidr\_id3](#input\_parameter\_alb\_cidr\_id3) | alb cidr block stored in aws\_ssm\_parameter | `string` | `"/vpc/securitygroup/inbound/pgecidr3"` | no |
| <a name="input_parameter_subnet_cidr1_id"></a> [parameter\_subnet\_cidr1\_id](#input\_parameter\_subnet\_cidr1\_id) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `"/vpc/managementsubnet1/cidr"` | no |
| <a name="input_parameter_subnet_cidr2_id"></a> [parameter\_subnet\_cidr2\_id](#input\_parameter\_subnet\_cidr2\_id) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `"/vpc/managementsubnet2/cidr"` | no |
| <a name="input_parameter_subnet_cidr3_id"></a> [parameter\_subnet\_cidr3\_id](#input\_parameter\_subnet\_cidr3\_id) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `"/vpc/privatesubnet3/cidr"` | no |
| <a name="input_parameter_subnet_id1_name"></a> [parameter\_subnet\_id1\_name](#input\_parameter\_subnet\_id1\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `"/vpc/managementsubnet1/id"` | no |
| <a name="input_parameter_subnet_id2_name"></a> [parameter\_subnet\_id2\_name](#input\_parameter\_subnet\_id2\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `"/vpc/managementsubnet2/id"` | no |
| <a name="input_parameter_subnet_id3_name"></a> [parameter\_subnet\_id3\_name](#input\_parameter\_subnet\_id3\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | `"/vpc/privatesubnet3/id"` | no |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | `"/vpc/id"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy template file in json format | `string` | `"s3_policy.json"` | no |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br>    containerPort = number<br>    hostPort      = number<br>    protocol      = string<br>  }))</pre> | `[]` | no |
| <a name="input_port_mappings_for_fluentbit"></a> [port\_mappings\_for\_fluentbit](#input\_port\_mappings\_for\_fluentbit) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br>    containerPort = number<br>    hostPort      = number<br>    protocol      = string<br>  }))</pre> | `[]` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type. | `bool` | `null` | no |
| <a name="input_pseudo_terminal"></a> [pseudo\_terminal](#input\_pseudo\_terminal) | When this parameter is true, a TTY is allocated. | `bool` | `null` | no |
| <a name="input_readonly_root_filesystem"></a> [readonly\_root\_filesystem](#input\_readonly\_root\_filesystem) | Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `false` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `0` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | Configuration block for runtime\_platform that containers in your task may use. | `map(string)` | n/a | yes |
| <a name="input_sample_application_port1"></a> [sample\_application\_port1](#input\_sample\_application\_port1) | port for application | `number` | n/a | yes |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | `true` | no |
| <a name="input_secretsmanager_description"></a> [secretsmanager\_description](#input\_secretsmanager\_description) | Description of the secret | `string` | `"testing of secrets manager with secret string as key value pairs"` | no |
| <a name="input_setting_value"></a> [setting\_value](#input\_setting\_value) | The value to assign to the setting. Value values are enabled and disabled. | `string` | `"enabled"` | no |
| <a name="input_sns_topic_cloudwatch_alarm_arn"></a> [sns\_topic\_cloudwatch\_alarm\_arn](#input\_sns\_topic\_cloudwatch\_alarm\_arn) | Enter the sns\_topic\_cloudwatch\_alarm\_arn to send alerts to | `string` | n/a | yes |
| <a name="input_target_group_healthcheck"></a> [target\_group\_healthcheck](#input\_target\_group\_healthcheck) | ALB target group Healthcheck. | `any` | <pre>[<br>  {<br>    "enabled": true,<br>    "interval": 10,<br>    "matcher": "200",<br>    "path": "/",<br>    "port": "traffic-port",<br>    "protocol": "HTTP",<br>    "timeout": 9,<br>    "unhealthy_threshold": 10<br>  }<br>]</pre> | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_port1"></a> [target\_group\_port1](#input\_target\_group\_port1) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Protocol to use for routing traffic to the targets | `string` | `"HTTP"` | no |
| <a name="input_target_group_stickiness"></a> [target\_group\_stickiness](#input\_target\_group\_stickiness) | ALB target group stickiness | `any` | <pre>[<br>  {<br>    "cookie_duration": 86400,<br>    "enabled": true,<br>    "type": "lb_cookie"<br>  }<br>]</pre> | no |
| <a name="input_target_group_target_type"></a> [target\_group\_target\_type](#input\_target\_group\_target\_type) | Type of target that you must specify when registering targets with this target group | `string` | `"ip"` | no |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Policy template file in json format | `string` | `"kms_user_policy.json"` | no |
| <a name="input_to_port"></a> [to\_port](#input\_to\_port) | to\_port | `number` | `65535` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | A set of volumes blocks that containers in your task may use. | <pre>list(object({<br>    host_path = string<br>    name      = string<br>  }))</pre> | <pre>[<br>  {<br>    "host_path": "",<br>    "name": "sensor-host-store"<br>  }<br>]</pre> | no |
| <a name="input_wiz_registry_credentials"></a> [wiz\_registry\_credentials](#input\_wiz\_registry\_credentials) | The name given in the parameter store for the wiz\_registry\_credentials | `string` | n/a | yes |
| <a name="input_wiz_secret_credential"></a> [wiz\_secret\_credential](#input\_wiz\_secret\_credential) | The name given in the parameter store for the golden wiz\_secret\_credential | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_account_setting_default_id"></a> [ecs\_account\_setting\_default\_id](#output\_ecs\_account\_setting\_default\_id) | ARN that identifies the account setting. |
| <a name="output_ecs_account_setting_default_principal_arn"></a> [ecs\_account\_setting\_default\_principal\_arn](#output\_ecs\_account\_setting\_default\_principal\_arn) | ARN that identifies the account setting. |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS Cluster. |
| <a name="output_ecs_cluster_capacity_providers_id"></a> [ecs\_cluster\_capacity\_providers\_id](#output\_ecs\_cluster\_capacity\_providers\_id) | Same as cluster\_name. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS Cluster. |
| <a name="output_ecs_cluster_tags_all"></a> [ecs\_cluster\_tags\_all](#output\_ecs\_cluster\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_ecs_dashboard_arn"></a> [ecs\_dashboard\_arn](#output\_ecs\_dashboard\_arn) | ECS Dashboard arn |
| <a name="output_ecs_service_cluster"></a> [ecs\_service\_cluster](#output\_ecs\_service\_cluster) | Amazon Resource Name (ARN) of cluster which the service runs on. |
| <a name="output_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#output\_ecs\_service\_desired\_count) | Number of instances of the task definition. |
| <a name="output_ecs_service_iam_role"></a> [ecs\_service\_iam\_role](#output\_ecs\_service\_iam\_role) | ARN of IAM role used for ELB. |
| <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id) | ARN that identifies the service. |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the service. |
| <a name="output_ecs_service_tags_all"></a> [ecs\_service\_tags\_all](#output\_ecs\_service\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | Full ARN of the Task Definition (including both family and revision). |
| <a name="output_ecs_task_definition_revision"></a> [ecs\_task\_definition\_revision](#output\_ecs\_task\_definition\_revision) | Revision of the task in a particular family. |
| <a name="output_ecs_task_definition_tags_all"></a> [ecs\_task\_definition\_tags\_all](#output\_ecs\_task\_definition\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_fluentbit_container_json"></a> [fluentbit\_container\_json](#output\_fluentbit\_container\_json) | Container definition in JSON format |
| <a name="output_json_map_encoded_list"></a> [json\_map\_encoded\_list](#output\_json\_map\_encoded\_list) | JSON encoded list of container definitions for use with other terraform resources such as aws\_ecs\_task\_definition |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ARN of the load balancer (matches id). |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | The id of the load balancer (matches arn). |
| <a name="output_lb_listener_certificate"></a> [lb\_listener\_certificate](#output\_lb\_listener\_certificate) | The listener\_arn and certificate\_arn separated by a \_. |
| <a name="output_lb_target_group_attachment_id"></a> [lb\_target\_group\_attachment\_id](#output\_lb\_target\_group\_attachment\_id) | A unique identifier for the attachment. |
| <a name="output_listener_http_arn"></a> [listener\_http\_arn](#output\_listener\_http\_arn) | ARN of the listener (matches id). |
| <a name="output_listener_https_arn"></a> [listener\_https\_arn](#output\_listener\_https\_arn) | ARN of the listener (matches id). |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the Target Group (matches id). |
| <a name="output_wiz_container_definition_json"></a> [wiz\_container\_definition\_json](#output\_wiz\_container\_definition\_json) | JSON encoded list of container definitions for use with other terraform resources such as aws\_ecs\_task\_definition |
| <a name="output_wiz_container_name"></a> [wiz\_container\_name](#output\_wiz\_container\_name) | Name of the wiz container. |

<!-- END_TF_DOCS -->