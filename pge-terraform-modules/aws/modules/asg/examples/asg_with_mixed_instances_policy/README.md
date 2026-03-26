<!-- BEGIN_TF_DOCS -->
# AWS ASG with mixed instances policy usage example
Terraform module which creates SAF2.0 ASG with mixed instances policy in AWS.

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
| <a name="module_aws_autoscaling_group"></a> [aws\_autoscaling\_group](#module\_aws\_autoscaling\_group) | ../../modules/asg_with_mixed_instances_policy | n/a |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | app.terraform.io/pgetech/iam/aws | 0.1.1 |
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | app.terraform.io/pgetech/sns/aws | 0.1.1 |
| <a name="module_sns_topic_subscription"></a> [sns\_topic\_subscription](#module\_sns\_topic\_subscription) | app.terraform.io/pgetech/sns/aws//modules/sns_subscription | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_lifecycle_hook.asg_lifecycle_hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_schedule.asg_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_lb_target_group.lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.lb_target_group_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sns_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.subnet_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
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
| <a name="input_asg_force_delete"></a> [asg\_force\_delete](#input\_asg\_force\_delete) | Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate | `bool` | n/a | yes |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The maximum size of the Auto Scaling Group | `number` | n/a | yes |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The minimum size of the Auto Scaling Group | `number` | n/a | yes |
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | The name of the Auto Scaling Group | `string` | n/a | yes |
| <a name="input_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#input\_autoscaling\_policy\_name) | The name of the Policy. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role | `string` | n/a | yes |
| <a name="input_cooldown"></a> [cooldown](#input\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | `number` | n/a | yes |
| <a name="input_default_result"></a> [default\_result](#input\_default\_result) | Defines the action the Auto Scaling group should take when the lifecycle hook timeout elapses or if an unexpected failure occurs | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of EC2 instances that should be running in the group. Default 0. Set to -1 if you don't want to change the desired capacity at the scheduled time. | `number` | n/a | yes |
| <a name="input_end_time"></a> [end\_time](#input\_end\_time) | The time for this action to end, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Endpoint to send data to. The contents vary with the protocol | `list(string)` | `null` | no |
| <a name="input_heartbeat_timeout"></a> [heartbeat\_timeout](#input\_heartbeat\_timeout) | Defines the amount of time, in seconds, that can elapse before the lifecycle hook times out | `number` | n/a | yes |
| <a name="input_iam_aws_service"></a> [iam\_aws\_service](#input\_iam\_aws\_service) | Aws service of the iam role | `list(string)` | n/a | yes |
| <a name="input_iam_name"></a> [iam\_name](#input\_iam\_name) | Name of the iam role | `string` | n/a | yes |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | Policy arn for the iam role | `list(string)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Override the instance type in the Launch Template. | `string` | n/a | yes |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | The description of the key as viewed in AWS console | `string` | n/a | yes |
| <a name="input_kms_name"></a> [kms\_name](#input\_kms\_name) | Unique name | `string` | n/a | yes |
| <a name="input_kms_role"></a> [kms\_role](#input\_kms\_role) | AWS role to administer the KMS key. | `string` | n/a | yes |
| <a name="input_launch_template_specification_id"></a> [launch\_template\_specification\_id](#input\_launch\_template\_specification\_id) | The ID of the launch template. | `string` | n/a | yes |
| <a name="input_launch_template_specification_version"></a> [launch\_template\_specification\_version](#input\_launch\_template\_specification\_version) | Template version | `string` | n/a | yes |
| <a name="input_lb_port"></a> [lb\_port](#input\_lb\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `number` | n/a | yes |
| <a name="input_lb_protocol"></a> [lb\_protocol](#input\_lb\_protocol) | Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `string` | n/a | yes |
| <a name="input_lb_target_group_name"></a> [lb\_target\_group\_name](#input\_lb\_target\_group\_name) | Name of the target group. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_lifecycle_hook_name"></a> [lifecycle\_hook\_name](#input\_lifecycle\_hook\_name) | The name of the lifecycle hook | `string` | n/a | yes |
| <a name="input_lifecycle_transition"></a> [lifecycle\_transition](#input\_lifecycle\_transition) | The instance state to which you want to attach the lifecycle hook. | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the maximum size at the scheduled time. | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `number` | n/a | yes |
| <a name="input_notification_metadata"></a> [notification\_metadata](#input\_notification\_metadata) | Contains additional information that you want to include any time Auto Scaling sends a message to the notification target. | `string` | n/a | yes |
| <a name="input_on_demand_allocation_strategy"></a> [on\_demand\_allocation\_strategy](#input\_on\_demand\_allocation\_strategy) | Strategy to use when launching on-demand instances | `string` | n/a | yes |
| <a name="input_on_demand_base_capacity"></a> [on\_demand\_base\_capacity](#input\_on\_demand\_base\_capacity) | Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances | `number` | n/a | yes |
| <a name="input_on_demand_percentage_above_base_capacity"></a> [on\_demand\_percentage\_above\_base\_capacity](#input\_on\_demand\_percentage\_above\_base\_capacity) | Percentage split between on-demand and Spot instances above the base on-demand capacity | `number` | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | Optional tags | `map(string)` | `{}` | no |
| <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type) | The policy type, either 'SimpleScaling' , 'StepScaling' or 'TargetTrackingScaling'. If this value isn't provided, AWS will default to 'SimpleScaling'. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `string` | n/a | yes |
| <a name="input_scaling_adjustment"></a> [scaling\_adjustment](#input\_scaling\_adjustment) | The number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity. | `number` | n/a | yes |
| <a name="input_scheduled_action_name"></a> [scheduled\_action\_name](#input\_scheduled\_action\_name) | The name of this scaling action. | `string` | n/a | yes |
| <a name="input_sns_protocol"></a> [sns\_protocol](#input\_sns\_protocol) | Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application | `string` | `null` | no |
| <a name="input_snstopic_display_name"></a> [snstopic\_display\_name](#input\_snstopic\_display\_name) | The display name of the SNS topic | `string` | n/a | yes |
| <a name="input_snstopic_name"></a> [snstopic\_name](#input\_snstopic\_name) | name of the SNS topic | `string` | n/a | yes |
| <a name="input_spot_allocation_strategy"></a> [spot\_allocation\_strategy](#input\_spot\_allocation\_strategy) | How to allocate capacity across the Spot pools | `string` | n/a | yes |
| <a name="input_spot_instance_pools"></a> [spot\_instance\_pools](#input\_spot\_instance\_pools) | Number of Spot pools per availability zone to allocate capacity | `number` | n/a | yes |
| <a name="input_spot_max_price"></a> [spot\_max\_price](#input\_spot\_max\_price) | Maximum price per unit hour that the user is willing to pay for the Spot instances | `string` | n/a | yes |
| <a name="input_start_time"></a> [start\_time](#input\_start\_time) | The time for this action to start, in YYYY-MM-DDThh:mm:ssZ format in UTC/GMT only (for example, 2014-06-01T00:00:00Z ). If you try to schedule your action in the past, Auto Scaling returns an error message. | `string` | n/a | yes |
| <a name="input_target_group_name"></a> [target\_group\_name](#input\_target\_group\_name) | Name of the target group. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_template_file_name"></a> [template\_file\_name](#input\_template\_file\_name) | Policy template file in json format | `string` | n/a | yes |
| <a name="input_weighted_capacity"></a> [weighted\_capacity](#input\_weighted\_capacity) | The number of capacity units, which gives the instance type a proportional weight to other instance types. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adjustment_type"></a> [adjustment\_type](#output\_adjustment\_type) | The scaling policy's adjustment type. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN for this Auto Scaling Group |
| <a name="output_autoscaling_policy_arn"></a> [autoscaling\_policy\_arn](#output\_autoscaling\_policy\_arn) | The ARN assigned by AWS to the scaling policy. |
| <a name="output_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#output\_autoscaling\_policy\_name) | The scaling policy's name. |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | The availability zones of the Auto Scaling Group |
| <a name="output_desired_capacity"></a> [desired\_capacity](#output\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group |
| <a name="output_health_check_grace_period"></a> [health\_check\_grace\_period](#output\_health\_check\_grace\_period) | Time after instance comes into service before checking health |
| <a name="output_health_check_type"></a> [health\_check\_type](#output\_health\_check\_type) | Controls how health checking is done |
| <a name="output_id"></a> [id](#output\_id) | The Auto Scaling Group id |
| <a name="output_max_size"></a> [max\_size](#output\_max\_size) | The maximum size of the Auto Scaling Group |
| <a name="output_min_size"></a> [min\_size](#output\_min\_size) | The minimum size of the Auto Scaling Group |
| <a name="output_name"></a> [name](#output\_name) | The name of the Auto Scaling Group |
| <a name="output_policy_type"></a> [policy\_type](#output\_policy\_type) | The scaling policy's type. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the Target Group (matches id). |
| <a name="output_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#output\_target\_group\_arn\_suffix) | ARN suffix for use with CloudWatch Metrics. |
| <a name="output_target_group_id"></a> [target\_group\_id](#output\_target\_group\_id) | ARN of the Target Group (matches arn). |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the Target Group. |
| <a name="output_target_group_tags_all"></a> [target\_group\_tags\_all](#output\_target\_group\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |


<!-- END_TF_DOCS -->