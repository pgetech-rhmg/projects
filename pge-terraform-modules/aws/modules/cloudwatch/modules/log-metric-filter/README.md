<!-- BEGIN_TF_DOCS -->
# AWS Cloudwatch module
Terraform module which creates SAF2.0 Cloudwatch Log metric filter resource in AWS.

Source can be found at https://github.com/pgetech/pge-terraform-modules

To use with encryption please refer https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.11 |
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
| [aws_cloudwatch_log_metric_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | The name of the log group to associate the metric filter with | `string` | n/a | yes |
| <a name="input_metric_transformation_default_value"></a> [metric\_transformation\_default\_value](#input\_metric\_transformation\_default\_value) | The value to emit when a filter pattern does not match a log event. | `string` | `null` | no |
| <a name="input_metric_transformation_name"></a> [metric\_transformation\_name](#input\_metric\_transformation\_name) | The name of the CloudWatch metric to which the monitored log information should be published (e.g. ErrorCount) | `string` | n/a | yes |
| <a name="input_metric_transformation_namespace"></a> [metric\_transformation\_namespace](#input\_metric\_transformation\_namespace) | The destination namespace of the CloudWatch metric. | `string` | n/a | yes |
| <a name="input_metric_transformation_value"></a> [metric\_transformation\_value](#input\_metric\_transformation\_value) | What to publish to the metric. For example, if you're counting the occurrences of a particular term like 'Error', the value will be '1' for each occurrence. If you're counting the bytes transferred the published value will be the value in the log event. | `string` | `"1"` | no |
| <a name="input_name"></a> [name](#input\_name) | A name for the metric filter. | `string` | n/a | yes |
| <a name="input_pattern"></a> [pattern](#input\_pattern) | A valid CloudWatch Logs filter pattern for extracting metric data out of ingested log events. | `string` | n/a | yes | 

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_metric_filter_id"></a> [cloudwatch\_log\_metric\_filter\_id](#output\_cloudwatch\_log\_metric\_filter\_id) | The name of the metric filter |

<!-- END_TF_DOCS -->