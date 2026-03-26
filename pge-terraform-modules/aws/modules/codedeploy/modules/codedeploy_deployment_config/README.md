<!-- BEGIN_TF_DOCS -->
# AWS CodeDeploy Deployment Config module
Terraform module which creates SAF2.0 CodeDeploy Deployment Config in AWS

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |

## Usage

Usage information can be found in `modules/examples/*`

`cd pge-terraform-modules/modules/examples/*`

`terraform init`

`terraform validate`

`terraform plan`

`terraform apply`

Run `terraform destroy` when you don't need these resources.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codedeploy_deployment_config.deployment_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_config) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_config_compute_platform"></a> [deployment\_config\_compute\_platform](#input\_deployment\_config\_compute\_platform) | The compute platform can either be ECS, Lambda, or Server. | `string` | `"Server"` | no |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | The name of the deployment config. | `string` | n/a | yes |
| <a name="input_minimum_healthy_hosts"></a> [minimum\_healthy\_hosts](#input\_minimum\_healthy\_hosts) | type:<br/>  The type can either be `FLEET_PERCENT` or `HOST_COUNT`.<br/>value:<br/>  The value when the type is `FLEET_PERCENT` represents the minimum number of healthy instances <br/>  as a percentage of the total number of instances in the deployment.<br/>  When the type is `HOST_COUNT`, the value represents the minimum number of healthy instances as an absolute value. | <pre>object({<br/>    type  = string<br/>    value = number<br/>  })</pre> | `null` | no |
| <a name="input_traffic_routing_config"></a> [traffic\_routing\_config](#input\_traffic\_routing\_config) | type:<br/>  Type of traffic routing config. One of `TimeBasedCanary`, `TimeBasedLinear`, `AllAtOnce`.<br/>interval:<br/>  The number of minutes between the first and second traffic shifts of a deployment.<br/>percentage:<br/>  The percentage of traffic to shift in the first increment of a deployment. | <pre>object({<br/>    type       = string<br/>    interval   = number<br/>    percentage = number<br/>  })</pre> | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codedeploy_deployment_config"></a> [codedeploy\_deployment\_config](#output\_codedeploy\_deployment\_config) | Map of codedeploy deployment config. |
| <a name="output_deployment_config_id"></a> [deployment\_config\_id](#output\_deployment\_config\_id) | The AWS Assigned deployment config id. |
| <a name="output_deployment_group_config_name"></a> [deployment\_group\_config\_name](#output\_deployment\_group\_config\_name) | The deployment group's config name. |

<!-- END_TF_DOCS -->