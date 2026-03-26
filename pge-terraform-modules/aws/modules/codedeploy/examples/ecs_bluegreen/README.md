<!-- BEGIN_TF_DOCS -->
# AWS ECS with FARGATE usage example
Terraform module which creates SAF2.0 ECS with FARGATE in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.3.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

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
| <a name="module_container"></a> [container](#module\_container) | app.terraform.io/pgetech/ecs/aws//modules/ecs_container_definition | 0.1.1 |
| <a name="module_ecs_account_setting_default"></a> [ecs\_account\_setting\_default](#module\_ecs\_account\_setting\_default) | app.terraform.io/pgetech/ecs/aws//modules/ecs_account_setting_default | 0.1.0 |
| <a name="module_ecs_codedeploy_app"></a> [ecs\_codedeploy\_app](#module\_ecs\_codedeploy\_app) | ../.. | n/a |
| <a name="module_ecs_codedeploy_deployment_group"></a> [ecs\_codedeploy\_deployment\_group](#module\_ecs\_codedeploy\_deployment\_group) | ../../modules/deployment_group | n/a |
| <a name="module_ecs_fargate"></a> [ecs\_fargate](#module\_ecs\_fargate) | app.terraform.io/pgetech/ecs/aws//modules/ecs_fargate | 0.1.0 |
| <a name="module_ecs_iam_role"></a> [ecs\_iam\_role](#module\_ecs\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | app.terraform.io/pgetech/ecs/aws//modules/ecs_service | 0.1.1 |
| <a name="module_ecs_task_definition"></a> [ecs\_task\_definition](#module\_ecs\_task\_definition) | app.terraform.io/pgetech/ecs/aws//modules/ecs_task_definition | 0.1.1 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_s3"></a> [s3](#module\_s3) | app.terraform.io/pgetech/s3/aws | 0.1.1 |
| <a name="module_secretsmanager_kms_key"></a> [secretsmanager\_kms\_key](#module\_secretsmanager\_kms\_key) | app.terraform.io/pgetech/kms/aws | 0.1.2 |
| <a name="module_security_group_alb"></a> [security\_group\_alb](#module\_security\_group\_alb) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_ecs"></a> [security\_group\_ecs](#module\_security\_group\_ecs) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_vpc_endpoint"></a> [security\_group\_vpc\_endpoint](#module\_security\_group\_vpc\_endpoint) | app.terraform.io/pgetech/security-group/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.jfrog_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [template_file.s3_policy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

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
| <a name="input_action"></a> [action](#input\_action) | action to proceed for the codedeploy | `string` | n/a | yes |
| <a name="input_action_on_timeout"></a> [action\_on\_timeout](#input\_action\_on\_timeout) | CodeDeploy B/G action to take on timeout | `string` | n/a | yes |
| <a name="input_alb_cidr_egress_rules"></a> [alb\_cidr\_egress\_rules](#input\_alb\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_alb_cidr_ingress_rules"></a> [alb\_cidr\_ingress\_rules](#input\_alb\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The resource name and Name tag of the load balancer. | `string` | n/a | yes |
| <a name="input_alb_s3_bucket_name"></a> [alb\_s3\_bucket\_name](#input\_alb\_s3\_bucket\_name) | Name of the S3 bucket for alb logs. | `string` | n/a | yes |
| <a name="input_alb_sg_description"></a> [alb\_sg\_description](#input\_alb\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_alb_sg_name"></a> [alb\_sg\_name](#input\_alb\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_auto_rollback_configuration_enabled"></a> [auto\_rollback\_configuration\_enabled](#input\_auto\_rollback\_configuration\_enabled) | autorollback whether true or false | `bool` | n/a | yes |
| <a name="input_auto_rollback_configuration_events"></a> [auto\_rollback\_configuration\_events](#input\_auto\_rollback\_configuration\_events) | auto\_rollback\_configuration\_events | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_awslogs_group"></a> [awslogs\_group](#input\_awslogs\_group) | identify the awslogs\_region | `string` | n/a | yes |
| <a name="input_awslogs_region"></a> [awslogs\_region](#input\_awslogs\_region) | identify the awslogs\_region | `string` | n/a | yes |
| <a name="input_awslogs_stream_prefix"></a> [awslogs\_stream\_prefix](#input\_awslogs\_stream\_prefix) | identify the awslogs\_stream\_prefix | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the certificate to attach to the listener. | `list(map(string))` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Enter the name of the cluster | `string` | n/a | yes |
| <a name="input_codedeploy_app_compute_platform"></a> [codedeploy\_app\_compute\_platform](#input\_codedeploy\_app\_compute\_platform) | Enter CodeDeploy computing platform, ECS | `string` | n/a | yes |
| <a name="input_codedeploy_application_name"></a> [codedeploy\_application\_name](#input\_codedeploy\_application\_name) | Enter Application name | `string` | n/a | yes |
| <a name="input_codedeploy_deployment_groupname"></a> [codedeploy\_deployment\_groupname](#input\_codedeploy\_deployment\_groupname) | Enter application deployment group name | `string` | n/a | yes |
| <a name="input_codedeploy_deployment_type"></a> [codedeploy\_deployment\_type](#input\_codedeploy\_deployment\_type) | codedeploy deployment type | `string` | n/a | yes |
| <a name="input_command"></a> [command](#input\_command) | The command that is passed to the container | `list(string)` | `null` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container\_cpu of all containers in a task will need to be lower than the task-level cpu value | `number` | `0` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | The environment variables to pass to the container. This is a list of maps. map\_environment overrides environment | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | The image used to start the container. Images in the Docker Hub registry available by default | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container\_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container\_memory of all containers in a task will need to be lower than the task memory value | `number` | `null` | no |
| <a name="input_container_memory_reservation"></a> [container\_memory\_reservation](#input\_container\_memory\_reservation) | The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container\_memory hard limit | `number` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, \_ allowed) | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | n/a | yes |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | Enter Application name | `string` | `"CodeDeployDefault.ECSAllAtOnce"` | no |
| <a name="input_deployment_group_service_role_arn"></a> [deployment\_group\_service\_role\_arn](#input\_deployment\_group\_service\_role\_arn) | Enter deloyment group service role ARN for CodeDeploy -> Blue green deployment | `string` | n/a | yes |
| <a name="input_deployment_option"></a> [deployment\_option](#input\_deployment\_option) | deployment option for codedeploy | `string` | n/a | yes |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS, EXTERNAL. Default: ECS. | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running. Defaults to 0. | `number` | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | Docker registry from which the image will be deployed | `string` | `"JFROG"` | no |
| <a name="input_ecs_account_name"></a> [ecs\_account\_name](#input\_ecs\_account\_name) | Name of the account setting to set. Valid values are serviceLongArnFormat, taskLongArnFormat, containerInstanceLongArnFormat, awsvpcTrunking and containerInsights. | `string` | n/a | yes |
| <a name="input_ecs_account_setting_value"></a> [ecs\_account\_setting\_value](#input\_ecs\_account\_setting\_value) | State of the setting. Valid values are enabled and disabled. | `string` | n/a | yes |
| <a name="input_ecs_cidr_egress_rules"></a> [ecs\_cidr\_egress\_rules](#input\_ecs\_cidr\_egress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_ecs_cidr_ingress_rules"></a> [ecs\_cidr\_ingress\_rules](#input\_ecs\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_ecs_cluster_capacity_providers"></a> [ecs\_cluster\_capacity\_providers](#input\_ecs\_cluster\_capacity\_providers) | Set of names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE\_SPOT. | `list(string)` | n/a | yes |
| <a name="input_ecs_default_cluster_capacity_provider"></a> [ecs\_default\_cluster\_capacity\_provider](#input\_ecs\_default\_cluster\_capacity\_provider) | The short name of the capacity provider. | `string` | n/a | yes |
| <a name="input_ecs_iam_aws_service"></a> [ecs\_iam\_aws\_service](#input\_ecs\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_ecs_iam_name"></a> [ecs\_iam\_name](#input\_ecs\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_ecs_iam_policy_arns"></a> [ecs\_iam\_policy\_arns](#input\_ecs\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_ecs_service_launch_type"></a> [ecs\_service\_launch\_type](#input\_ecs\_service\_launch\_type) | Launch type on which to run your service. The valid values are EC2, FARGATE, and EXTERNAL. Defaults to EC2. | `string` | n/a | yes |
| <a name="input_ecs_sg_description"></a> [ecs\_sg\_description](#input\_ecs\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_ecs_sg_name"></a> [ecs\_sg\_name](#input\_ecs\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_essential"></a> [essential](#input\_essential) | Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `true` | no |
| <a name="input_extra_hosts"></a> [extra\_hosts](#input\_extra\_hosts) | A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps | <pre>list(object({<br/>    ipAddress = string<br/>    hostname  = string<br/>  }))</pre> | `null` | no |
| <a name="input_family_service"></a> [family\_service](#input\_family\_service) | A unique name for your task definition. | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname to use for your container. | `string` | `null` | no |
| <a name="input_interactive"></a> [interactive](#input\_interactive) | When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated. | `bool` | `null` | no |
| <a name="input_jfrog_credentials"></a> [jfrog\_credentials](#input\_jfrog\_credentials) | Jfrog Credentials stored in the secrets | `string` | `"/jfrog/credentials"` | no |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_lb_listener_http"></a> [lb\_listener\_http](#input\_lb\_listener\_http) | A list of maps describing HTTP listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | A list of maps describing HTTPS listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_target_group_name"></a> [lb\_target\_group\_name](#input\_lb\_target\_group\_name) | Name of the target group for blue | `string` | n/a | yes |
| <a name="input_lb_target_group_name_test"></a> [lb\_target\_group\_name\_test](#input\_lb\_target\_group\_name\_test) | Name of the target group for green | `string` | n/a | yes |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Configuration block for load balancers. | `any` | n/a | yes |
| <a name="input_logDriver"></a> [logDriver](#input\_logDriver) | identify the logDriver | `string` | n/a | yes |
| <a name="input_log_group_name_prefix"></a> [log\_group\_name\_prefix](#input\_log\_group\_name\_prefix) | To identify the log group name | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_parameter_subnet_id1_name"></a> [parameter\_subnet\_id1\_name](#input\_parameter\_subnet\_id1\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_parameter_subnet_id2_name"></a> [parameter\_subnet\_id2\_name](#input\_parameter\_subnet\_id2\_name) | Name of the subnet id stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_parameter_vpc_id_name"></a> [parameter\_vpc\_id\_name](#input\_parameter\_vpc\_id\_name) | Id of vpc stored in aws\_ssm\_parameter | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | Policy template file in json format | `string` | n/a | yes |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | The port mappings to configure for the container. This is a list of maps. Each map should contain "containerPort", "hostPort", and "protocol", where "protocol" is one of "tcp" or "udp". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort | <pre>list(object({<br/>    containerPort = number<br/>    hostPort      = number<br/>    protocol      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | When this variable is `true`, the container is given elevated privileges on the host container instance (similar to the root user). This parameter is not supported for Windows containers or tasks using the Fargate launch type. | `bool` | `null` | no |
| <a name="input_pseudo_terminal"></a> [pseudo\_terminal](#input\_pseudo\_terminal) | When this parameter is true, a TTY is allocated. | `bool` | `null` | no |
| <a name="input_readonly_root_filesystem"></a> [readonly\_root\_filesystem](#input\_readonly\_root\_filesystem) | Determines whether a container is given read-only access to its root filesystem. Due to how Terraform type casts booleans in json it is required to double quote this value | `bool` | `false` | no |
| <a name="input_requires_compatibilities"></a> [requires\_compatibilities](#input\_requires\_compatibilities) | Set of launch types required by the task. The valid values are EC2 and FARGATE. | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Provide name for the service | `string` | n/a | yes |
| <a name="input_setting_value"></a> [setting\_value](#input\_setting\_value) | The value to assign to the setting. Value values are enabled and disabled. | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | vpc id for security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | name of the security group | `string` | n/a | yes |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_port_test"></a> [target\_group\_port\_test](#input\_target\_group\_port\_test) | Port on which targets receive traffic, unless overridden when registering a specific target | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Protocol to use for routing traffic to the targets | `string` | n/a | yes |
| <a name="input_target_group_target_type"></a> [target\_group\_target\_type](#input\_target\_group\_target\_type) | Type of target that you must specify when registering targets with this target group | `string` | n/a | yes |
| <a name="input_termination_wait_time_in_minutes"></a> [termination\_wait\_time\_in\_minutes](#input\_termination\_wait\_time\_in\_minutes) | wait time to terminate the task for codedeploy failure | `number` | n/a | yes |
| <a name="input_wait_time_in_minutes"></a> [wait\_time\_in\_minutes](#input\_wait\_time\_in\_minutes) | codedeploy b/g Wait time | `string` | n/a | yes |
| <a name="input_wiz_container_image"></a> [wiz\_container\_image](#input\_wiz\_container\_image) | twistlock container image | `string` | n/a | yes |
| <a name="input_wiz_container_name"></a> [wiz\_container\_name](#input\_wiz\_container\_name) | twistlock container name | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
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
| <a name="output_json_map_encoded_list"></a> [json\_map\_encoded\_list](#output\_json\_map\_encoded\_list) | JSON encoded list of container definitions for use with other terraform resources such as aws\_ecs\_task\_definition |

<!-- END_TF_DOCS -->