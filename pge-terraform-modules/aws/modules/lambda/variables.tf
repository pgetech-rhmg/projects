#variables for aws_lambda_function
variable "function_name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

variable "role" {
  description = "Amazon Resource Name (ARN) of the function's execution role. The role provides the function's identity and access to AWS services and resources"
  type        = string
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda function. Valid values are [x86_64] and [arm64]"
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.architectures)
    error_message = "Valid values for architectures are x86_64 and arm64. Please select on these as architectures parameter."
  }
}

variable "allow_outofband_update" {
  description = "set this to 'true' if to be used with codepipeline, when updates to the code happens outside of terraform"
  type        = bool
  default     = false
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

variable "source_code" {
  description = <<-DOC
    source_dir:
     Package entire contents of this directory into the archive.
    content:
    Add only this content to the archive with source_content_filename as the filename.
    filename:
     Set this as the filename when using source_content.
    DOC

  type = object({
    source_dir = optional(string)
    content    = optional(string)
    filename   = optional(string)
  })

  validation {
    condition     = var.source_code.source_dir == null && var.source_code.content != null && var.source_code.filename == null || var.source_code.source_dir == null && var.source_code.filename != null && var.source_code.content == null ? false : true
    error_message = "Error! Both content and filename are required."
  }

  validation {
    condition     = var.source_code.source_dir != null && var.source_code.content != null && var.source_code.filename == null || var.source_code.source_dir != null && var.source_code.filename != null && var.source_code.content == null ? false : true
    error_message = "Error! Either provide source_dir or provide both content & filename."
  }

  validation {
    condition     = var.source_code.source_dir == null && var.source_code.content == null && var.source_code.filename == null ? false : true
    error_message = "Error! Either provide source_dir or provide both content & filename."
  }

  validation {
    condition     = var.source_code.source_dir != null && var.source_code.content != null && var.source_code.filename != null ? false : true
    error_message = "Error! Either provide source_dir or provide both content & filename."
  }

}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
  default     = null
}

variable "layers" {
  description = "list of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function"
  type        = list(string)
  default     = null
  validation {
    condition = (var.layers == null ? true : (
    length(var.layers) <= 5))
    error_message = "Layers should not exceed a maximum of five."
  }
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128

}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version"
  type        = bool
  default     = false
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations"
  type        = number
  default     = -1
}

variable "runtime" {
  description = "Identifier of the function's runtime"
  type        = string
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

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "dead_letter_config_target_arn" {
  description = "ARN of an SNS topic or SQS queue to notify when an invocation fails. If this option is used, the function's IAM role must be granted suitable access to write to the target object, which means allowing either the sns:Publish or sqs:SendMessage action on this ARN, depending on which service is targeted"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = <<-DOC
    variables:
       Map of environment variables that are accessible from the function code during execution.
    kms_key_arn:
      Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables.The kms key is mandatory when we set the environment variables.
  DOC
  type = object({
    variables   = map(string)
    kms_key_arn = string
  })
  default = {
    variables   = null
    kms_key_arn = null
  }
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

variable "vpc_config_security_group_ids" {
  description = "List of security group IDs associated with the Lambda function"
  type        = list(string)
}

variable "vpc_config_subnet_ids" {
  description = "List of subnet IDs associated with the Lambda function"
  type        = list(string)
}

#variables for aws_lambda_provisioned_concurrency_config
variable "provisioned_concurrent_executions" {
  description = "Amount of capacity to allocate. Must be greater than or equal to 1"
  type        = number
  default     = 0
  validation {
    condition = (var.provisioned_concurrent_executions == 0 ? true : (
    var.provisioned_concurrent_executions >= 1))
    error_message = "Error! The value must be greater than or equal to 1."
  }
}

variable "provisioned_concurrency_config_create_timeouts" {
  description = "How long to wait for the Lambda Provisioned Concurrency Config to be ready on creation"
  type        = string
  default     = "15m"
}

variable "provisioned_concurrency_config_update_timeouts" {
  description = "How long to wait for the Lambda Provisioned Concurrency Config to be ready on update"
  type        = string
  default     = "15m"
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
variable "enable_ephemeral_storage" {
  description = "Flag to enable ephemeral storage"
  type        = bool
  default     = false
}

variable "ephemeral_storage_size" {
  description = "The size of the ephemeral storage in MB"
  type        = number
  default     = 512
}

variable "logging_config" {
  description = <<-DOC
    Configuration block for Lambda function logging settings:
    log_format: The log format for the function. Valid values are 'Text' or 'JSON'. Default is 'Text'.
    application_log_level: The application log level for the function. Valid values are 'TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'. Only applies when log_format is 'JSON'.
    system_log_level: The system log level for the function. Valid values are 'DEBUG', 'INFO', 'WARN'. Only applies when log_format is 'JSON'.
  DOC
  type = object({
    log_format            = optional(string)
    application_log_level = optional(string)
    system_log_level      = optional(string)
  })
  default = null

  validation {
    condition = var.logging_config == null ? true : (
      var.logging_config.log_format == null ? true : contains(["Text", "JSON"], var.logging_config.log_format)
    )
    error_message = "Valid values for log_format are 'Text' or 'JSON'."
  }

  validation {
    condition = var.logging_config == null ? true : (
      var.logging_config.application_log_level == null ? true : contains(["TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"], var.logging_config.application_log_level)
    )
    error_message = "Valid values for application_log_level are 'TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', or 'FATAL'."
  }

  validation {
    condition = var.logging_config == null ? true : (
      var.logging_config.system_log_level == null ? true : contains(["DEBUG", "INFO", "WARN"], var.logging_config.system_log_level)
    )
    error_message = "Valid values for system_log_level are 'DEBUG', 'INFO', or 'WARN'."
  }

  validation {
    condition = var.logging_config == null ? true : (
      var.logging_config.log_format != "JSON" ? true : (
        var.logging_config.application_log_level != null && var.logging_config.system_log_level != null
      )
    )
    error_message = "When log_format is 'JSON', both application_log_level and system_log_level must be specified."
  }
}