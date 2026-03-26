#variables for aws_lambda_function
variable "function_name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda@edge function. Valid value is [x86_64]"
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64"], var.architectures)
    error_message = "Lambda@edge supports only x86_64. It doesn't support arm64. Please select on these as architectures parameter."
  }
}

variable "code_signing_config_arn" {
  description = "To enable code signing for this function, specify the ARN of a code-signing configuration"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
  validation {
    condition = (
      var.memory_size >= 128 &&
    var.memory_size <= 1024)
    error_message = "Set a value from 128 MB to 1024 MB."
  }
}

variable "runtime" {
  description = "Identifier of the function's runtime"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket location containing the function's deployment package. Conflicts with filename and image_uri. This bucket must reside in the same AWS region where you are creating the Lambda function"
  type        = string
}

variable "s3_key" {
  description = " S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri"
  type        = string
}

variable "s3_object_version" {
  description = "Object version containing the function's deployment package. Conflicts with filename and image_uri"
  type        = string
  default     = null
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
  validation {
    condition = (
      var.timeout >= 1 &&
    var.timeout <= 900)
    error_message = "Lambda function timeout value should be between 1 second to  900 seconds."
  }
}

variable "lambda_function_create_timeouts" {
  description = "How long to wait for slow uploads or EC2 throttling errors in minutes"
  type        = string
  default     = "10m"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

# validate the tags passed
module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "file_system_config_arn" {
  description = "Amazon Resource Name (ARN) of the Amazon EFS Access Point that provides access to the file system"
  type        = string
  default     = null
}

variable "file_system_config_local_mount_path" {
  description = "Path where the function can access the file system, starting with /mnt/"
  type        = string
  default     = null
}

variable "tracing_config_mode" {
  description = "Whether to to sample and trace a subset of incoming requests with AWS X-Ray. Valid values are PassThrough and Active"
  type        = string
  default     = null
}

#variables for aws_lambda_function_event_invoke_config
variable "event_invoke_config_create" {
  description = "Specifies if aws_lambda_function_event_invoke_config is set or not"
  type        = bool
  default     = false
}

variable "event_invoke_config_maximum_event_age_in_seconds" {
  description = "Maximum age of a request that Lambda sends to a function for processing in seconds. Valid values between 60 and 21600"
  type        = number
  default     = null
  validation {
    condition = (var.event_invoke_config_maximum_event_age_in_seconds == null ? true : (
    var.event_invoke_config_maximum_event_age_in_seconds >= 60 && var.event_invoke_config_maximum_event_age_in_seconds <= 21600))
    error_message = "Error! The value must be between 60 and 21600."
  }
}

variable "event_invoke_config_maximum_retry_attempts" {
  description = "Maximum number of times to retry when the function returns an error. Valid values between 0 and 2. Defaults to 2."
  type        = number
  default     = 2
  validation {
    condition     = contains([0, 1, 2], var.event_invoke_config_maximum_retry_attempts)
    error_message = "Error! The value must be between 0 and 2."
  }
}

variable "destination_on_failure" {
  description = "Amazon Resource Name (ARN) of the destination resource for failed asynchronous invocations"
  type        = string
  default     = null
}

variable "destination_on_success" {
  description = "Amazon Resource Name (ARN) of the destination resource for successful asynchronous invocations"
  type        = string
  default     = null
}

#variables for aws_lambda_event_source_mapping
variable "event_source_mapping_create" {
  description = "Specifies if aws_lambda_event_source_mapping is set or not"
  type        = bool
  default     = false
}

variable "event_source_mapping_batch_size" {
  description = "The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100 for DynamoDB, Kinesis, MQ and MSK, 10 for SQS"
  type        = number
  default     = 100
  validation {
    condition     = contains([100, 10], var.event_source_mapping_batch_size)
    error_message = "Error! Defaults to 100 for DynamoDB, Kinesis, MQ and MSK, 10 for SQS."
  }
}

variable "event_source_mapping_bisect_batch_on_function_error" {
  description = "f the function returns an error, split the batch in two and retry. Only available for stream sources (DynamoDB and Kinesis)"
  type        = bool
  default     = false
}

variable "event_source_mapping_enabled" {
  description = "Determines if the mapping will be enabled on creation"
  type        = bool
  default     = true
}

variable "event_source_mapping_event_source_arn" {
  description = "The event source ARN - this is required for Kinesis stream, DynamoDB stream, SQS queue, MQ broker or MSK cluster. It is incompatible with a Self Managed Kafka source"
  type        = string
  default     = null
}

variable "event_source_mapping_function_response_types" {
  description = " list of current response type enums applied to the event source mapping for AWS Lambda checkpointing. Only available for SQS and stream sources (DynamoDB and Kinesis). Valid values: ReportBatchItemFailures."
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.event_source_mapping_function_response_types == null,
    var.event_source_mapping_function_response_types == "ReportBatchItemFailures"])
    error_message = "Error! enter a valid value for aws event source mapping function response types."
  }
}

variable "event_source_mapping_maximum_batching_window_in_seconds" {
  description = "The maximum amount of time to gather records before invoking the function, in seconds (between 0 and 300)"
  type        = number
  default     = null
  validation {
    condition = (var.event_source_mapping_maximum_batching_window_in_seconds == null ? true : (
    var.event_source_mapping_maximum_batching_window_in_seconds >= 0 && var.event_source_mapping_maximum_batching_window_in_seconds <= 300))
    error_message = "Error! The value must be between 0 and 300."
  }
}

variable "event_source_mapping_maximum_record_age_in_seconds" {
  description = " The maximum age of a record that Lambda sends to a function for processing. Only available for stream sources (DynamoDB and Kinesis)"
  type        = number
  default     = -1
  validation {
    condition = anytrue([
      var.event_source_mapping_maximum_record_age_in_seconds == -1,
    var.event_source_mapping_maximum_record_age_in_seconds >= 60 && var.event_source_mapping_maximum_record_age_in_seconds <= 604800])
    error_message = "Error! The value must be between 60 and 604800."
  }
}

variable "event_source_mapping_maximum_retry_attempts" {
  description = "The maximum number of times to retry when the function returns an error. Only available for stream sources (DynamoDB and Kinesis)"
  type        = number
  default     = -1
  validation {
    condition     = (var.event_source_mapping_maximum_retry_attempts >= -1 && var.event_source_mapping_maximum_retry_attempts <= 10000)
    error_message = "Error! The value must be between -1 and 10000."
  }
}

variable "event_source_mapping_parallelization_factor" {
  description = "The number of batches to process from each shard concurrently. Only available for stream sources (DynamoDB and Kinesis)"
  type        = number
  default     = 1
  validation {
    condition     = (var.event_source_mapping_parallelization_factor >= 1 && var.event_source_mapping_parallelization_factor <= 10)
    error_message = "Error! The value must be between 1 and 10."
  }
}

variable "event_source_mapping_queues" {
  description = "The name of the Amazon MQ broker destination queue to consume. Only available for MQ sources. A single queue name must be specified."
  type        = list(string)
  default     = null
}

variable "event_source_mapping_starting_position" {
  description = "The position in the stream where AWS Lambda should start reading. Must be one of AT_TIMESTAMP (Kinesis only), LATEST or TRIM_HORIZON if getting events from Kinesis, DynamoDB or MSK. Must not be provided if getting events from SQS"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.event_source_mapping_starting_position == null,
      var.event_source_mapping_starting_position == "AT_TIMESTAMP",
      var.event_source_mapping_starting_position == "LATEST",
    var.event_source_mapping_starting_position == "TRIM_HORIZON"])
    error_message = "Error! The valid value must be AT_TIMESTAMP, LATEST, TRIM_HORIZON."
  }
}

variable "event_source_mapping_starting_position_timestamp" {
  description = "A timestamp in RFC3339 format of the data record which to start reading when using starting_position set to AT_TIMESTAMP"
  type        = string
  default     = null
}

variable "event_source_mapping_topics" {
  description = "The name of the Kafka topics. Only available for MSK sources. A single topic name must be specified"
  type        = list(string)
  default     = null
}

variable "event_source_mapping_tumbling_window_in_seconds" {
  description = "The duration in seconds of a processing window for AWS Lambda streaming analytics. The range is between 1 second up to 900 seconds. Only available for stream sources (DynamoDB and Kinesis)"
  type        = number
  default     = null
  validation {
    condition = (var.event_source_mapping_tumbling_window_in_seconds == null ? true : (
    var.event_source_mapping_tumbling_window_in_seconds >= 1 && var.event_source_mapping_tumbling_window_in_seconds <= 900))
    error_message = "Error! The value must be between 0 and 900."
  }
}

variable "destination_arn_on_failure" {
  description = "The Amazon Resource Name (ARN) of the destination resource"
  type        = string
  default     = null
}

variable "source_access_configuration_type" {
  description = "The type of this configuration. For Self Managed Kafka you will need to supply blocks for type VPC_SUBNET and VPC_SECURITY_GROUP"
  type        = string
  default     = null
}

variable "source_access_configuration_uri" {
  description = "The URI for this configuration. For type VPC_SUBNET the value should be subnet:subnet_id where subnet_id is the value you would find in an aws_subnet resource's id attribute. For type VPC_SECURITY_GROUP the value should be security_group:security_group_id where security_group_id is the value you would find in an aws_security_group resource's id attribute"
  type        = string
  default     = null
}

variable "filter_criteria_pattern" {
  description = "A filter pattern up to 4096 characters"
  type        = string
  default     = null
}

variable "self_managed_event_source_endpoints" {
  description = "A map of endpoints for the self managed source. For Kafka self-managed sources, the key should be KAFKA_BOOTSTRAP_SERVERS and the value should be a string with a comma separated list of broker endpoints."
  type        = map(string)
  default     = null
}

#variables for aws_lambda_permission
variable "lambda_permission_action" {
  description = "The AWS Lambda action you want to allow in this statement"
  type        = string
  default     = null
}

variable "lambda_permission_event_source_token" {
  description = "The Event Source Token to validate. Used with Alexa Skills"
  type        = string
  default     = null
}

variable "lambda_permission_principal" {
  description = "The principal who is getting this permissionE.g., s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com"
  type        = string
  default     = null
}

variable "lambda_permission_source_account" {
  description = "This parameter is used for S3 and SES. The AWS account ID (without a hyphen) of the source owner"
  type        = string
  default     = null
}

variable "lambda_permission_source_arn" {
  description = "When the principal is an AWS service, the ARN of the specific resource within that service to grant permission to. Without this, any resource from principal will be granted permission – even if that resource is from another account"
  type        = string
  default     = null
}

#variables for aws_lambda_iam_role
variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}