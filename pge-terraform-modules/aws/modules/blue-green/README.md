<!-- BEGIN_TF_DOCS -->


Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.4.0 |
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
| <a name="module_alb_baseline"></a> [alb\_baseline](#module\_alb\_baseline) | app.terraform.io/pgetech/alb/aws//modules/internal_alb_bluegreen | 0.1.3 |
| <a name="module_asg_blue"></a> [asg\_blue](#module\_asg\_blue) | app.terraform.io/pgetech/asg/aws | 0.1.3 |
| <a name="module_asg_green"></a> [asg\_green](#module\_asg\_green) | app.terraform.io/pgetech/asg/aws | 0.1.3 |
| <a name="module_aws_iam_role_bluegreen_testing"></a> [aws\_iam\_role\_bluegreen\_testing](#module\_aws\_iam\_role\_bluegreen\_testing) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_lambda_lambda_s3_bucket"></a> [lambda\_lambda\_s3\_bucket](#module\_lambda\_lambda\_s3\_bucket) | app.terraform.io/pgetech/lambda/aws//modules/lambda_s3_bucket | 0.1.3 |
| <a name="module_lambda_log_group"></a> [lambda\_log\_group](#module\_lambda\_log\_group) | app.terraform.io/pgetech/cloudwatch/aws//modules/log-group | 0.1.3 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | app.terraform.io/pgetech/s3/aws | 0.1.3 |
| <a name="module_secretsmanager"></a> [secretsmanager](#module\_secretsmanager) | app.terraform.io/pgetech/secretsmanager/aws | 0.1.3 |
| <a name="module_security-group"></a> [security-group](#module\_security-group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_ssm_ami_catalog"></a> [ssm\_ami\_catalog](#module\_ssm\_ami\_catalog) | app.terraform.io/pgetech/ssm/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.parameter_store_update](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_instance_profile.profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_lambda_alias.dev_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_function_event_invoke_config.lambda_retry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_object.lambda_zip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.bluegreen_testing_combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.ami_catalog_param](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.latest_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number | `string` | n/a | yes |
| <a name="input_alb_log_prefix"></a> [alb\_log\_prefix](#input\_alb\_log\_prefix) | S3 prefix for ALB access logs | `string` | `"alb-logs"` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Name of the alb | `string` | n/a | yes |
| <a name="input_ami_catalog_param_name"></a> [ami\_catalog\_param\_name](#input\_ami\_catalog\_param\_name) | SSM parameter holding AMI catalog JSON | `string` | n/a | yes |
| <a name="input_asg_adjustment_type"></a> [asg\_adjustment\_type](#input\_asg\_adjustment\_type) | n/a | `string` | `"ChangeInCapacity"` | no |
| <a name="input_asg_cooldown"></a> [asg\_cooldown](#input\_asg\_cooldown) | n/a | `number` | `200` | no |
| <a name="input_asg_force_delete"></a> [asg\_force\_delete](#input\_asg\_force\_delete) | Force delete ASG | `bool` | `true` | no |
| <a name="input_asg_policy_type"></a> [asg\_policy\_type](#input\_asg\_policy\_type) | n/a | `string` | `"SimpleScaling"` | no |
| <a name="input_asg_scaling_adjustment"></a> [asg\_scaling\_adjustment](#input\_asg\_scaling\_adjustment) | n/a | `number` | `1` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | n/a | `bool` | `true` | no |
| <a name="input_auto_apply_ami_updates"></a> [auto\_apply\_ami\_updates](#input\_auto\_apply\_ami\_updates) | Auto-apply Terraform runs triggered by AMI updates | `bool` | `false` | no |
| <a name="input_blue_asg_name"></a> [blue\_asg\_name](#input\_blue\_asg\_name) | Name of blue ASG | `string` | n/a | yes |
| <a name="input_blue_autoscaling_policy_name"></a> [blue\_autoscaling\_policy\_name](#input\_blue\_autoscaling\_policy\_name) | n/a | `string` | `"scale-blue"` | no |
| <a name="input_blue_desired_capacity"></a> [blue\_desired\_capacity](#input\_blue\_desired\_capacity) | Desired capacity for blue ASG | `number` | n/a | yes |
| <a name="input_blue_launch_template_name"></a> [blue\_launch\_template\_name](#input\_blue\_launch\_template\_name) | n/a | `string` | `"blue-lt"` | no |
| <a name="input_blue_max_size"></a> [blue\_max\_size](#input\_blue\_max\_size) | Maximum size for blue ASG | `number` | n/a | yes |
| <a name="input_blue_min_size"></a> [blue\_min\_size](#input\_blue\_min\_size) | Minimum size for blue ASG | `number` | n/a | yes |
| <a name="input_blue_mode"></a> [blue\_mode](#input\_blue\_mode) | How blue AMI is selected (relative\_to\_selected \| relative\_to\_latest \| pinned) | `string` | `"relative_to_selected"` | no |
| <a name="input_blue_pinned_ami_id"></a> [blue\_pinned\_ami\_id](#input\_blue\_pinned\_ami\_id) | Pinned AMI ID for blue when blue\_mode = pinned | `string` | `""` | no |
| <a name="input_bluegreen_iam_role_name"></a> [bluegreen\_iam\_role\_name](#input\_bluegreen\_iam\_role\_name) | IAM role name for Blue-Green AMI automation | `string` | `"ami_bg_test"` | no |
| <a name="input_bluegreen_iam_services"></a> [bluegreen\_iam\_services](#input\_bluegreen\_iam\_services) | AWS services allowed to assume the Blue-Green IAM role | `list(string)` | <pre>[<br/>  "ec2.amazonaws.com",<br/>  "lambda.amazonaws.com"<br/>]</pre> | no |
| <a name="input_bluegreen_instance_profile_name"></a> [bluegreen\_instance\_profile\_name](#input\_bluegreen\_instance\_profile\_name) | IAM instance profile name used by blue/green ASGs | `string` | `"instance-profile-bg"` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | Configuration block for egress rules. Can be specified multiple times for each egress rule. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | Configuration block for ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br/>    from             = number<br/>    to               = number<br/>    protocol         = string<br/>    cidr_blocks      = list(string)<br/>    ipv6_cidr_blocks = list(string)<br/>    prefix_list_ids  = list(string)<br/>    description      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | n/a | `bool` | `true` | no |
| <a name="input_enable_ami_automation"></a> [enable\_ami\_automation](#input\_enable\_ami\_automation) | Enable AMI automation via Lambda | `bool` | `false` | no |
| <a name="input_green_asg_name"></a> [green\_asg\_name](#input\_green\_asg\_name) | Name of green ASG | `string` | n/a | yes |
| <a name="input_green_autoscaling_policy_name"></a> [green\_autoscaling\_policy\_name](#input\_green\_autoscaling\_policy\_name) | n/a | `string` | `"scale-green"` | no |
| <a name="input_green_desired_capacity"></a> [green\_desired\_capacity](#input\_green\_desired\_capacity) | Desired capacity for green ASG | `number` | n/a | yes |
| <a name="input_green_launch_template_name"></a> [green\_launch\_template\_name](#input\_green\_launch\_template\_name) | n/a | `string` | `"green-lt"` | no |
| <a name="input_green_max_size"></a> [green\_max\_size](#input\_green\_max\_size) | Maximum size for green ASG | `number` | n/a | yes |
| <a name="input_green_min_size"></a> [green\_min\_size](#input\_green\_min\_size) | Minimum size for green ASG | `number` | n/a | yes |
| <a name="input_green_percent"></a> [green\_percent](#input\_green\_percent) | Percentage of traffic routed to green | `number` | `10` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t3.micro"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Optional KMS key ARN | `string` | `null` | no |
| <a name="input_lambda_alias_name"></a> [lambda\_alias\_name](#input\_lambda\_alias\_name) | Lambda alias name | `string` | `"dev"` | no |
| <a name="input_lambda_bucket_name"></a> [lambda\_bucket\_name](#input\_lambda\_bucket\_name) | S3 bucket for Lambda artifacts and ALB logs | `string` | n/a | yes |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Lambda function name for AMI automation | `string` | `null` | no |
| <a name="input_lambda_handler"></a> [lambda\_handler](#input\_lambda\_handler) | Lambda handler | `string` | `"lambda.lambda_handler"` | no |
| <a name="input_lambda_max_event_age_seconds"></a> [lambda\_max\_event\_age\_seconds](#input\_lambda\_max\_event\_age\_seconds) | Maximum event age for Lambda invocation | `number` | `3600` | no |
| <a name="input_lambda_max_retry_attempts"></a> [lambda\_max\_retry\_attempts](#input\_lambda\_max\_retry\_attempts) | Maximum Lambda retry attempts | `number` | `2` | no |
| <a name="input_lambda_publish"></a> [lambda\_publish](#input\_lambda\_publish) | Whether to publish a new Lambda version | `bool` | `true` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Lambda runtime | `string` | `"python3.9"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | `900` | no |
| <a name="input_latest_ami_param_name"></a> [latest\_ami\_param\_name](#input\_latest\_ami\_param\_name) | SSM parameter holding latest AMI ID | `string` | n/a | yes |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | n/a | `string` | `"$Latest"` | no |
| <a name="input_lb_listener_https"></a> [lb\_listener\_https](#input\_lb\_listener\_https) | n/a | <pre>list(object({<br/>    port              = number<br/>    protocol          = string<br/>    type              = string<br/>    target_group_name = string<br/>    certificate_arn   = string<br/>  }))</pre> | n/a | yes |
| <a name="input_lb_target_group"></a> [lb\_target\_group](#input\_lb\_target\_group) | n/a | <pre>list(object({<br/>    name        = string<br/>    target_type = string<br/>    port        = number<br/>    protocol    = string<br/>    health_check = list(object({<br/>      enabled             = bool<br/>      healthy_threshold   = number<br/>      interval            = number<br/>      matcher             = string<br/>      path                = string<br/>      port                = string<br/>      protocol            = string<br/>      timeout             = number<br/>      unhealthy_threshold = number<br/>    }))<br/>    stickiness = list(object({<br/>      enabled         = bool<br/>      type            = string<br/>      cookie_duration = number<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_nic_device_index"></a> [nic\_device\_index](#input\_nic\_device\_index) | n/a | `number` | `0` | no |
| <a name="input_parameter_store_event_description"></a> [parameter\_store\_event\_description](#input\_parameter\_store\_event\_description) | n/a | `string` | `"Trigger lambda when the golden ami parameter is updated"` | no |
| <a name="input_release_version"></a> [release\_version](#input\_release\_version) | AMI version to deploy (latest or version number) | `string` | `"latest"` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | cloud watch retention\_in\_days | `number` | `90` | no |
| <a name="input_secret_string"></a> [secret\_string](#input\_secret\_string) | Specifies text data that you want to encrypt and store in this version of the secret | `string` | `"aaaa"` | no |
| <a name="input_secret_version_enabled"></a> [secret\_version\_enabled](#input\_secret\_version\_enabled) | Specifies if versioning is set or not | `bool` | `true` | no |
| <a name="input_secretsmanager_description"></a> [secretsmanager\_description](#input\_secretsmanager\_description) | Description of the secret | `string` | `"add your Terraform token in secret_string value"` | no |
| <a name="input_secretsmanager_name"></a> [secretsmanager\_name](#input\_secretsmanager\_name) | Name of the new secret | `string` | `"TFC_API_TOKEN"` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Configuration block for nested security groups ingress rules. Can be specified multiple times for each ingress rule. | <pre>list(object({<br/>    from                     = number<br/>    to                       = number<br/>    protocol                 = string<br/>    source_security_group_id = string<br/>    description              = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Security group name | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for ALB and ASGs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_tfc_org_name"></a> [tfc\_org\_name](#input\_tfc\_org\_name) | Terraform Cloud organization name | `string` | `"pgetech"` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | n/a | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for ALB and ASGs | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the Application Load Balancer |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_ami_catalog_ssm_parameter"></a> [ami\_catalog\_ssm\_parameter](#output\_ami\_catalog\_ssm\_parameter) | SSM parameter name for AMI catalog |
| <a name="output_blue_ami_id"></a> [blue\_ami\_id](#output\_blue\_ami\_id) | AMI ID used by Blue ASG |
| <a name="output_blue_asg_name"></a> [blue\_asg\_name](#output\_blue\_asg\_name) | Blue Auto Scaling Group name |
| <a name="output_blue_launch_template_name"></a> [blue\_launch\_template\_name](#output\_blue\_launch\_template\_name) | Launch template name for Blue ASG |
| <a name="output_green_ami_id"></a> [green\_ami\_id](#output\_green\_ami\_id) | AMI ID used by Green ASG |
| <a name="output_green_asg_name"></a> [green\_asg\_name](#output\_green\_asg\_name) | Green Auto Scaling Group name |
| <a name="output_green_launch_template_name"></a> [green\_launch\_template\_name](#output\_green\_launch\_template\_name) | Launch template name for Green ASG |
| <a name="output_green_traffic_percentage"></a> [green\_traffic\_percentage](#output\_green\_traffic\_percentage) | Percentage of traffic routed to Green |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | AMI automation Lambda ARN |
| <a name="output_latest_ami_ssm_parameter"></a> [latest\_ami\_ssm\_parameter](#output\_latest\_ami\_ssm\_parameter) | SSM parameter name for latest AMI |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | Target group ARNs for blue and green |

<!-- END_TF_DOCS -->