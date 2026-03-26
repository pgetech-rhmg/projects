<!-- BEGIN_TF_DOCS -->
# AWS CodeDeploy Ec2 In\_place Deployment User module example

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

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
| <a name="module_alb_security_group"></a> [alb\_security\_group](#module\_alb\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_codedeploy_app_ec2"></a> [codedeploy\_app\_ec2](#module\_codedeploy\_app\_ec2) | ../.. | n/a |
| <a name="module_deployment_config_ec2"></a> [deployment\_config\_ec2](#module\_deployment\_config\_ec2) | ../../modules/codedeploy_deployment_config | n/a |
| <a name="module_deployment_group"></a> [deployment\_group](#module\_deployment\_group) | ../../modules/deployment_group | n/a |
| <a name="module_deployment_group_role"></a> [deployment\_group\_role](#module\_deployment\_group\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | app.terraform.io/pgetech/ec2/aws | 0.1.2 |
| <a name="module_ec2_security_group"></a> [ec2\_security\_group](#module\_ec2\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_security_group_vpc_endpoint"></a> [security\_group\_vpc\_endpoint](#module\_security\_group\_vpc\_endpoint) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |
| <a name="module_vpc_endpoint_code_deploy_agent"></a> [vpc\_endpoint\_code\_deploy\_agent](#module\_vpc\_endpoint\_code\_deploy\_agent) | app.terraform.io/pgetech/vpc-endpoint/aws | 0.1.1 |
| <a name="module_vpc_endpoint_code_deploy_api"></a> [vpc\_endpoint\_code\_deploy\_api](#module\_vpc\_endpoint\_code\_deploy\_api) | app.terraform.io/pgetech/vpc-endpoint/aws | 0.1.1 |

## Resources

| Name | Type |
|------|------|
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ssm_parameter.golden_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one). | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud. | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one). | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3. | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_agent_service_name"></a> [agent\_service\_name](#input\_agent\_service\_name) | The service name.It creates a VPC endpoint for CodeDeploy agent operations. | `string` | n/a | yes |
| <a name="input_alb_cidr_egress_rules"></a> [alb\_cidr\_egress\_rules](#input\_alb\_cidr\_egress\_rules) | Egress rule for the CIDR network range. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_alb_cidr_ingress_rules"></a> [alb\_cidr\_ingress\_rules](#input\_alb\_cidr\_ingress\_rules) | Ingress rule for the CIDR network range. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the alb on AWS | `string` | n/a | yes |
| <a name="input_alb_s3_bucket_name"></a> [alb\_s3\_bucket\_name](#input\_alb\_s3\_bucket\_name) | Name of the S3 bucket for alb logs. | `string` | n/a | yes |
| <a name="input_alb_sg_description"></a> [alb\_sg\_description](#input\_alb\_sg\_description) | Security group description for example usage with alb. | `string` | n/a | yes |
| <a name="input_alb_sg_name"></a> [alb\_sg\_name](#input\_alb\_sg\_name) | Name of the security group. | `string` | n/a | yes |
| <a name="input_api_service_name"></a> [api\_service\_name](#input\_api\_service\_name) | The service name.It creates a VPC endpoint for CodeDeploy API operations. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | Aws service of the iam role. | `list(string)` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the certificate to attach to the listener. | `list(map(string))` | n/a | yes |
| <a name="input_codedeploy_app_name"></a> [codedeploy\_app\_name](#input\_codedeploy\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | The name of the deployment config. | `string` | n/a | yes |
| <a name="input_deployment_group_name"></a> [deployment\_group\_name](#input\_deployment\_group\_name) | The name of the deployment group. | `string` | n/a | yes |
| <a name="input_deployment_option"></a> [deployment\_option](#input\_deployment\_option) | Indicates whether to route deployment traffic behind a load balancer. Valid Values are WITH\_TRAFFIC\_CONTROL or WITHOUT\_TRAFFIC\_CONTROL. | `string` | n/a | yes |
| <a name="input_ec2_az"></a> [ec2\_az](#input\_ec2\_az) | List of availability zone for ec2. | `string` | n/a | yes |
| <a name="input_ec2_cidr_egress_rules"></a> [ec2\_cidr\_egress\_rules](#input\_ec2\_cidr\_egress\_rules) | Egress rule for the CIDR network range. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Type of the ec2 instance. | `string` | n/a | yes |
| <a name="input_ec2_name"></a> [ec2\_name](#input\_ec2\_name) | Name to be used on EC2 instance created. | `string` | n/a | yes |
| <a name="input_ec2_sg_description"></a> [ec2\_sg\_description](#input\_ec2\_sg\_description) | Security group description for example usage with EC2 | `string` | n/a | yes |
| <a name="input_ec2_sg_name"></a> [ec2\_sg\_name](#input\_ec2\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_ec2_tag_filter_key"></a> [ec2\_tag\_filter\_key](#input\_ec2\_tag\_filter\_key) | The key of the tag filter. | `string` | n/a | yes |
| <a name="input_ec2_tag_filter_type"></a> [ec2\_tag\_filter\_type](#input\_ec2\_tag\_filter\_type) | The type of the tag filter, either KEY\_ONLY, VALUE\_ONLY, or KEY\_AND\_VALUE. | `string` | n/a | yes |
| <a name="input_ec2_tag_filter_value"></a> [ec2\_tag\_filter\_value](#input\_ec2\_tag\_filter\_value) | The value of the tag filter. | `string` | n/a | yes |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Whether health checks are enabled. | `bool` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | n/a | yes |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | Response codes to use when checking for a healthy responses from a target. | `number` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Destination for the health check request. | `string` | n/a | yes |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Port to use to connect with the target. Valid values are either ports 1-65535, or traffic-port. | `string` | n/a | yes |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | Protocol to use to connect with the target. | `string` | n/a | yes |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Amount of time, in seconds, during which no response means a failed health check. | `number` | n/a | yes |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Number of consecutive health check failures required before considering the target unhealthy. | `number` | n/a | yes |
| <a name="input_lb_listener_http"></a> [lb\_listener\_http](#input\_lb\_listener\_http) | A list of maps describing HTTP listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | A list of maps describing HTTPS listeners for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_rule_http"></a> [lb\_listener\_rule\_http](#input\_lb\_listener\_rule\_http) | A list of maps describing the HTTP listener rules for ALB. | `any` | n/a | yes |
| <a name="input_lb_listener_rule_https"></a> [lb\_listener\_rule\_https](#input\_lb\_listener\_rule\_https) | A list of maps describing the HTTPS listener rules for ALB. | `any` | n/a | yes |
| <a name="input_lb_target_group_name"></a> [lb\_target\_group\_name](#input\_lb\_target\_group\_name) | Name of the target group. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_lb_target_group_port"></a> [lb\_target\_group\_port](#input\_lb\_target\_group\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `number` | n/a | yes |
| <a name="input_lb_target_group_protocol"></a> [lb\_target\_group\_protocol](#input\_lb\_target\_group\_protocol) | Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance, ip or alb. | `string` | n/a | yes |
| <a name="input_lb_target_group_target_type"></a> [lb\_target\_group\_target\_type](#input\_lb\_target\_group\_target\_type) | Type of target that you must specify when registering targets with this target group. | `string` | n/a | yes |
| <a name="input_minimum_healthy_hosts"></a> [minimum\_healthy\_hosts](#input\_minimum\_healthy\_hosts) | type:<br/>  The type can either be `FLEET_PERCENT` or `HOST_COUNT`.<br/>value:<br/>  The value when the type is `FLEET_PERCENT` represents the minimum number of healthy instances <br/>  as a percentage of the total number of instances in the deployment.<br/>  When the type is `HOST_COUNT`, the value represents the minimum number of healthy instances as an absolute value. | <pre>object({<br/>    type  = string<br/>    value = number<br/>  })</pre> | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | optional\_tags. | `map(string)` | `{}` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | Policy arn for the iam role. | `list(string)` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the iam role. | `string` | n/a | yes |
| <a name="input_ssm_parameter_golden_ami"></a> [ssm\_parameter\_golden\_ami](#input\_ssm\_parameter\_golden\_ami) | The name given in parameter store for the golden ami | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id1"></a> [ssm\_parameter\_subnet\_id1](#input\_ssm\_parameter\_subnet\_id1) | The value of subnet id\_1 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_subnet_id2"></a> [ssm\_parameter\_subnet\_id2](#input\_ssm\_parameter\_subnet\_id2) | Tthe value of subnet id\_2 stored in ssm parameter | `string` | n/a | yes |
| <a name="input_ssm_parameter_vpc_id"></a> [ssm\_parameter\_vpc\_id](#input\_ssm\_parameter\_vpc\_id) | The value of vpc id stored in ssm parameter | `string` | n/a | yes |
| <a name="input_targets_ec2_port"></a> [targets\_ec2\_port](#input\_targets\_ec2\_port) | The port on which targets receive traffic. | `number` | n/a | yes |
| <a name="input_vpc_endpoint_cidr_egress_rules"></a> [vpc\_endpoint\_cidr\_egress\_rules](#input\_vpc\_endpoint\_cidr\_egress\_rules) | Egress rule for the CIDR network range. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_endpoint_cidr_ingress_rules"></a> [vpc\_endpoint\_cidr\_ingress\_rules](#input\_vpc\_endpoint\_cidr\_ingress\_rules) | Ingress rule for the CIDR network range. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | n/a | yes |
| <a name="input_vpc_endpoint_sg_description"></a> [vpc\_endpoint\_sg\_description](#input\_vpc\_endpoint\_sg\_description) | description for security group associated with endpoint. | `string` | n/a | yes |
| <a name="input_vpc_endpoint_sg_name"></a> [vpc\_endpoint\_sg\_name](#input\_vpc\_endpoint\_sg\_name) | name of the security group associated with endpoint. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codedeploy_app_application_id"></a> [codedeploy\_app\_application\_id](#output\_codedeploy\_app\_application\_id) | The application ID. |
| <a name="output_codedeploy_app_arn"></a> [codedeploy\_app\_arn](#output\_codedeploy\_app\_arn) | The ARN of the CodeDeploy application. |
| <a name="output_codedeploy_app_github_account_name"></a> [codedeploy\_app\_github\_account\_name](#output\_codedeploy\_app\_github\_account\_name) | The name for a connection to a GitHub account. |
| <a name="output_codedeploy_app_id"></a> [codedeploy\_app\_id](#output\_codedeploy\_app\_id) | Amazon's assigned ID for the application. |
| <a name="output_codedeploy_app_linked_to_github"></a> [codedeploy\_app\_linked\_to\_github](#output\_codedeploy\_app\_linked\_to\_github) | Whether the user has authenticated with GitHub for the specified application. |
| <a name="output_codedeploy_app_name"></a> [codedeploy\_app\_name](#output\_codedeploy\_app\_name) | The application's name. |
| <a name="output_codedeploy_app_tags_all"></a> [codedeploy\_app\_tags\_all](#output\_codedeploy\_app\_tags\_all) | A map of tags assigned to the resource. |
| <a name="output_deployment_config_id"></a> [deployment\_config\_id](#output\_deployment\_config\_id) | The AWS Assigned deployment config id. |
| <a name="output_deployment_group_arn"></a> [deployment\_group\_arn](#output\_deployment\_group\_arn) | The ARN of the CodeDeploy deployment group. |
| <a name="output_deployment_group_compute_platform"></a> [deployment\_group\_compute\_platform](#output\_deployment\_group\_compute\_platform) | The destination platform type for the deployment. |
| <a name="output_deployment_group_config_name"></a> [deployment\_group\_config\_name](#output\_deployment\_group\_config\_name) | The deployment group's config name. |
| <a name="output_deployment_group_id"></a> [deployment\_group\_id](#output\_deployment\_group\_id) | The ARN of the CodeDeploy deployment group. |
| <a name="output_deployment_group_name"></a> [deployment\_group\_name](#output\_deployment\_group\_name) | Application name and deployment group name. |
| <a name="output_deployment_group_tags_all"></a> [deployment\_group\_tags\_all](#output\_deployment\_group\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->