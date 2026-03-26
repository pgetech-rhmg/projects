<!-- BEGIN_TF_DOCS -->
# Blue-Green EC2 Deployment Module
Terraform module which creates bluegreen EC2 AMI Automation in AWS

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

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
| <a name="module_bluegreen_ec2"></a> [bluegreen\_ec2](#module\_bluegreen\_ec2) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

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
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | AWS account ID for app infra. | `string` | n/a | yes |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the alb | `string` | n/a | yes |
| <a name="input_ami_catalog_param_name"></a> [ami\_catalog\_param\_name](#input\_ami\_catalog\_param\_name) | SSM parameter name for AMI catalog JSON. | `string` | `"/app/bluegreen/ami_catalog"` | no |
| <a name="input_auto_apply_ami_updates"></a> [auto\_apply\_ami\_updates](#input\_auto\_apply\_ami\_updates) | Auto-apply Terraform runs triggered by AMI updates | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | IAM role name for assuming into app account. | `string` | n/a | yes |
| <a name="input_blue_asg_name"></a> [blue\_asg\_name](#input\_blue\_asg\_name) | n/a | `string` | `"blue_asg"` | no |
| <a name="input_blue_desired_capacity"></a> [blue\_desired\_capacity](#input\_blue\_desired\_capacity) | n/a | `number` | `0` | no |
| <a name="input_blue_max_size"></a> [blue\_max\_size](#input\_blue\_max\_size) | n/a | `number` | `2` | no |
| <a name="input_blue_min_size"></a> [blue\_min\_size](#input\_blue\_min\_size) | n/a | `number` | `0` | no |
| <a name="input_blue_mode"></a> [blue\_mode](#input\_blue\_mode) | How blue AMI is selected: 'relative\_to\_selected', 'relative\_to\_latest', or 'pinned'. | `string` | `"relative_to_selected"` | no |
| <a name="input_blue_pinned_ami_id"></a> [blue\_pinned\_ami\_id](#input\_blue\_pinned\_ami\_id) | If blue\_mode = 'pinned', use this AMI ID for blue. | `string` | `""` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | Configuration block for egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | Configuration block for ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_ami_automation"></a> [enable\_ami\_automation](#input\_enable\_ami\_automation) | Enable AMI automation via Lambda | `bool` | `false` | no |
| <a name="input_green_asg_name"></a> [green\_asg\_name](#input\_green\_asg\_name) | n/a | `string` | `"green_asg"` | no |
| <a name="input_green_desired_capacity"></a> [green\_desired\_capacity](#input\_green\_desired\_capacity) | n/a | `number` | `2` | no |
| <a name="input_green_max_size"></a> [green\_max\_size](#input\_green\_max\_size) | n/a | `number` | `2` | no |
| <a name="input_green_min_size"></a> [green\_min\_size](#input\_green\_min\_size) | n/a | `number` | `1` | no |
| <a name="input_green_percent"></a> [green\_percent](#input\_green\_percent) | Traffic percentage to send to green TG (0–100). | `number` | `100` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type. | `string` | n/a | yes |
| <a name="input_lambda_bucket_name"></a> [lambda\_bucket\_name](#input\_lambda\_bucket\_name) | S3 bucket to store the lambda function | `string` | `null` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | The AWS Lambda action you want to allow in this statement | `string` | `null` | no |
| <a name="input_latest_ami_param_name"></a> [latest\_ami\_param\_name](#input\_latest\_ami\_param\_name) | SSM parameter name holding latest AMI ID. | `string` | `"/app/bluegreen/latest_ami"` | no |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | n/a | <pre>list(object({<br/>    port              = number<br/>    protocol          = string<br/>    type              = string<br/>    target_group_name = string<br/>    certificate_arn   = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lb_target_group"></a> [lb\_target\_group](#input\_lb\_target\_group) | n/a | <pre>list(object({<br/>    name        = string<br/>    target_type = string<br/>    port        = number<br/>    protocol    = string<br/>    health_check = list(object({<br/>      enabled             = bool<br/>      healthy_threshold   = number<br/>      interval            = number<br/>      matcher             = string<br/>      path                = string<br/>      port                = string<br/>      protocol            = string<br/>      timeout             = number<br/>      unhealthy_threshold = number<br/>    }))<br/>    stickiness = list(object({<br/>      enabled         = bool<br/>      type            = string<br/>      cookie_duration = number<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_release_version"></a> [release\_version](#input\_release\_version) | AMI version to treat as N. Use 'latest' or specific version number. | `string` | `"latest"` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br/>    from                     = number<br/>    to                       = number<br/>    protocol                 = string<br/>    source_security_group_id = string<br/>    description              = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Security group name | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for ALB and ASG. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID. | `string` | n/a | yes | 

## Outputs

No outputs.

<!-- END_TF_DOCS -->