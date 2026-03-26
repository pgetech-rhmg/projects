<!-- BEGIN_TF_DOCS -->
# AWS Lambda function module using Amazon S3
Terraform module which creates SAF2.0 Lambda function in AWS

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
| <a name="provider_external"></a> [external](#provider\_external) | n/a |

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
| [aws_lambda_event_source_mapping.event_source_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.event_invoke_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_provisioned_concurrency_config.provisioned_concurrency_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_provisioned_concurrency_config) | resource |
| [external_external.is_valid_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.validate_kms](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architectures"></a> [architectures](#input\_architectures) | Instruction set architecture for your Lambda function. Valid values are [x86\_64] and [arm64] | `string` | `"x86_64"` | no |
| <a name="input_code_signing_config_arn"></a> [code\_signing\_config\_arn](#input\_code\_signing\_config\_arn) | To enable code signing for this function, specify the ARN of a code-signing configuration | `string` | `null` | no |
| <a name="input_dead_letter_config_target_arn"></a> [dead\_letter\_config\_target\_arn](#input\_dead\_letter\_config\_target\_arn) | ARN of an SNS topic or SQS queue to notify when an invocation fails. If this option is used, the function's IAM role must be granted suitable access to write to the target object, which means allowing either the sns:Publish or sqs:SendMessage action on this ARN, depending on which service is targeted | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of what your Lambda Function does | `string` | `null` | no |
| <a name="input_destination_arn_on_failure"></a> [destination\_arn\_on\_failure](#input\_destination\_arn\_on\_failure) | The Amazon Resource Name (ARN) of the destination resource | `string` | `null` | no |
| <a name="input_destination_on_failure"></a> [destination\_on\_failure](#input\_destination\_on\_failure) | Amazon Resource Name (ARN) of the destination resource for failed asynchronous invocations | `string` | `null` | no |
| <a name="input_destination_on_success"></a> [destination\_on\_success](#input\_destination\_on\_success) | Amazon Resource Name (ARN) of the destination resource for successful asynchronous invocations | `string` | `null` | no |
| <a name="input_enable_ephemeral_storage"></a> [enable\_ephemeral\_storage](#input\_enable\_ephemeral\_storage) | Flag to enable ephemeral storage | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | variables:<br/>   Map of environment variables that are accessible from the function code during execution.<br/>kms\_key\_arn:<br/>  Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables.The kms key is mandatory when we set the environment variables. | <pre>object({<br/>    variables   = map(string)<br/>    kms_key_arn = string<br/>  })</pre> | <pre>{<br/>  "kms_key_arn": null,<br/>  "variables": null<br/>}</pre> | no |
| <a name="input_ephemeral_storage_size"></a> [ephemeral\_storage\_size](#input\_ephemeral\_storage\_size) | The size of the ephemeral storage in MB | `number` | `512` | no |
| <a name="input_event_invoke_config_create"></a> [event\_invoke\_config\_create](#input\_event\_invoke\_config\_create) | Specifies if aws\_lambda\_function\_event\_invoke\_config is set or not | `bool` | `false` | no |
| <a name="input_event_invoke_config_maximum_event_age_in_seconds"></a> [event\_invoke\_config\_maximum\_event\_age\_in\_seconds](#input\_event\_invoke\_config\_maximum\_event\_age\_in\_seconds) | Maximum age of a request that Lambda sends to a function for processing in seconds. Valid values between 60 and 21600 | `number` | `null` | no |
| <a name="input_event_invoke_config_maximum_retry_attempts"></a> [event\_invoke\_config\_maximum\_retry\_attempts](#input\_event\_invoke\_config\_maximum\_retry\_attempts) | Maximum number of times to retry when the function returns an error. Valid values between 0 and 2. Defaults to 2. | `number` | `2` | no |
| <a name="input_event_source_mapping_batch_size"></a> [event\_source\_mapping\_batch\_size](#input\_event\_source\_mapping\_batch\_size) | The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100 for DynamoDB, Kinesis, MQ and MSK, 10 for SQS | `number` | `100` | no |
| <a name="input_event_source_mapping_bisect_batch_on_function_error"></a> [event\_source\_mapping\_bisect\_batch\_on\_function\_error](#input\_event\_source\_mapping\_bisect\_batch\_on\_function\_error) | f the function returns an error, split the batch in two and retry. Only available for stream sources (DynamoDB and Kinesis) | `bool` | `false` | no |
| <a name="input_event_source_mapping_create"></a> [event\_source\_mapping\_create](#input\_event\_source\_mapping\_create) | Specifies if aws\_lambda\_event\_source\_mapping is set or not | `bool` | `false` | no |
| <a name="input_event_source_mapping_enabled"></a> [event\_source\_mapping\_enabled](#input\_event\_source\_mapping\_enabled) | Determines if the mapping will be enabled on creation | `bool` | `true` | no |
| <a name="input_event_source_mapping_event_source_arn"></a> [event\_source\_mapping\_event\_source\_arn](#input\_event\_source\_mapping\_event\_source\_arn) | The event source ARN - this is required for Kinesis stream, DynamoDB stream, SQS queue, MQ broker or MSK cluster. It is incompatible with a Self Managed Kafka source | `string` | `null` | no |
| <a name="input_event_source_mapping_function_response_types"></a> [event\_source\_mapping\_function\_response\_types](#input\_event\_source\_mapping\_function\_response\_types) | list of current response type enums applied to the event source mapping for AWS Lambda checkpointing. Only available for SQS and stream sources (DynamoDB and Kinesis). Valid values: ReportBatchItemFailures. | `string` | `null` | no |
| <a name="input_event_source_mapping_maximum_batching_window_in_seconds"></a> [event\_source\_mapping\_maximum\_batching\_window\_in\_seconds](#input\_event\_source\_mapping\_maximum\_batching\_window\_in\_seconds) | The maximum amount of time to gather records before invoking the function, in seconds (between 0 and 300) | `number` | `null` | no |
| <a name="input_event_source_mapping_maximum_record_age_in_seconds"></a> [event\_source\_mapping\_maximum\_record\_age\_in\_seconds](#input\_event\_source\_mapping\_maximum\_record\_age\_in\_seconds) | The maximum age of a record that Lambda sends to a function for processing. Only available for stream sources (DynamoDB and Kinesis) | `number` | `-1` | no |
| <a name="input_event_source_mapping_maximum_retry_attempts"></a> [event\_source\_mapping\_maximum\_retry\_attempts](#input\_event\_source\_mapping\_maximum\_retry\_attempts) | The maximum number of times to retry when the function returns an error. Only available for stream sources (DynamoDB and Kinesis) | `number` | `-1` | no |
| <a name="input_event_source_mapping_parallelization_factor"></a> [event\_source\_mapping\_parallelization\_factor](#input\_event\_source\_mapping\_parallelization\_factor) | The number of batches to process from each shard concurrently. Only available for stream sources (DynamoDB and Kinesis) | `number` | `1` | no |
| <a name="input_event_source_mapping_queues"></a> [event\_source\_mapping\_queues](#input\_event\_source\_mapping\_queues) | The name of the Amazon MQ broker destination queue to consume. Only available for MQ sources. A single queue name must be specified. | `list(string)` | `null` | no |
| <a name="input_event_source_mapping_starting_position"></a> [event\_source\_mapping\_starting\_position](#input\_event\_source\_mapping\_starting\_position) | The position in the stream where AWS Lambda should start reading. Must be one of AT\_TIMESTAMP (Kinesis only), LATEST or TRIM\_HORIZON if getting events from Kinesis, DynamoDB or MSK. Must not be provided if getting events from SQS | `string` | `null` | no |
| <a name="input_event_source_mapping_starting_position_timestamp"></a> [event\_source\_mapping\_starting\_position\_timestamp](#input\_event\_source\_mapping\_starting\_position\_timestamp) | A timestamp in RFC3339 format of the data record which to start reading when using starting\_position set to AT\_TIMESTAMP | `string` | `null` | no |
| <a name="input_event_source_mapping_topics"></a> [event\_source\_mapping\_topics](#input\_event\_source\_mapping\_topics) | The name of the Kafka topics. Only available for MSK sources. A single topic name must be specified | `list(string)` | `null` | no |
| <a name="input_event_source_mapping_tumbling_window_in_seconds"></a> [event\_source\_mapping\_tumbling\_window\_in\_seconds](#input\_event\_source\_mapping\_tumbling\_window\_in\_seconds) | The duration in seconds of a processing window for AWS Lambda streaming analytics. The range is between 1 second up to 900 seconds. Only available for stream sources (DynamoDB and Kinesis) | `number` | `null` | no |
| <a name="input_file_system_config_arn"></a> [file\_system\_config\_arn](#input\_file\_system\_config\_arn) | Amazon Resource Name (ARN) of the Amazon EFS Access Point that provides access to the file system | `string` | `null` | no |
| <a name="input_file_system_config_local_mount_path"></a> [file\_system\_config\_local\_mount\_path](#input\_file\_system\_config\_local\_mount\_path) | Path where the function can access the file system, starting with /mnt/ | `string` | `null` | no |
| <a name="input_filter_criteria_pattern"></a> [filter\_criteria\_pattern](#input\_filter\_criteria\_pattern) | A filter pattern up to 4096 characters | `string` | `null` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Unique name for your Lambda Function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | `null` | no |
| <a name="input_lambda_function_create_timeouts"></a> [lambda\_function\_create\_timeouts](#input\_lambda\_function\_create\_timeouts) | How long to wait for slow uploads or EC2 throttling errors in minutes | `string` | `"10m"` | no |
| <a name="input_lambda_permission_action"></a> [lambda\_permission\_action](#input\_lambda\_permission\_action) | The AWS Lambda action you want to allow in this statement | `string` | `null` | no |
| <a name="input_lambda_permission_event_source_token"></a> [lambda\_permission\_event\_source\_token](#input\_lambda\_permission\_event\_source\_token) | The Event Source Token to validate. Used with Alexa Skills | `string` | `null` | no |
| <a name="input_lambda_permission_principal"></a> [lambda\_permission\_principal](#input\_lambda\_permission\_principal) | The principal who is getting this permissionE.g., s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com | `string` | `null` | no |
| <a name="input_lambda_permission_source_account"></a> [lambda\_permission\_source\_account](#input\_lambda\_permission\_source\_account) | This parameter is used for S3 and SES. The AWS account ID (without a hyphen) of the source owner | `string` | `null` | no |
| <a name="input_lambda_permission_source_arn"></a> [lambda\_permission\_source\_arn](#input\_lambda\_permission\_source\_arn) | When the principal is an AWS service, the ARN of the specific resource within that service to grant permission to. Without this, any resource from principal will be granted permission – even if that resource is from another account | `string` | `null` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | list of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function | `list(string)` | `null` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB your Lambda Function can use at runtime | `number` | `128` | no |
| <a name="input_provisioned_concurrency_config_create_timeouts"></a> [provisioned\_concurrency\_config\_create\_timeouts](#input\_provisioned\_concurrency\_config\_create\_timeouts) | How long to wait for the Lambda Provisioned Concurrency Config to be ready on creation | `string` | `"15m"` | no |
| <a name="input_provisioned_concurrency_config_update_timeouts"></a> [provisioned\_concurrency\_config\_update\_timeouts](#input\_provisioned\_concurrency\_config\_update\_timeouts) | How long to wait for the Lambda Provisioned Concurrency Config to be ready on update | `string` | `"15m"` | no |
| <a name="input_provisioned_concurrent_executions"></a> [provisioned\_concurrent\_executions](#input\_provisioned\_concurrent\_executions) | Amount of capacity to allocate. Must be greater than or equal to 1 | `number` | `0` | no |
| <a name="input_publish"></a> [publish](#input\_publish) | Whether to publish creation/change as new Lambda Function Version | `bool` | `false` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations | `number` | `-1` | no |
| <a name="input_role"></a> [role](#input\_role) | Amazon Resource Name (ARN) of the function's execution role. The role provides the function's identity and access to AWS services and resources | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Identifier of the function's runtime | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket location containing the function's deployment package. Conflicts with filename and image\_uri. This bucket must reside in the same AWS region where you are creating the Lambda function | `string` | n/a | yes |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key of an object containing the function's deployment package. Conflicts with filename and image\_uri | `string` | n/a | yes |
| <a name="input_s3_object_version"></a> [s3\_object\_version](#input\_s3\_object\_version) | Object version containing the function's deployment package. Conflicts with filename and image\_uri | `string` | `null` | no |
| <a name="input_self_managed_event_source_endpoints"></a> [self\_managed\_event\_source\_endpoints](#input\_self\_managed\_event\_source\_endpoints) | A map of endpoints for the self managed source. For Kafka self-managed sources, the key should be KAFKA\_BOOTSTRAP\_SERVERS and the value should be a string with a comma separated list of broker endpoints. | `map(string)` | `null` | no |
| <a name="input_source_access_configuration_type"></a> [source\_access\_configuration\_type](#input\_source\_access\_configuration\_type) | The type of this configuration. For Self Managed Kafka you will need to supply blocks for type VPC\_SUBNET and VPC\_SECURITY\_GROUP | `string` | `null` | no |
| <a name="input_source_access_configuration_uri"></a> [source\_access\_configuration\_uri](#input\_source\_access\_configuration\_uri) | The URI for this configuration. For type VPC\_SUBNET the value should be subnet:subnet\_id where subnet\_id is the value you would find in an aws\_subnet resource's id attribute. For type VPC\_SECURITY\_GROUP the value should be security\_group:security\_group\_id where security\_group\_id is the value you would find in an aws\_security\_group resource's id attribute | `string` | `null` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | The hash value of the source-code zip file | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Amount of time your Lambda Function has to run in seconds | `number` | `3` | no |
| <a name="input_tracing_config_mode"></a> [tracing\_config\_mode](#input\_tracing\_config\_mode) | Whether to to sample and trace a subset of incoming requests with AWS X-Ray. Valid values are PassThrough and Active | `string` | `null` | no |
| <a name="input_vpc_config_security_group_ids"></a> [vpc\_config\_security\_group\_ids](#input\_vpc\_config\_security\_group\_ids) | List of security group IDs associated with the Lambda function | `list(string)` | n/a | yes |
| <a name="input_vpc_config_subnet_ids"></a> [vpc\_config\_subnet\_ids](#input\_vpc\_config\_subnet\_ids) | List of subnet IDs associated with the Lambda function | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_source_mapping_function_arn"></a> [event\_source\_mapping\_function\_arn](#output\_event\_source\_mapping\_function\_arn) | The the ARN of the Lambda function the event source mapping is sending events to |
| <a name="output_event_source_mapping_last_modified"></a> [event\_source\_mapping\_last\_modified](#output\_event\_source\_mapping\_last\_modified) | The date this resource was last modified |
| <a name="output_event_source_mapping_last_processing_result"></a> [event\_source\_mapping\_last\_processing\_result](#output\_event\_source\_mapping\_last\_processing\_result) | The result of the last AWS Lambda invocation of your Lambda function |
| <a name="output_event_source_mapping_last_state"></a> [event\_source\_mapping\_last\_state](#output\_event\_source\_mapping\_last\_state) | The state of the event source mapping |
| <a name="output_event_source_mapping_state_transition_reason"></a> [event\_source\_mapping\_state\_transition\_reason](#output\_event\_source\_mapping\_state\_transition\_reason) | The reason the event source mapping is in its current state |
| <a name="output_event_source_mapping_uuid"></a> [event\_source\_mapping\_uuid](#output\_event\_source\_mapping\_uuid) | The UUID of the created event source mapping |
| <a name="output_lambda_all"></a> [lambda\_all](#output\_lambda\_all) | Map of all Lambda object |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | Amazon Resource Name (ARN) identifying your Lambda Function |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri |
| <a name="output_lambda_last_modified"></a> [lambda\_last\_modified](#output\_lambda\_last\_modified) | Date this resource was last modified |
| <a name="output_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#output\_lambda\_qualified\_arn) | ARN identifying your Lambda Function Version (if versioning is enabled via publish = true) |
| <a name="output_lambda_signing_job_arn"></a> [lambda\_signing\_job\_arn](#output\_lambda\_signing\_job\_arn) | ARN of the signing job |
| <a name="output_lambda_signing_profile_version_arn"></a> [lambda\_signing\_profile\_version\_arn](#output\_lambda\_signing\_profile\_version\_arn) | ARN of the signing profile version |
| <a name="output_lambda_source_code_size"></a> [lambda\_source\_code\_size](#output\_lambda\_source\_code\_size) | Size in bytes of the function .zip file |
| <a name="output_lambda_tags_all"></a> [lambda\_tags\_all](#output\_lambda\_tags\_all) | A map of tags assigned to the resource |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of your Lambda Function |
| <a name="output_lambda_vpc_config_vpc_id"></a> [lambda\_vpc\_config\_vpc\_id](#output\_lambda\_vpc\_config\_vpc\_id) | ID of the VPC |
| <a name="output_provisioned_concurrency_config_id"></a> [provisioned\_concurrency\_config\_id](#output\_provisioned\_concurrency\_config\_id) | Lambda Function name and qualifier separated by a colon (:) |

<!-- END_TF_DOCS -->