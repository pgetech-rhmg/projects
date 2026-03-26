<!-- BEGIN_TF_DOCS -->
# RDS start/stop

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

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
| <a name="module_lambda_function_rds_auto_start"></a> [lambda\_function\_rds\_auto\_start](#module\_lambda\_function\_rds\_auto\_start) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_lambda_function_rds_auto_stop"></a> [lambda\_function\_rds\_auto\_stop](#module\_lambda\_function\_rds\_auto\_stop) | app.terraform.io/pgetech/lambda/aws | 0.1.3 |
| <a name="module_validate-pge-tags"></a> [validate-pge-tags](#module\_validate-pge-tags) | app.terraform.io/pgetech/validate-pge-tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.schedule-start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.schedule-stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.schedule_lambda_start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.schedule_lambda_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_permission.allow_events_bridge_to_run_lambda_auto_start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_events_bridge_to_run_lambda_auto_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_role_start_stop"></a> [iam\_role\_start\_stop](#input\_iam\_role\_start\_stop) | Aws service of the iam role | `string` | n/a | yes |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda timeout in seconds | `number` | n/a | yes |
| <a name="input_rds_auto_control_service_name"></a> [rds\_auto\_control\_service\_name](#input\_rds\_auto\_control\_service\_name) | RDS auto control service name | `string` | n/a | yes |
| <a name="input_rds_auto_start_tag"></a> [rds\_auto\_start\_tag](#input\_rds\_auto\_start\_tag) | Set it to yes if auto start needs to be enabled | `string` | `"no"` | no |
| <a name="input_rds_auto_stop_tag"></a> [rds\_auto\_stop\_tag](#input\_rds\_auto\_stop\_tag) | Set it to yes if auto stop needs to be enabled | `string` | `"no"` | no |
| <a name="input_schedule_rds_auto_start"></a> [schedule\_rds\_auto\_start](#input\_schedule\_rds\_auto\_start) | Cron schedule to trigger lambda function | `string` | n/a | yes |
| <a name="input_schedule_rds_auto_stop"></a> [schedule\_rds\_auto\_stop](#input\_schedule\_rds\_auto\_stop) | Cron schedule to trigger lambda function | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | n/a | yes |
| <a name="input_vpc_config_security_group_ids"></a> [vpc\_config\_security\_group\_ids](#input\_vpc\_config\_security\_group\_ids) | List of security group IDs associated with the Lambda function | `list(string)` | n/a | yes |
| <a name="input_vpc_config_subnet_ids"></a> [vpc\_config\_subnet\_ids](#input\_vpc\_config\_subnet\_ids) | List of subnet IDs associated with the Lambda function | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_schedule_start_arn"></a> [cloudwatch\_event\_rule\_schedule\_start\_arn](#output\_cloudwatch\_event\_rule\_schedule\_start\_arn) | value of the cloudwatch event rule schedule start arn |
| <a name="output_cloudwatch_event_rule_schedule_stop_arn"></a> [cloudwatch\_event\_rule\_schedule\_stop\_arn](#output\_cloudwatch\_event\_rule\_schedule\_stop\_arn) | value of the cloudwatch event rule schedule stop arn |
| <a name="output_lambda_function_rds_auto_start_arn"></a> [lambda\_function\_rds\_auto\_start\_arn](#output\_lambda\_function\_rds\_auto\_start\_arn) | value of the lambda start function arn |
| <a name="output_lambda_function_rds_auto_stop_arn"></a> [lambda\_function\_rds\_auto\_stop\_arn](#output\_lambda\_function\_rds\_auto\_stop\_arn) | value of the lambda stop function arn |


<!-- END_TF_DOCS -->