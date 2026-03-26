<!-- BEGIN_TF_DOCS -->
# AWS Lambda event source mapping using kinesis
Terraform module which creates SAF2.0 Lambda event source mapping in AWS

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lambda_event_source_mapping.kinesis_event_source_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_batch_size"></a> [batch\_size](#input\_batch\_size) | The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100. | `number` | `100` | no |
| <a name="input_bisect_batch_on_function_error"></a> [bisect\_batch\_on\_function\_error](#input\_bisect\_batch\_on\_function\_error) | If the function returns an error, split the batch in two and retry. | `bool` | `false` | no |
| <a name="input_destination_arn_on_failure"></a> [destination\_arn\_on\_failure](#input\_destination\_arn\_on\_failure) | The Amazon Resource Name (ARN) of the destination resource | `any` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Determines if the mapping will be enabled on creation | `bool` | `true` | no |
| <a name="input_event_source_arn"></a> [event\_source\_arn](#input\_event\_source\_arn) | The event source ARN | `string` | n/a | yes |
| <a name="input_filter_criteria_pattern"></a> [filter\_criteria\_pattern](#input\_filter\_criteria\_pattern) | A filter pattern up to 4096 characters | `any` | `[]` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | The name or the ARN of the Lambda function that will be subscribing to events | `string` | n/a | yes |
| <a name="input_function_response_types"></a> [function\_response\_types](#input\_function\_response\_types) | list of current response type enums applied to the event source mapping for AWS Lambda checkpointing.Valid value: ReportBatchItemFailures | `list(string)` | `[]` | no |
| <a name="input_maximum_batching_window_in_seconds"></a> [maximum\_batching\_window\_in\_seconds](#input\_maximum\_batching\_window\_in\_seconds) | The maximum amount of time to gather records before invoking the function, in seconds (between 0 and 300) | `number` | `null` | no |
| <a name="input_maximum_record_age_in_seconds"></a> [maximum\_record\_age\_in\_seconds](#input\_maximum\_record\_age\_in\_seconds) | The maximum age of a record that Lambda sends to a function for processing. | `number` | `-1` | no |
| <a name="input_maximum_retry_attempts"></a> [maximum\_retry\_attempts](#input\_maximum\_retry\_attempts) | The maximum number of times to retry when the function returns an error. | `number` | `-1` | no |
| <a name="input_parallelization_factor"></a> [parallelization\_factor](#input\_parallelization\_factor) | The number of batches to process from each shard concurrently. | `number` | `1` | no |
| <a name="input_starting_position"></a> [starting\_position](#input\_starting\_position) | The position in the stream where AWS Lambda should start reading. Must be one of AT\_TIMESTAMP, LATEST or TRIM\_HORIZON. | `string` | n/a | yes |
| <a name="input_starting_position_timestamp"></a> [starting\_position\_timestamp](#input\_starting\_position\_timestamp) | A timestamp in RFC3339 format of the data record which to start reading when using starting\_position set to AT\_TIMESTAMP | `string` | `null` | no |
| <a name="input_tumbling_window_in_seconds"></a> [tumbling\_window\_in\_seconds](#input\_tumbling\_window\_in\_seconds) | The duration in seconds of a processing window for AWS Lambda streaming analytics. The range is between 1 second up to 900 seconds. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_source_mapping_all"></a> [event\_source\_mapping\_all](#output\_event\_source\_mapping\_all) | Map of all object |
| <a name="output_event_source_mapping_function_arn"></a> [event\_source\_mapping\_function\_arn](#output\_event\_source\_mapping\_function\_arn) | The the ARN of the Lambda function the event source mapping is sending events to |
| <a name="output_event_source_mapping_last_modified"></a> [event\_source\_mapping\_last\_modified](#output\_event\_source\_mapping\_last\_modified) | The date this resource was last modified |
| <a name="output_event_source_mapping_last_processing_result"></a> [event\_source\_mapping\_last\_processing\_result](#output\_event\_source\_mapping\_last\_processing\_result) | The result of the last AWS Lambda invocation of your Lambda function |
| <a name="output_event_source_mapping_last_state"></a> [event\_source\_mapping\_last\_state](#output\_event\_source\_mapping\_last\_state) | The state of the event source mapping |
| <a name="output_event_source_mapping_state_transition_reason"></a> [event\_source\_mapping\_state\_transition\_reason](#output\_event\_source\_mapping\_state\_transition\_reason) | The reason the event source mapping is in its current state |
| <a name="output_event_source_mapping_uuid"></a> [event\_source\_mapping\_uuid](#output\_event\_source\_mapping\_uuid) | The UUID of the created event source mapping |

<!-- END_TF_DOCS -->