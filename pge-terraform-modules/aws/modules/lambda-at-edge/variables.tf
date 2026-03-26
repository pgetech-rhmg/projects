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

variable "local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive"
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

#variables for aws_lambda_iam_role
variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "inline_code" {
  description = "Inline lambda code"
  type        = string
  default     = null
}

variable "file_name" {
  description = "Inline lambda file name"
  type        = string
  default     = null
}
