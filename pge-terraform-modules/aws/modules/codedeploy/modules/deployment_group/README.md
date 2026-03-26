<!-- BEGIN_TF_DOCS -->
# AWS CodeDeploy Deployment Group module
Terraform module which creates SAF2.0 CodeDeploy Deployment Group in AWS

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_validate_tags"></a> [validate\_tags](#module\_validate\_tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |
| <a name="module_ws"></a> [ws](#module\_ws) | app.terraform.io/pgetech/utils/aws//modules/workspace-info | 0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codedeploy_deployment_group.deployment_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_configuration_alarms"></a> [alarm\_configuration\_alarms](#input\_alarm\_configuration\_alarms) | A list of alarms configured for the deployment group. | `list(string)` | `[]` | no |
| <a name="input_alarm_configuration_enabled"></a> [alarm\_configuration\_enabled](#input\_alarm\_configuration\_enabled) | Indicates whether the alarm configuration is enabled. This option is useful when you want to temporarily deactivate alarm monitoring for a deployment group without having to add the same alarms again later. | `bool` | `false` | no |
| <a name="input_alarm_configuration_ignore_poll_alarm_failure"></a> [alarm\_configuration\_ignore\_poll\_alarm\_failure](#input\_alarm\_configuration\_ignore\_poll\_alarm\_failure) | Indicates whether a deployment should continue if information about the current state of alarms cannot be retrieved from CloudWatch. | `bool` | `false` | no |
| <a name="input_auto_rollback_configuration_enabled"></a> [auto\_rollback\_configuration\_enabled](#input\_auto\_rollback\_configuration\_enabled) | Indicates whether a defined automatic rollback configuration is currently enabled for this Deployment Group. If you enable automatic rollback, you must specify at least one event type. | `bool` | `false` | no |
| <a name="input_auto_rollback_configuration_events"></a> [auto\_rollback\_configuration\_events](#input\_auto\_rollback\_configuration\_events) | The event type or types that trigger a rollback. Supported types are DEPLOYMENT\_FAILURE and DEPLOYMENT\_STOP\_ON\_ALARM. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_groups"></a> [autoscaling\_groups](#input\_autoscaling\_groups) | Autoscaling groups associated with the deployment group. | `list(string)` | `[]` | no |
| <a name="input_blue_green_deployment_config"></a> [blue\_green\_deployment\_config](#input\_blue\_green\_deployment\_config) | action\_on\_timeout:<br/>When to reroute traffic from an original environment to a replacement environment in a blue/green deployment.<br/>Valid values are CONTINUE\_DEPLOYMENT and STOP\_DEPLOYMENT.<br/>wait\_time\_in\_minutes:<br/>The number of minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually.<br/>action:<br/>The method used to add instances to a replacement environment.<br/>Valid values are DISCOVER\_EXISTING and COPY\_AUTO\_SCALING\_GROUP.<br/>action:<br/>The action to take on instances in the original environment after a successful blue/green deployment.<br/>Valid values are TERMINATE and KEEP\_ALIVE.<br/>termination\_wait\_time\_in\_minutes:<br/>The number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment. | `any` | `[]` | no |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | The name of the group's deployment config. | `string` | `"CodeDeployDefault.OneAtATime"` | no |
| <a name="input_deployment_group_app_name"></a> [deployment\_group\_app\_name](#input\_deployment\_group\_app\_name) | The name of the application. | `string` | n/a | yes |
| <a name="input_deployment_group_name"></a> [deployment\_group\_name](#input\_deployment\_group\_name) | The name of the deployment group. | `string` | n/a | yes |
| <a name="input_deployment_group_service_role_arn"></a> [deployment\_group\_service\_role\_arn](#input\_deployment\_group\_service\_role\_arn) | The service role ARN that allows deployments. | `string` | n/a | yes |
| <a name="input_deployment_style"></a> [deployment\_style](#input\_deployment\_style) | Configuration of the type of deployment, either in-place or blue/green, <br/>you want to run and whether to route deployment traffic behind a load balancer.<br/>deployment\_option:<br/>  Indicates whether to route deployment traffic behind a load balancer. <br/>  Possible values: `WITH_TRAFFIC_CONTROL`, `WITHOUT_TRAFFIC_CONTROL`.<br/>  Default is WITHOUT\_TRAFFIC\_CONTROL.<br/>deployment\_type:<br/>  Indicates whether to run an in-place deployment or a blue/green deployment.<br/>  Possible values: `IN_PLACE`, `BLUE_GREEN`.<br/>  Default is IN\_PLACE. | `any` | `[]` | no |
| <a name="input_ec2_tag_filter"></a> [ec2\_tag\_filter](#input\_ec2\_tag\_filter) | Tag filters associated with the deployment group.Cannot be used in the same call as ec2TagSet.<br/>key:<br/> The key of the tag filter.<br/>type:<br/> The type of the tag filter, either KEY\_ONLY, VALUE\_ONLY, or KEY\_AND\_VALUE.<br/>value:<br/> The value of the tag filter. | `any` | `[]` | no |
| <a name="input_ec2_tag_set"></a> [ec2\_tag\_set](#input\_ec2\_tag\_set) | Tag filters associated with the deployment group.Cannot be used in the same call as ec2TagSet.<br/>key:<br/> The key of the tag filter.<br/>type:<br/> The type of the tag filter, either KEY\_ONLY, VALUE\_ONLY, or KEY\_AND\_VALUE.<br/>value:<br/> The value of the tag filter. | `any` | `[]` | no |
| <a name="input_ecs_service"></a> [ecs\_service](#input\_ecs\_service) | Configuration block(s) of the ECS services for a deployment group.<br/>cluster\_name:<br/>  The name of the ECS cluster. <br/>service\_name:<br/>  The name of the ECS service. | `any` | `[]` | no |
| <a name="input_load_balancer_info"></a> [load\_balancer\_info](#input\_load\_balancer\_info) | Single configuration block of the load balancer to use in a blue/green deployment. | `any` | `[]` | no |
| <a name="input_on_premises_instance_tag_filter"></a> [on\_premises\_instance\_tag\_filter](#input\_on\_premises\_instance\_tag\_filter) | On premise tag filters associated with the group.<br/>key:<br/>  The key of the tag filter.<br/>type:<br/>   The type of the tag filter, either KEY\_ONLY, VALUE\_ONLY, or KEY\_AND\_VALUE.<br/>value:<br/>   The value of the tag filter. | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_trigger_configuration"></a> [trigger\_configuration](#input\_trigger\_configuration) | Add triggers to a Deployment Group to receive notifications about events related to deployments or instances in the group.<br/>trigger\_events:<br/>  The event type or types for which notifications are triggered. <br/>trigger\_name:<br/>   The name of the notification trigger.<br/>trigger\_target\_arn:<br/>    The ARN of the SNS topic through which notifications are sent. | `any` | `[]` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codedeploy_deployment_group"></a> [codedeploy\_deployment\_group](#output\_codedeploy\_deployment\_group) | Map of codedeploy deployment group. |
| <a name="output_deployment_group_arn"></a> [deployment\_group\_arn](#output\_deployment\_group\_arn) | The ARN of the CodeDeploy deployment group. |
| <a name="output_deployment_group_compute_platform"></a> [deployment\_group\_compute\_platform](#output\_deployment\_group\_compute\_platform) | The destination platform type for the deployment. |
| <a name="output_deployment_group_id"></a> [deployment\_group\_id](#output\_deployment\_group\_id) | The ARN of the CodeDeploy deployment group. |
| <a name="output_deployment_group_name"></a> [deployment\_group\_name](#output\_deployment\_group\_name) | Application name and deployment group name. |
| <a name="output_deployment_group_tags_all"></a> [deployment\_group\_tags\_all](#output\_deployment\_group\_tags\_all) | A map of tags assigned to the resource. |

<!-- END_TF_DOCS -->