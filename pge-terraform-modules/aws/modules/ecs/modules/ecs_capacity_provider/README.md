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
| [aws_ecs_capacity_provider.ecs_capacity_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_instance_warmup_period"></a> [asg\_instance\_warmup\_period](#input\_asg\_instance\_warmup\_period) | Period of time, in seconds, after a newly launched Amazon EC2 instance can contribute to CloudWatch metrics for Auto Scaling group. If this parameter is omitted, the default value of 300 seconds is used. | `number` | `null` | no |
| <a name="input_asg_maximum_scaling_step_size"></a> [asg\_maximum\_scaling\_step\_size](#input\_asg\_maximum\_scaling\_step\_size) | Maximum step adjustment size. A number between 1 and 10,000. | `number` | `null` | no |
| <a name="input_asg_minimum_scaling_step_size"></a> [asg\_minimum\_scaling\_step\_size](#input\_asg\_minimum\_scaling\_step\_size) | Minimum step adjustment size. A number between 1 and 10,000. | `number` | `null` | no |
| <a name="input_asg_status"></a> [asg\_status](#input\_asg\_status) | Whether auto scaling is managed by ECS. Valid values are ENABLED and DISABLED. | `string` | `"ENABLED"` | no |
| <a name="input_asg_target_capacity"></a> [asg\_target\_capacity](#input\_asg\_target\_capacity) | Target utilization for the capacity provider. A number between 1 and 100. | `number` | `null` | no |
| <a name="input_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#input\_autoscaling\_group\_arn) | The Amazon Resource Name (ARN) of the associated auto scaling group. | `string` | n/a | yes |
| <a name="input_ecs_capacity_provider_name"></a> [ecs\_capacity\_provider\_name](#input\_ecs\_capacity\_provider\_name) | Name of the capacity provider. | `string` | n/a | yes |
| <a name="input_managed_termination_protection"></a> [managed\_termination\_protection](#input\_managed\_termination\_protection) | Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens. Valid values are ENABLED and DISABLED. | `string` | `"ENABLED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to ECS Cluster | `map(string)` | `{}` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_capacity_provider_all"></a> [ecs\_capacity\_provider\_all](#output\_ecs\_capacity\_provider\_all) | All attributes of the capacity provider. |
| <a name="output_ecs_capacity_provider_arn"></a> [ecs\_capacity\_provider\_arn](#output\_ecs\_capacity\_provider\_arn) | The Amazon Resource Name (ARN) that identifies the capacity provider. |
| <a name="output_ecs_capacity_provider_id"></a> [ecs\_capacity\_provider\_id](#output\_ecs\_capacity\_provider\_id) | The Amazon Resource Name (ARN) that identifies the capacity provider. |
| <a name="output_ecs_capacity_provider_name"></a> [ecs\_capacity\_provider\_name](#output\_ecs\_capacity\_provider\_name) | Name of the ecs capacity provider. |
| <a name="output_ecs_capacity_provider_tags_all"></a> [ecs\_capacity\_provider\_tags\_all](#output\_ecs\_capacity\_provider\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |

<!-- END_TF_DOCS -->