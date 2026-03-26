<!-- BEGIN_TF_DOCS -->
# AWS ASG with launch template module
Terraform module which creates SAF2.0 ASG launch template in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.0 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_launch_template.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adjustment_type"></a> [adjustment\_type](#input\_adjustment\_type) | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity. | `string` | `null` | no |
| <a name="input_asg_availability_zones"></a> [asg\_availability\_zones](#input\_asg\_availability\_zones) | A list of one or more availability zones for the group | `list(string)` | `null` | no |
| <a name="input_asg_capacity_rebalance"></a> [asg\_capacity\_rebalance](#input\_asg\_capacity\_rebalance) | Indicates whether capacity rebalance is enabled. | `bool` | `false` | no |
| <a name="input_asg_default_cooldown"></a> [asg\_default\_cooldown](#input\_asg\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | `number` | `null` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group | `number` | `null` | no |
| <a name="input_asg_enabled_metrics"></a> [asg\_enabled\_metrics](#input\_asg\_enabled\_metrics) | A list of metrics to collect | `list(string)` | `null` | no |
| <a name="input_asg_force_delete"></a> [asg\_force\_delete](#input\_asg\_force\_delete) | Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. | `bool` | `false` | no |
| <a name="input_asg_health_check_grace_period"></a> [asg\_health\_check\_grace\_period](#input\_asg\_health\_check\_grace\_period) | Time after instance comes into service before checking health. | `number` | `300` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | Controls how health checking is done. | `string` | `null` | no |
| <a name="input_asg_load_balancers"></a> [asg\_load\_balancers](#input\_asg\_load\_balancers) | A list of elastic load balancer names to add to the autoscaling group names | `list(string)` | `null` | no |
| <a name="input_asg_max_instance_lifetime"></a> [asg\_max\_instance\_lifetime](#input\_asg\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service | `number` | `0` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The maximum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_asg_min_elb_capacity"></a> [asg\_min\_elb\_capacity](#input\_asg\_min\_elb\_capacity) | Setting this causes Terraform to wait for this number of instances from this Auto Scaling Group to show up healthy in the ELB only on creation | `number` | `null` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The minimum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | The name of the Auto Scaling Group | `string` | `null` | no |
| <a name="input_asg_name_prefix"></a> [asg\_name\_prefix](#input\_asg\_name\_prefix) | Creates a unique name beginning with the specified prefix. | `string` | `null` | no |
| <a name="input_asg_placement_group"></a> [asg\_placement\_group](#input\_asg\_placement\_group) | The name of the placement group into which you'll launch your instances | `string` | `null` | no |
| <a name="input_asg_protect_from_scale_in"></a> [asg\_protect\_from\_scale\_in](#input\_asg\_protect\_from\_scale\_in) | Allows setting instance protection | `string` | `null` | no |
| <a name="input_asg_service_linked_role_arn"></a> [asg\_service\_linked\_role\_arn](#input\_asg\_service\_linked\_role\_arn) | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `null` | no |
| <a name="input_asg_suspended_processes"></a> [asg\_suspended\_processes](#input\_asg\_suspended\_processes) | A list of processes to suspend for the Auto Scaling Group | `list(string)` | `null` | no |
| <a name="input_asg_target_group_arns"></a> [asg\_target\_group\_arns](#input\_asg\_target\_group\_arns) | A set of aws\_alb\_target\_group ARNs, for use with Application or Network Load Balancing | `list(string)` | `null` | no |
| <a name="input_asg_termination_policies"></a> [asg\_termination\_policies](#input\_asg\_termination\_policies) | A list of policies to decide how the instances in the Auto Scaling Group should be terminated. | `string` | `"Default"` | no |
| <a name="input_asg_vpc_zone_identifier"></a> [asg\_vpc\_zone\_identifier](#input\_asg\_vpc\_zone\_identifier) | A list of subnet IDs to launch resources in | `list(string)` | `null` | no |
| <a name="input_asg_wait_for_capacity_timeout"></a> [asg\_wait\_for\_capacity\_timeout](#input\_asg\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out | `string` | `null` | no |
| <a name="input_asg_wait_for_elb_capacity"></a> [asg\_wait\_for\_elb\_capacity](#input\_asg\_wait\_for\_elb\_capacity) | Setting this will cause Terraform to wait for exactly this number of healthy instances from this Auto Scaling Group in all attached load balancers on both create and update operations | `number` | `null` | no |
| <a name="input_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#input\_autoscaling\_policy\_name) | The name of the Policy. | `string` | n/a | yes |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | `list(any)` | `[]` | no |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | n/a | `any` | `null` | no |
| <a name="input_checkpoint_delay"></a> [checkpoint\_delay](#input\_checkpoint\_delay) | The number of seconds to wait after a checkpoint. | `string` | `null` | no |
| <a name="input_checkpoint_percentages"></a> [checkpoint\_percentages](#input\_checkpoint\_percentages) | List of percentages for each checkpoint. | `list(string)` | `null` | no |
| <a name="input_cooldown"></a> [cooldown](#input\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | `number` | `null` | no |
| <a name="input_cpu_options"></a> [cpu\_options](#input\_cpu\_options) | The CPU options for the instance | `map(string)` | `{}` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Determines whether to create launch template or not | `bool` | `true` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | Customize the credit specification of the instance | `map(string)` | `{}` | no |
| <a name="input_disable_api_stop"></a> [disable\_api\_stop](#input\_disable\_api\_stop) | This is used for EC2 Instance Stop Protection. | `bool` | `false` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | This is used for EC2 Instance Termination Protection. | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | n/a | `bool` | `false` | no |
| <a name="input_estimated_instance_warmup"></a> [estimated\_instance\_warmup](#input\_estimated\_instance\_warmup) | The estimated time, in seconds, until a newly launched instance will contribute CloudWatch metrics. Without a value, AWS will default to the group's specified cooldown period. | `number` | `null` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The name attribute of the IAM instance profile to associate with launched instances | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | n/a | `string` | `""` | no |
| <a name="input_initial_lifecycle_hooks"></a> [initial\_lifecycle\_hooks](#input\_initial\_lifecycle\_hooks) | One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource | `list(map(string))` | `[]` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | n/a | `string` | `"stop"` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | The market (purchasing) option for the instance | <pre>map(object({<br>    market_type = string<br>    spot_options = object({<br>      block_duration_minutes         = number<br>      instance_interruption_behavior = string<br>      max_price                      = number<br>      spot_instance_type             = string<br>      valid_until                    = number<br>    })<br>  }))</pre> | `{}` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name to be used on EC2 instance created | `string` | `"asg_launch_template"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `null` | no |
| <a name="input_instance_warmup"></a> [instance\_warmup](#input\_instance\_warmup) | The number of seconds until a newly launched instance is configured and ready to use. | `string` | `null` | no |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | n/a | `string` | `""` | no |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | Name of an existing launch template to be used (created outside of this module) | `string` | `null` | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Name of the launch template. | `string` | `""` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Version of the launch template, values for launch\_template\_version should be $Latest or $Default. | `string` | `"$Latest"` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options for the instance | `map(string)` | `{}` | no |
| <a name="input_min_healthy_percentage"></a> [min\_healthy\_percentage](#input\_min\_healthy\_percentage) | The amount of capacity in the Auto Scaling group that must remain healthy during an instance refresh to allow the operation to continue, as a percentage of the desired capacity of the Auto Scaling group. | `string` | `90` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Customize network interfaces to be attached at instance boot time | `list(any)` | `[]` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | The placement of the instance | `map(string)` | `{}` | no |
| <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type) | The policy type, either 'SimpleScaling' , 'StepScaling' or 'TargetTrackingScaling'. If this value isn't provided, AWS will default to 'SimpleScaling'. | `string` | `"SimpleScaling"` | no |
| <a name="input_ram_disk_id"></a> [ram\_disk\_id](#input\_ram\_disk\_id) | n/a | `string` | `""` | no |
| <a name="input_scaling_adjustment"></a> [scaling\_adjustment](#input\_scaling\_adjustment) | The number of instances by which to scale. adjustment\_type determines the interpretation of this number (e.g., as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity. | `number` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to associate | `list(string)` | `[]` | no |
| <a name="input_strategy"></a> [strategy](#input\_strategy) | The strategy to use for instance refresh | `string` | `"Rolling"` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | The tags to apply to the resources during launch | <pre>list(object({<br>    resource_type = string<br>    tags          = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "resource_type": "instance",<br>    "tags": {}<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Set of maps containing resource tags. | `map(string)` | n/a | yes |
| <a name="input_triggers"></a> [triggers](#input\_triggers) | Set of additional property names that will trigger an Instance Refresh | `list(string)` | `null` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | Whether to update Default Version each update. Conflicts with default\_version. | `bool` | `null` | no |
| <a name="input_use_mixed_instances_policy"></a> [use\_mixed\_instances\_policy](#input\_use\_mixed\_instances\_policy) | Determines whether to use a mixed instances policy in the autoscaling group or not | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance | `string` | `null` | no |
| <a name="input_warm_pool"></a> [warm\_pool](#input\_warm\_pool) | If this block is configured, add a Warm Pool to the specified Auto Scaling group | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adjustment_type"></a> [adjustment\_type](#output\_adjustment\_type) | The scaling policy's adjustment type. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN for this Auto Scaling Group |
| <a name="output_asg_autoscaling_group"></a> [asg\_autoscaling\_group](#output\_asg\_autoscaling\_group) | Map of ASG group object |
| <a name="output_asg_autoscaling_policy"></a> [asg\_autoscaling\_policy](#output\_asg\_autoscaling\_policy) | Map of ASG policy object |
| <a name="output_asg_launch_template"></a> [asg\_launch\_template](#output\_asg\_launch\_template) | Map of ASG launch template object |
| <a name="output_asg_launch_template_arn"></a> [asg\_launch\_template\_arn](#output\_asg\_launch\_template\_arn) | Amazon Resource Name (ARN) of the launch template |
| <a name="output_asg_launch_template_id"></a> [asg\_launch\_template\_id](#output\_asg\_launch\_template\_id) | The ID of the launch template |
| <a name="output_asg_launch_template_latest_version"></a> [asg\_launch\_template\_latest\_version](#output\_asg\_launch\_template\_latest\_version) | The latest version of the launch template |
| <a name="output_autoscaling_policy_arn"></a> [autoscaling\_policy\_arn](#output\_autoscaling\_policy\_arn) | The ARN assigned by AWS to the scaling policy. |
| <a name="output_autoscaling_policy_name"></a> [autoscaling\_policy\_name](#output\_autoscaling\_policy\_name) | The scaling policy's name. |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | The availability zones of the Auto Scaling Group |
| <a name="output_default_cooldown"></a> [default\_cooldown](#output\_default\_cooldown) | Time between a scaling activity and the succeeding scaling activity |
| <a name="output_desired_capacity"></a> [desired\_capacity](#output\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group |
| <a name="output_health_check_grace_period"></a> [health\_check\_grace\_period](#output\_health\_check\_grace\_period) | Time after instance comes into service before checking health |
| <a name="output_health_check_type"></a> [health\_check\_type](#output\_health\_check\_type) | Controls how health checking is done |
| <a name="output_id"></a> [id](#output\_id) | The Auto Scaling Group id |
| <a name="output_launch_configuration"></a> [launch\_configuration](#output\_launch\_configuration) | The launch configuration of the Auto Scaling Group |
| <a name="output_max_size"></a> [max\_size](#output\_max\_size) | The maximum size of the Auto Scaling Group |
| <a name="output_min_size"></a> [min\_size](#output\_min\_size) | The minimum size of the Auto Scaling Group |
| <a name="output_name"></a> [name](#output\_name) | The name of the Auto Scaling Group |
| <a name="output_policy_type"></a> [policy\_type](#output\_policy\_type) | The scaling policy's type. |


<!-- END_TF_DOCS -->