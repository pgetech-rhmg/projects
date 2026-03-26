<!-- BEGIN_TF_DOCS -->
# AWS ASG with launch template usage example
Terraform module which creates SAF2.0 ASG with launch template in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
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
| <a name="module_asg_with_launch_template"></a> [asg\_with\_launch\_template](#module\_asg\_with\_launch\_template) | ../../ | n/a |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | app.terraform.io/pgetech/security-group/aws | 0.1.2 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_lifecycle_hook.asg_lifecycle_hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_schedule.asg_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sns_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.golden_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.subnet_id1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_adjustment_type"></a> [adjustment\_type](#input\_adjustment\_type) | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity. | `string` | n/a | yes |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group | `number` | n/a | yes |
| <a name="input_asg_force_delete"></a> [asg\_force\_delete](#input\_asg\_force\_delete) | Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. | `bool` | n/a | yes |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The maximum size of the Auto Scaling Group | `number` | n/a | yes |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The minimum size of the Auto Scaling Group | `number` | n/a | yes |
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | The name of the Auto Scaling Group | `string` | n/a | yes |
| <a name="input_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#input\_autoscaling\_policy\_name) | The name of the Policy. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to assume | `string` | n/a | yes |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | `list(any)` | `[]` | no |
| <a name="input_cidr_egress_rules"></a> [cidr\_egress\_rules](#input\_cidr\_egress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_cidr_ingress_rules"></a> [cidr\_ingress\_rules](#input\_cidr\_ingress\_rules) | n/a | <pre>list(object({<br>    from             = number<br>    to               = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    description      = string<br>  }))</pre> | n/a | yes |
| <a name="input_cooldown"></a> [cooldown](#input\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | `number` | n/a | yes |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Determines whether to create launch template or not | `bool` | `true` | no |
| <a name="input_default_result"></a> [default\_result](#input\_default\_result) | Defines the action the Auto Scaling group should take when the lifecycle hook timeout elapses or if an unexpected failure occurs | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group | `number` | n/a | yes |
| <a name="input_end_time"></a> [end\_time](#input\_end\_time) | The time for this action to end, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | `null` | no |
| <a name="input_heartbeat_timeout"></a> [heartbeat\_timeout](#input\_heartbeat\_timeout) | Defines the amount of time, in seconds, that can elapse before the lifecycle hook times out | `number` | n/a | yes |
| <a name="input_iam_aws_service"></a> [iam\_aws\_service](#input\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The size of instance to launch | `string` | `null` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Creates a unique name beginning with the specified prefix. | `string` | n/a | yes |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Version of the launch template, values for launch\_template\_version should be $Latest or $Default. | `string` | `"$Default"` | no |
| <a name="input_lifecycle_hook_name"></a> [lifecycle\_hook\_name](#input\_lifecycle\_hook\_name) | The name of the lifecycle hook | `string` | n/a | yes |
| <a name="input_lifecycle_transition"></a> [lifecycle\_transition](#input\_lifecycle\_transition) | The instance state to which you want to attach the lifecycle hook. | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the maximum size at the scheduled time. | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `number` | n/a | yes |
| <a name="input_notification_metadata"></a> [notification\_metadata](#input\_notification\_metadata) | Contains additional information that you want to include any time Auto Scaling sends a message to the notification target. | `string` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_parameter_golden_ami_name"></a> [parameter\_golden\_ami\_name](#input\_parameter\_golden\_ami\_name) | The name given in the parameter store for the golden ami | `string` | n/a | yes |
| <a name="input_policy_file_name"></a> [policy\_file\_name](#input\_policy\_file\_name) | Valid JSON document representing a resource policy | `string` | n/a | yes |
| <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type) | The policy type, either 'SimpleScaling' , 'StepScaling' or 'TargetTrackingScaling'. If this value isn't provided, AWS will default to 'SimpleScaling'. | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application | `string` | `null` | no |
| <a name="input_scaling_adjustment"></a> [scaling\_adjustment](#input\_scaling\_adjustment) | The number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity. | `number` | n/a | yes |
| <a name="input_scheduled_action_name"></a> [scheduled\_action\_name](#input\_scheduled\_action\_name) | The name of this scaling action. | `string` | n/a | yes |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | Description for the security group | `string` | n/a | yes |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |
| <a name="input_start_time"></a> [start\_time](#input\_start\_time) | The time for this action to start, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message. | `string` | n/a | yes |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Policy template file in json format | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adjustment_type"></a> [adjustment\_type](#output\_adjustment\_type) | The scaling policy's adjustment type. |
| <a name="output_asg_arn"></a> [asg\_arn](#output\_asg\_arn) | The ARN for this Auto Scaling Group |
| <a name="output_asg_availability_zones"></a> [asg\_availability\_zones](#output\_asg\_availability\_zones) | The availability zones of the Auto Scaling Group |
| <a name="output_asg_id"></a> [asg\_id](#output\_asg\_id) | The Auto Scaling Group id |
| <a name="output_asg_launch_template_arn"></a> [asg\_launch\_template\_arn](#output\_asg\_launch\_template\_arn) | Amazon Resource Name (ARN) of the launch template |
| <a name="output_asg_launch_template_id"></a> [asg\_launch\_template\_id](#output\_asg\_launch\_template\_id) | The ID of the launch template |
| <a name="output_asg_launch_template_latest_version"></a> [asg\_launch\_template\_latest\_version](#output\_asg\_launch\_template\_latest\_version) | The latest version of the launch template |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | The name of the Auto Scaling Group |
| <a name="output_autoscaling_policy_arn"></a> [autoscaling\_policy\_arn](#output\_autoscaling\_policy\_arn) | The ARN assigned by AWS to the scaling policy. |
| <a name="output_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#output\_autoscaling\_policy\_name) | The scaling policy's name. |
| <a name="output_default_cooldown"></a> [default\_cooldown](#output\_default\_cooldown) | Time between a scaling activity and the succeeding scaling activity |
| <a name="output_desired_capacity"></a> [desired\_capacity](#output\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group |
| <a name="output_health_check_grace_period"></a> [health\_check\_grace\_period](#output\_health\_check\_grace\_period) | Time after instance comes into service before checking health |
| <a name="output_health_check_type"></a> [health\_check\_type](#output\_health\_check\_type) | Controls how health checking is done |
| <a name="output_launch_configuration"></a> [launch\_configuration](#output\_launch\_configuration) | The launch configuration of the Auto Scaling Group |
| <a name="output_max_size"></a> [max\_size](#output\_max\_size) | The maximum size of the Auto Scaling Group |
| <a name="output_min_size"></a> [min\_size](#output\_min\_size) | The minimum size of the Auto Scaling Group |
| <a name="output_policy_type"></a> [policy\_type](#output\_policy\_type) | The scaling policy's type. |


<!-- END_TF_DOCS -->