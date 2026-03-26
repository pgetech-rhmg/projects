<!-- BEGIN_TF_DOCS -->
#Rolling EC2 Deployment Module
Terraform module which creates rolling EC2 AMI Automation in AWS

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
| <a name="module_rolling_ec2"></a> [rolling\_ec2](#module\_rolling\_ec2) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AppID"></a> [AppID](#input\_AppID) | AMPS App ID | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance tags | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Data classification | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | Environment (Dev/Test/Prod) | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Notification emails | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order tag | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | Application owners | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | AWS account number | `string` | n/a | yes |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | ALB name | `string` | n/a | yes |
| <a name="input_ami_catalog_param_name"></a> [ami\_catalog\_param\_name](#input\_ami\_catalog\_param\_name) | SSM parameter name for AMI catalog JSON. | `string` | `"/app/nonbluegreen/ami_catalog"` | no |
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | Auto Scaling Group name | `string` | n/a | yes |
| <a name="input_auto_apply_ami_updates"></a> [auto\_apply\_ami\_updates](#input\_auto\_apply\_ami\_updates) | Allow Lambda to auto-apply Terraform runs | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | IAM role name for assuming into app account. | `string` | n/a | yes |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | Configuration block for egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | Configuration block for ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | ASG desired capacity | `number` | n/a | yes |
| <a name="input_enable_ami_automation"></a> [enable\_ami\_automation](#input\_enable\_ami\_automation) | Enable AMI automation via Lambda | `bool` | `false` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | n/a | yes |
| <a name="input_lambda_bucket_name"></a> [lambda\_bucket\_name](#input\_lambda\_bucket\_name) | S3 bucket for ALB logs and lambda artifacts | `string` | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Lambda function name for AMI automation | `string` | `null` | no |
| <a name="input_latest_ami_param_name"></a> [latest\_ami\_param\_name](#input\_latest\_ami\_param\_name) | SSM parameter for latest AMI | `string` | n/a | yes |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | n/a | <pre>list(object({<br/>    port              = number<br/>    protocol          = string<br/>    type              = string<br/>    target_group_name = string<br/>    certificate_arn   = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lb_target_group"></a> [lb\_target\_group](#input\_lb\_target\_group) | n/a | <pre>list(object({<br/>    name        = string<br/>    target_type = string<br/>    port        = number<br/>    protocol    = string<br/>    health_check = list(object({<br/>      enabled             = bool<br/>      healthy_threshold   = number<br/>      interval            = number<br/>      matcher             = string<br/>      path                = string<br/>      port                = string<br/>      protocol            = string<br/>      timeout             = number<br/>      unhealthy_threshold = number<br/>    }))<br/>    stickiness = list(object({<br/>      enabled         = bool<br/>      type            = string<br/>      cookie_duration = number<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | ASG maximum size | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | ASG minimum size | `number` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_release_version"></a> [release\_version](#input\_release\_version) | AMI version to deploy (latest or version number) | `string` | `"latest"` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br/>    from                     = number<br/>    to                       = number<br/>    protocol                 = string<br/>    source_security_group_id = string<br/>    description              = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Security group name | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for ALB and ASG | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_catalog_parameter_name"></a> [ami\_catalog\_parameter\_name](#output\_ami\_catalog\_parameter\_name) | n/a |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | n/a |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | n/a |
| <a name="output_latest_ami_parameter_name"></a> [latest\_ami\_parameter\_name](#output\_latest\_ami\_parameter\_name) | n/a |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | n/a |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | n/a |
| <a name="output_lb_target_group_arn"></a> [lb\_target\_group\_arn](#output\_lb\_target\_group\_arn) | n/a |

<!-- END_TF_DOCS -->