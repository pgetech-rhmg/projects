<!-- BEGIN_TF_DOCS -->
# AWS ECS module
Terraform module which creates SAF2.0 ECS in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
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
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.step_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.target_tracking_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_autoscaling"></a> [create\_autoscaling](#input\_create\_autoscaling) | Whether to create autoscaling | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting logs | `string` | `null` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum number of tasks that can be running at any one time | `number` | `5` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | The minimum number of tasks that can be running at any one time | `number` | `1` | no |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The identifier of the resource to scale | `string` | `""` | no |
| <a name="input_step_scaling_policy_configuration"></a> [step\_scaling\_policy\_configuration](#input\_step\_scaling\_policy\_configuration) | Configuration for step scaling policy | <pre>object({<br>    adjustment_type         = string<br>    cooldown                = number<br>    metric_aggregation_type = string<br>    step_adjustment = list(object({<br>      metric_interval_lower_bound = number<br>      metric_interval_upper_bound = number<br>      scaling_adjustment          = number<br>    }))<br>  })</pre> | <pre>{<br>  "adjustment_type": "ChangeInCapacity",<br>  "cooldown": 300,<br>  "metric_aggregation_type": "Average",<br>  "step_adjustment": [<br>    {<br>      "metric_interval_lower_bound": 2,<br>      "metric_interval_upper_bound": 3,<br>      "scaling_adjustment": 1<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_step_scaling_policy_name"></a> [step\_scaling\_policy\_name](#input\_step\_scaling\_policy\_name) | The name of the step scaling policy | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no |
| <a name="input_target_tracking_scaling_policy_configuration"></a> [target\_tracking\_scaling\_policy\_configuration](#input\_target\_tracking\_scaling\_policy\_configuration) | Configuration for target tracking scaling policy | <pre>object({<br>    target_value       = number<br>    scale_in_cooldown  = number<br>    scale_out_cooldown = number<br>    disable_scale_in   = bool<br>    predefined_metric_specification = list(object({<br>      predefined_metric_type = string<br>    }))<br>  })</pre> | <pre>{<br>  "disable_scale_in": false,<br>  "predefined_metric_specification": [<br>    {<br>      "predefined_metric_type": "ECSServiceAverageCPUUtilization"<br>    }<br>  ],<br>  "scale_in_cooldown": 300,<br>  "scale_out_cooldown": 300,<br>  "target_value": 50<br>}</pre> | no |
| <a name="input_target_tracking_scaling_policy_name"></a> [target\_tracking\_scaling\_policy\_name](#input\_target\_tracking\_scaling\_policy\_name) | The name of the target tracking scaling policy | `string` | `""` | no |
| <a name="input_use_target_tracking_scaling"></a> [use\_target\_tracking\_scaling](#input\_use\_target\_tracking\_scaling) | Whether to use target tracking scaling policy or step scaling policy | `bool` | `true` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_Appautoscalling_all"></a> [ecs\_Appautoscalling\_all](#output\_ecs\_Appautoscalling\_all) | Map of ECS Appautoscalling |
| <a name="output_ecs_Appautoscalling_arn"></a> [ecs\_Appautoscalling\_arn](#output\_ecs\_Appautoscalling\_arn) | ARN of Appautoscalling target |

<!-- END_TF_DOCS -->