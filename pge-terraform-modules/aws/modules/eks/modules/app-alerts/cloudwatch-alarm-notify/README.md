<!-- BEGIN_TF_DOCS -->


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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.metric-alarm-down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.metric-alarm-up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_name"></a> [alarm\_name](#input\_alarm\_name) | Domain name or ip address of checking service. | `string` | n/a | yes |
| <a name="input_alert_type_name"></a> [alert\_type\_name](#input\_alert\_type\_name) | Alert\_Type | `string` | `"other"` | no |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | Comparison operator. | `string` | `""` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | n/a | `map(any)` | `{}` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | Evaluation periods. | `string` | `""` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | n/a | `list(any)` | `[]` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | Name of the metric. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Alarm emitter. | `string` | `""` | no |
| <a name="input_period"></a> [period](#input\_period) | Period. | `string` | `""` | no |
| <a name="input_sns_subscription_email_address_list"></a> [sns\_subscription\_email\_address\_list](#input\_sns\_subscription\_email\_address\_list) | List of email addresses | `list(string)` | `[]` | no |
| <a name="input_sns_topic"></a> [sns\_topic](#input\_sns\_topic) | SNS TOPIC arn to be passed to receive the alerts | `string` | n/a | yes |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | Statistic. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | Threshold. | `string` | `""` | no |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | n/a | `string` | `""` | no |
| <a name="input_unit"></a> [unit](#input\_unit) | n/a | `string` | `""` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metric_name"></a> [metric\_name](#output\_metric\_name) | n/a |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | n/a |

<!-- END_TF_DOCS -->