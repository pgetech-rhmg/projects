<!-- BEGIN_TF_DOCS -->
# AWS ECS with FARGATE usage example
Terraform module which creates SAF2.0 ECS with FARGATE Bluegreen in AWS.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_aws.r53"></a> [aws.r53](#provider\_aws.r53) | >= 5.0 |

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
| <a name="module_acm_public_certificate"></a> [acm\_public\_certificate](#module\_acm\_public\_certificate) | app.terraform.io/pgetech/acm/aws | 0.1.2 |
| <a name="module_alb"></a> [alb](#module\_alb) | app.terraform.io/pgetech/alb/aws//modules/internal_alb_bluegreen | 0.1.2 |
| <a name="module_container"></a> [container](#module\_container) | ../../modules/ecs_container_definition | n/a |
| <a name="module_ecs_account_setting_default"></a> [ecs\_account\_setting\_default](#module\_ecs\_account\_setting\_default) | ../../modules/ecs_account_setting_default | n/a |
| <a name="module_ecs_codedeploy_app"></a> [ecs\_codedeploy\_app](#module\_ecs\_codedeploy\_app) | app.terraform.io/pgetech/codedeploy/aws | 0.1.2 |
| <a name="module_ecs_codedeploy_deployment_group"></a> [ecs\_codedeploy\_deployment\_group](#module\_ecs\_codedeploy\_deployment\_group) | app.terraform.io/pgetech/codedeploy/aws//modules/deployment_group | 0.1.2 |
| <a name="module_ecs_fargate"></a> [ecs\_fargate](#module\_ecs\_fargate) | ../../modules/ecs_fargate | n/a |
| <a name="module_ecs_fargate_appautoscaling"></a> [ecs\_fargate\_appautoscaling](#module\_ecs\_fargate\_appautoscaling) | ../../modules/ecs_fargate_appautoscaling | n/a |
| <a name="module_ecs_iam_role"></a> [ecs\_iam\_role](#module\_ecs\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | ../../modules/ecs_service_bluegreen | n/a |
| <a name="module_ecs_task_definition"></a> [ecs\_task\_definition](#module\_ecs\_task\_definition) | ../../modules/ecs_task_definition | n/a |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_secretsmanager"></a> [secretsmanager](#module\_secretsmanager) | app.terraform.io/pgetech/secretsmanager/aws | 0.1.3 |
| <a name="module_secretsmanager_kms_key"></a> [secretsmanager\_kms\_key](#module\_secretsmanager\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_security_group_alb"></a> [security\_group\_alb](#module\_security\_group\_alb) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_ecs"></a> [security\_group\_ecs](#module\_security\_group\_ecs) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.private_cname_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_route53_zone.private_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret.jfrog_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.wiz_secret_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.jfrog_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.wiz_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_account_num_r53"></a> [account\_num\_r53](#input\_account\_num\_r53) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_action_on_timeout"></a> [action\_on\_timeout](#input\_action\_on\_timeout) | CodeDeploy B/G action to take on timeout | `string` | `"CONTINUE_DEPLOYMENT"` | no |
| <a name="input_alb_cidr_egress_rules"></a> [alb\_cidr\_egress\_rules](#input\_alb\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_alb_cidr_ingress_rules"></a> [alb\_cidr\_ingress\_rules](#input\_alb\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_alb_sg_description"></a> [alb\_sg\_description](#input\_alb\_sg\_description) | vpc id for security group | `string` | `"Security group for alb usage with ecs"` | no |
| <a name="input_auto_rollback_configuration_enabled"></a> [auto\_rollback\_configuration\_enabled](#input\_auto\_rollback\_configuration\_enabled) | autorollback whether true or false | `bool` | `true` | no |
| <a name="input_auto_rollback_configuration_events"></a> [auto\_rollback\_configuration\_events](#input\_auto\_rollback\_configuration\_events) | event type or types that trigger a rollback | `list(string)` | <pre>[<br>  "DEPLOYMENT_FAILURE"<br>]</pre> | no |
| <a name="input_availability_zone_rebalancing"></a> [availability\_zone\_rebalancing](#input\_availability\_zone\_rebalancing) | Automatically redistributes tasks within a service across Availability Zones Valid values: ENABLED, DISABLED. Default: DISABLED. | `string` | `"DISABLED"` | no |
| <a name="input_aws_r53_role"></a> [aws\_r53\_role](#input\_aws\_r53\_role) | AWS role to assume | `string` | `"CloudAdmin"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Enter the name of the cluster | `string` | n/a | yes |
| <a name="input_codedeploy_app_compute_platform"></a> [codedeploy\_app\_compute\_platform](#input\_codedeploy\_app\_compute\_platform) | Enter CodeDeploy computing platform, ECS | `string` | `"ECS"` | no |
| <a name="input_command"></a> [command](#input\_command) | The command that is passed to the container | `list(string)` | `null` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container\_cpu of all containers in a task will need to be lower than the task-level cpu value | `number` | `0` | no |
| <a name="input_container_depends_on"></a> [container\_depends\_on](#input\_container\_depends\_on) | The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. When a dependency is defined for container startup, for container shutdown it is reversed. The condition can be one of START, COMPLETE, SUCCESS or HEALTHY | <pre>list(object({<br>    containerName = string<br>    condition     = string<br>  }))</pre> | `null` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | The environment variables to pass to the container. This is a list of maps. map\_environment overrides environment | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The image used to start the container. Images in the Docker Hub registry available by default | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container\_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container\_memory of all containers in a task will need to be lower than the task memory value | `number` | `null` | no |
| <a name="input_container_memory_reservation"></a> [container\_memory\_reservation](#input\_container\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, \_ allowed) | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | n/a | yes |
| <a name="input_create_autoscaling"></a> [create\_autoscaling](#input\_create\_autoscaling) | Whether to create autoscaling | `bool` | n/a | yes |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | A domain name for which the certificate should be issued | `string` | n/a | yes |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | Enter Application name | `string` | `"CodeDeployDefault.ECSAllAtOnce"` | no |
| <a name="input_deployment_group_service_role_arn"></a> [deployment\_group\_service\_role\_arn](#input\_deployment\_group\_service\_role\_arn) | Enter deloyment group service role ARN for CodeDeploy -> Blue green deployment | `string` | `"arn:aws:iam::750713712981:role/AWSCodeDeployRoleForECS"` | no |
| <a name="input_deployment_style_deployment_option"></a> [deployment\_style\_deployment\_option](#input\_deployment\_style\_deployment\_option) | whether to route deployment traffic behind a load balancer | `string` | `"WITH_TRAFFIC_CONTROL"` | no |
| <a name="input_deployment_style_deployment_type"></a> [deployment\_style\_deployment\_type](#input\_deployment\_style\_deployment\_type) | whether to run an in-place deployment or a blue/green deployment | `string` | `"BLUE_GREEN"` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS, EXTERNAL. Default: ECS. | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running. Defaults to 0. | `number` | n/a | yes |
| <a name="input_disable_networking"></a> [disable\_networking](#input\_disable\_networking) | When this parameter is true, networking is disabled within the container. | `bool` | `null` | no |
| <a name="input_dns_search_domains"></a> [dns\_search\_domains](#input\_dns\_search\_domains) | Container DNS search domains. A list of DNS search domains that are presented to the container | `list(string)` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers | `list(string)` | `null` | no |
| <a name="input_docker_labels"></a> [docker\_labels](#input\_docker\_labels) | The configuration options to send to the `docker_labels` | `map(string)` | `null` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | Docker registry from which the image will be deployed | `string` | `"JFROG"` | no |
| <a name="input_ecs_account_name"></a> [ecs\_account\_name](#input\_ecs\_account\_name) | Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights. | `string` | `"taskLongArnFormat"` | no |
| <a name="input_ecs_account_setting_value"></a> [ecs\_account\_setting\_value](#input\_ecs\_account\_setting\_value) | State of the setting. Valid values are enabled and disabled. | `string` | `"enabled"` | no |
| <a name="input_ecs_cidr_egress_rules"></a> [ecs\_cidr\_egress\_rules](#input\_ecs\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_ecs_cidr_ingress_rules"></a> [ecs\_cidr\_ingress\_rules](#input\_ecs\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_ecs_cluster_capacity_providers"></a> [ecs\_cluster\_capacity\_providers](#input\_ecs\_cluster\_capacity\_providers) | Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | <pre>[<br>  "FARGATE",<br>  "FARGATE_SPOT"<br>]</pre> | no |
| <a name="input_ecs_default_cluster_capacity_provider"></a> [ecs\_default\_cluster\_capacity\_provider](#input\_ecs\_default\_cluster\_capacity\_provider) | The short name of the capacity provider. | `string` | `"FARGATE"` | no |
| <a name="input_ecs_iam_aws_service"></a> [ecs\_iam\_aws\_service](#input\_ecs\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | <pre>[<br>  "ecs.amazonaws.com",<br>  "ecs-tasks.amazonaws.com"<br>]</pre> | no |
| <a name="input_ecs_iam_policy_arns"></a> [ecs\_iam\_policy\_arns](#input\_ecs\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",<br>  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"<br>]</pre> | no |
| <a name="input_ecs_service_launch_type"></a> [ecs\_service\_launch\_type](#input\_ecs\_service\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | n/a | yes |
| <a name="input_ecs_sg_description"></a> [ecs\_sg\_description](#input\_ecs\_sg\_description) | vpc id for security group | `string` | `"Security group for example usage with ecs"` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that is passed to the container | `list(string)` | `null` | no |
| <a name="input_environment_files"></a> [environment\_files](#input\_environment\_files) | One or more files containing the environment variables to pass to the container. This maps to the --env-file option to docker run. The file must be hosted in Amazon S3. This option is only available to tasks using the EC2 launch type. This is a list of maps | <pre>list(object({<br>    value = string<br>    type  = string<br>  }))</pre> | `null` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `true` | no |
| <a name="input_extra_hosts"></a> [extra\_hosts](#input\_extra\_hosts) | A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps | <pre>list(object({<br>    ipAddress = string<br>    hostname  = string<br>  }))</pre> | `null` | no |
| <a name="input_firelens_configuration"></a> [firelens\_configuration](#input\_firelens\_configuration) | The FireLens configuration for the container. This is used to specify and configure a log router for container logs. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html | <pre>object({<br>    type    = string<br>    options = map(string)<br>  })</pre> | `null` | no |
| <a name="input_healthcheck"></a> [healthcheck](#input\_healthcheck) | A map containing command (string), timeout, interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy), and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries) | <pre>object({<br>    command     = list(string)<br>    retries     = number<br>    timeout     = number<br>    interval    = number<br>    startPeriod = number<br>  })</pre> | `null` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname to use for your container. | `string` | `null` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | https Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_https_port1"></a> [https\_port1](#input\_https\_port1) | https Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_https_protocol"></a> [https\_protocol](#input\_https\_protocol) | https Protocol to use for routing traffic to the targets | `string` | n/a | yes |
| <a name="input_https_type"></a> [https\_type](#input\_https\_type) | Type of target that you must specify when registering targets with this target group | `string` | n/a | yes |
| <a name="input_interactive"></a> [interactive](#input\_interactive) | When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated. | `bool` | `null` | no |
| <a name="input_jfrog_credentials"></a> [jfrog\_credentials](#input\_jfrog\_credentials) | Jfrog Credentials stored in the secrets | `string` | `"/jfrog/credentials"` | no |
| <a name="input_lb_listener_http"></a> [lb\_listener\_http](#input\_lb\_listener\_http) | A list of maps describing HTTP listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_target_group_name"></a> [lb\_target\_group\_name](#input\_lb\_target\_group\_name) | Name of the target group for blue | `string` | n/a | yes |
| <a name="input_lb_target_group_name_test"></a> [lb\_target\_group\_name\_test](#input\_lb\_target\_group\_name\_test) | Name of the target group for green | `string` | n/a | yes |
| <a name="input_links"></a> [links](#input\_links) | List of container names this container can communicate with without port mappings | `list(string)` | `null` | no |
| <a name="input_linux_parameters"></a> [linux\_parameters](#input\_linux\_parameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html | <pre>object({<br>    capabilities = object({<br>      add  = list(string)<br>      drop = list(string)<br>    })<br>    devices = list(object({<br>      containerPath = string<br>      hostPath      = string<br>      permissions   = list(string)<br>    }))<br>    initProcessEnabled = bool<br>    maxSwap            = number<br>    sharedMemorySize   = number<br>    swappiness         = number<br>    tmpfs = list(object({<br>      containerPath = string<br>      mountOptions  = list(string)<br>      size          = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Configuration block for load balancers. | `any` | n/a | yes |
| <a name="input_logDriver"></a> [logDriver](#input\_logDriver) | identify the logDriver | `string` | `"awslogs"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | n/a | yes |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | Container mount points. This is a list of maps, where each map should contain `containerPath`, `sourceVolume` and `readOnly` | <pre>list(object({<br>    containerPath = string<br>    sourceVolume  = string<br>    readOnly      = bool<br>  }))</pre> | <pre>[<br>  {<br>    "containerPath": "/host-store",<br>    "readOnly": false,<br>    "sourceVolume": "sensor-host-store"<br>  }<br>]</pre> | no |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_parameter_subnet_id1_name"></a> [parameter\_subnet\_id1\_name](#input\_parameter\_subnet\_id1\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_parameter_subnet_id2_name"></a> [parameter\_subnet\_id2\_name](#input\_parameter\_subnet\_id2\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | `"/vpc/id"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy template file in json format | `string` | `"s3_policy.json"` | no |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br>    containerPort = number<br>    hostPort      = number<br>    protocol      = string<br>  }))</pre> | `[]` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type. | `bool` | `false` | no |
| <a name="input_pseudo_terminal"></a> [pseudo\_terminal](#input\_pseudo\_terminal) | When this parameter is true, a TTY is allocated. | `bool` | `null` | no |
| <a name="input_readonly_root_filesystem"></a> [readonly\_root\_filesystem](#input\_readonly\_root\_filesystem) | Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `false` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `0` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | <pre>[<br>  "FARGATE"<br>]</pre> | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group | `number` | `90` | no |
| <a name="input_runtime_platform"></a> [runtime\_platform](#input\_runtime\_platform) | Configuration block for runtime\_platform that containers in your task may use. | `map(string)` | n/a | yes |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | `true` | no |
| <a name="input_secretsmanager_description"></a> [secretsmanager\_description](#input\_secretsmanager\_description) | Description of the secret | `string` | `"testing of secrets manager with secret string as key value pairs"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Provide name for the service | `string` | n/a | yes |
| <a name="input_setting_value"></a> [setting\_value](#input\_setting\_value) | The value to assign to the setting. Value values are enabled and disabled. | `string` | `"enabled"` | no |
| <a name="input_start_timeout"></a> [start\_timeout](#input\_start\_timeout) | Time duration (in seconds) to wait before giving up on resolving dependencies for a container | `number` | `null` | no |
| <a name="input_step_scaling_policy_configuration"></a> [step\_scaling\_policy\_configuration](#input\_step\_scaling\_policy\_configuration) | Configuration for step scaling policy | <pre>object({<br>    adjustment_type         = string<br>    cooldown                = number<br>    metric_aggregation_type = string<br>    step_adjustment = list(object({<br>      metric_interval_lower_bound = number<br>      metric_interval_upper_bound = number<br>      scaling_adjustment          = number<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_step_scaling_policy_name"></a> [step\_scaling\_policy\_name](#input\_step\_scaling\_policy\_name) | The name of the step scaling policy | `string` | n/a | yes |
| <a name="input_stop_timeout"></a> [stop\_timeout](#input\_stop\_timeout) | Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own | `number` | `null` | no |
| <a name="input_system_controls"></a> [system\_controls](#input\_system\_controls) | A list of namespaced kernel parameters to set in the container, mapping to the --sysctl option to docker run. This is a list of maps: { namespace = "", value = ""} | `list(map(string))` | `null` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_port_test"></a> [target\_group\_port\_test](#input\_target\_group\_port\_test) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Protocol to use for routing traffic to the targets | `string` | n/a | yes |
| <a name="input_target_group_target_type"></a> [target\_group\_target\_type](#input\_target\_group\_target\_type) | Type of target that you must specify when registering targets with this target group | `string` | n/a | yes |
| <a name="input_target_tracking_scaling_policy_configuration"></a> [target\_tracking\_scaling\_policy\_configuration](#input\_target\_tracking\_scaling\_policy\_configuration) | Configuration for target tracking scaling policy | <pre>object({<br>    target_value       = number<br>    scale_in_cooldown  = number<br>    scale_out_cooldown = number<br>    disable_scale_in   = bool<br>    predefined_metric_specification = list(object({<br>      predefined_metric_type = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_target_tracking_scaling_policy_name"></a> [target\_tracking\_scaling\_policy\_name](#input\_target\_tracking\_scaling\_policy\_name) | The name of the target tracking scaling policy | `string` | n/a | yes |
| <a name="input_terminate_blue_instances_on_deployment_success_action"></a> [terminate\_blue\_instances\_on\_deployment\_success\_action](#input\_terminate\_blue\_instances\_on\_deployment\_success\_action) | action to take on instances in the original environment after a successful blue/green deployment | `string` | `"TERMINATE"` | no |
| <a name="input_terminate_blue_instances_on_deployment_success_termination_wait_time_in_minutes"></a> [terminate\_blue\_instances\_on\_deployment\_success\_termination\_wait\_time\_in\_minutes](#input\_terminate\_blue\_instances\_on\_deployment\_success\_termination\_wait\_time\_in\_minutes) | number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment. | `number` | `5` | no |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | Container ulimit settings. This is a list of maps, where each map should contain "name", "hardLimit" and "softLimit" | <pre>list(object({<br>    name      = string<br>    hardLimit = number<br>    softLimit = number<br>  }))</pre> | `null` | no |
| <a name="input_use_target_tracking_scaling"></a> [use\_target\_tracking\_scaling](#input\_use\_target\_tracking\_scaling) | Whether to use target tracking scaling policy or step scaling policy | `bool` | `true` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | A set of volumes blocks that containers in your task may use. | <pre>list(object({<br>    host_path = string<br>    name      = string<br>  }))</pre> | <pre>[<br>  {<br>    "host_path": "",<br>    "name": "sensor-host-store"<br>  }<br>]</pre> | no |
| <a name="input_volumes_from"></a> [volumes\_from](#input\_volumes\_from) | A list of VolumesFrom maps which contain "sourceContainer" (name of the container that has the volumes to mount) and "readOnly" (whether the container can write to the volume) | <pre>list(object({<br>    sourceContainer = string<br>    readOnly        = bool<br>  }))</pre> | `[]` | no |
| <a name="input_wait_time_in_minutes"></a> [wait\_time\_in\_minutes](#input\_wait\_time\_in\_minutes) | codedeploy b/g Wait time | `string` | `"0"` | no |
| <a name="input_wiz_repository_Credentials"></a> [wiz\_repository\_Credentials](#input\_wiz\_repository\_Credentials) | Container repository credentials; required when using a private repo.  This map currently supports a single key; "credentialsParameter", which should be the ARN of a Secrets Manager's secret holding the credentials | `map(string)` | `null` | no |
| <a name="input_wiz_secret_credential"></a> [wiz\_secret\_credential](#input\_wiz\_secret\_credential) | The name given in the parameter store for the golden wiz\_secret\_credential | `string` | n/a | yes |
| <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory) | The working directory to run commands inside the container | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the container |
| <a name="output_ecs_account_setting_default_id"></a> [ecs\_account\_setting\_default\_id](#output\_ecs\_account\_setting\_default\_id) | ARN that identifies the account setting. |
| <a name="output_ecs_account_setting_default_principal_arn"></a> [ecs\_account\_setting\_default\_principal\_arn](#output\_ecs\_account\_setting\_default\_principal\_arn) | ARN that identifies the account setting. |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS Cluster. |
| <a name="output_ecs_cluster_capacity_providers_id"></a> [ecs\_cluster\_capacity\_providers\_id](#output\_ecs\_cluster\_capacity\_providers\_id) | Same as cluster\_name. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS Cluster. |
| <a name="output_ecs_cluster_tags_all"></a> [ecs\_cluster\_tags\_all](#output\_ecs\_cluster\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_ecs_service_cluster"></a> [ecs\_service\_cluster](#output\_ecs\_service\_cluster) | Amazon Resource Name (ARN) of cluster which the service runs on. |
| <a name="output_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#output\_ecs\_service\_desired\_count) | Number of instances of the task definition. |
| <a name="output_ecs_service_iam_role"></a> [ecs\_service\_iam\_role](#output\_ecs\_service\_iam\_role) | ARN of IAM role used for ELB. |
| <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id) | ARN that identifies the service. |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the service. |
| <a name="output_ecs_service_tags_all"></a> [ecs\_service\_tags\_all](#output\_ecs\_service\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | Full ARN of the Task Definition (including both family and revision). |
| <a name="output_ecs_task_definition_revision"></a> [ecs\_task\_definition\_revision](#output\_ecs\_task\_definition\_revision) | Revision of the task in a particular family. |
| <a name="output_ecs_task_definition_tags_all"></a> [ecs\_task\_definition\_tags\_all](#output\_ecs\_task\_definition\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_wiz_container_definition_json"></a> [wiz\_container\_definition\_json](#output\_wiz\_container\_definition\_json) | JSON encoded list of container definitions for use with other terraform resources such as aws\_ecs\_task\_definition |
| <a name="output_wiz_container_name"></a> [wiz\_container\_name](#output\_wiz\_container\_name) | Name of the wiz container. |

<!-- END_TF_DOCS -->