<!-- BEGIN_TF_DOCS -->


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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

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
| <a name="module_alarm"></a> [alarm](#module\_alarm) | ../../ | n/a |
| <a name="module_alarm_metric_query_anomalous"></a> [alarm\_metric\_query\_anomalous](#module\_alarm\_metric\_query\_anomalous) | ../../modules/metric-alarm-anomalous | n/a |
| <a name="module_alarm_metric_query_anomalous_minimal"></a> [alarm\_metric\_query\_anomalous\_minimal](#module\_alarm\_metric\_query\_anomalous\_minimal) | ../../modules/metric-alarm-anomalous | n/a |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | ../../modules/log-group | n/a |
| <a name="module_log_metric_filter"></a> [log\_metric\_filter](#module\_log\_metric\_filter) | ../../modules/log-metric-filter | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | app.terraform.io/pgetech/tags/aws | 0.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AlarmComparisonOperator"></a> [AlarmComparisonOperator](#input\_AlarmComparisonOperator) | The Comparison of alarm metic operator | `string` | n/a | yes |
| <a name="input_AlarmDescription"></a> [AlarmDescription](#input\_AlarmDescription) | The description of Alarm | `string` | n/a | yes |
| <a name="input_AlarmEvaluationPeriods"></a> [AlarmEvaluationPeriods](#input\_AlarmEvaluationPeriods) | To evaluate the periods of alarm | `number` | n/a | yes |
| <a name="input_AlarmPeriod"></a> [AlarmPeriod](#input\_AlarmPeriod) | To count the period of alarm | `number` | n/a | yes |
| <a name="input_AlarmStatistic"></a> [AlarmStatistic](#input\_AlarmStatistic) | The Statistics of alarm | `string` | n/a | yes |
| <a name="input_AlarmThreshold"></a> [AlarmThreshold](#input\_AlarmThreshold) | Value of Alarm threshold | `number` | n/a | yes |
| <a name="input_AlarmUnit"></a> [AlarmUnit](#input\_AlarmUnit) | Specify the unit of alarm | `string` | n/a | yes |
| <a name="input_AppID"></a> [AppID](#input\_AppID) | Identify the application this asset belongs to by its AMPS APP ID.Format = APP-#### | `number` | n/a | yes |
| <a name="input_CRIS"></a> [CRIS](#input\_CRIS) | Cyber Risk Impact Score High, Medium, Low (only one) | `string` | n/a | yes |
| <a name="input_Compliance"></a> [Compliance](#input\_Compliance) | Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud | `list(string)` | n/a | yes |
| <a name="input_DataClassification"></a> [DataClassification](#input\_DataClassification) | Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one) | `string` | n/a | yes |
| <a name="input_Environment"></a> [Environment](#input\_Environment) | The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod. | `string` | n/a | yes |
| <a name="input_LogGroupNamePrefix"></a> [LogGroupNamePrefix](#input\_LogGroupNamePrefix) | To identify the log group name | `string` | n/a | yes |
| <a name="input_LogMetricFilterPattern"></a> [LogMetricFilterPattern](#input\_LogMetricFilterPattern) | The pattern of log metric filter | `string` | n/a | yes |
| <a name="input_MetricTransformationName"></a> [MetricTransformationName](#input\_MetricTransformationName) | Name of the transformation metric | `string` | n/a | yes |
| <a name="input_MetricTransformationNamespace"></a> [MetricTransformationNamespace](#input\_MetricTransformationNamespace) | Namespace of the metric transformation | `string` | n/a | yes |
| <a name="input_Notify"></a> [Notify](#input\_Notify) | Who to notify for system failure or maintenance. Should be a group or list of email addresses. | `list(string)` | n/a | yes |
| <a name="input_Order"></a> [Order](#input\_Order) | Order as a tag to be associated with an AWS resource | `number` | n/a | yes |
| <a name="input_Owner"></a> [Owner](#input\_Owner) | List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1\_LANID2\_LANID3 | `list(string)` | n/a | yes |
| <a name="input_account_num"></a> [account\_num](#input\_account\_num) | Target AWS account number, mandatory | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | n/a | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ID of an AWS-managed customer master key (CMK) for log group | `string` | `null` | no | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of Cloudwatch log group |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of Cloudwatch log group |
| <a name="output_cloudwatch_log_metric_filter_id"></a> [cloudwatch\_log\_metric\_filter\_id](#output\_cloudwatch\_log\_metric\_filter\_id) | The name of the metric filter |
| <a name="output_cloudwatch_metric_alarm_arn"></a> [cloudwatch\_metric\_alarm\_arn](#output\_cloudwatch\_metric\_alarm\_arn) | The ARN of the Cloudwatch metric alarm |
| <a name="output_cloudwatch_metric_alarm_id"></a> [cloudwatch\_metric\_alarm\_id](#output\_cloudwatch\_metric\_alarm\_id) | The ID of the Cloudwatch metric alarm |

<!-- END_TF_DOCS -->