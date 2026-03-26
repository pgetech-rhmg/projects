variable "aws_region" {
  type        = string
  description = "The AWS region to use for storing logs and Lambda Insights."
}

variable "aws_role" {
  type        = string
  description = "The AWS role used for the Sumo logger module."
}

variable "lambda_name" {
  type        = string
  description = "The name of the Lambda function."

  validation {
    condition     = length(var.lambda_name) < 108
    error_message = "Lambda name must be shorter than 108 characters to accomodate alias/warmer limits."
  }
}

variable "runtime" {
  type        = string
  description = "The runtime used to run Lambda code. See: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html#runtimes-supported"
  default     = "nodejs22.x"
}

variable "handler" {
  type        = string
  description = "The handler function for this Lambda. Default of `src/index.handler` means that the handler will be located in `src/index.js` and the exported function is named `handler`."
  default     = "src/index.handler"
}

variable "layers" {
  type        = list(string)
  description = "Lambda layer version ARNs to attach to the Lambda function. See: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html"
  default     = ["arn:aws:lambda:us-west-2:553035198032:layer:git:6"]
}

variable "envvars" {
  type        = map(string)
  description = "Environment variables to pass into the Lambda function."
  default     = { "DEFAULT_ENVARS" = "TRUE" }
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS account or environment. Should be one of: `Dev`, `Test`, `QA`, `Prod`"
}

variable "account_num" {
  type        = string
  description = "The AWS account number."
  default     = null
}

variable "timeout" {
  type        = number
  description = "Execution timeout for the Lambda function, in seconds."
  default     = 60
}

variable "memory" {
  type        = number
  description = "Amount of memory provided to the Lambda function, in MiB."
  default     = 1024
}

variable "tracing_enabled" {
  type        = bool
  description = "If true, use Active mode for function tracing; otherwise, use PassThrough mode. See: https://docs.aws.amazon.com/vsts/latest/userguide/lambda-deploy.html"
  default     = true
}

variable "archive_path" {
  type        = string
  description = "The path to the Lambda source code directory."
}

variable "subnet_qualifier" {
  type        = map(any)
  description = "If `partner != MRAD`, this is used to select a subnet by environment."
  default     = { Dev = "Dev-2", Test = "Test-2", QA = "QA", Prod = "Prod" }
}

variable "maximum_retry_attempts" {
  type        = number
  description = "Maximum number of times to retry when the function returns an error, from 0 to 2."
  default     = 2
}

variable "additional_security_groups" {
  type        = list(string)
  description = "Any additional security groups to be added to the Lambda function."
  default     = []
}

variable "service" {
  type        = list(string)
  description = "A list of AWS services allowed to assume the generated IAM role."
  default     = ["lambda.amazonaws.com"]
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to these resources which indicates their provenance."
}

variable "optional_tags" {
  type        = map(string)
  description = "Optional tags to add to these resources."
  default     = {}
}

variable "partner" {
  type        = string
  description = "If `partner` is not MRAD, the name of the VPC to use for this Lambda function."
  default     = "MRAD"
}

variable "subnet1" {
  type        = string
  description = "The name of the first subnet to use for this Lambda function."
  default     = ""
}

variable "subnet2" {
  type        = string
  description = "The name of the second subnet to use for this Lambda function."
  default     = ""
}

variable "subnet3" {
  type        = string
  description = "The name of the third subnet to use for this Lambda function."
  default     = ""
}

variable "sg_name" {
  type        = string
  description = "The name of the security group to use for this Lambda function."
  default     = "terraform-template-lambda-sg"
}

variable "alias_name" {
  type        = string
  description = "An optional custom alias name for this Lambda function."
  default     = null
}

variable "TFC_CONFIGURATION_VERSION_GIT_BRANCH" {
  type        = string
  description = "The current Git branch, set by Terraform. See: https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment"
}

variable "filter_pattern" {
  type        = string
  description = "The CloudWatch Logs filter pattern for pattern matching logs to send to Sumo Logic. Applies to an `aws_cloudwatch_log_subscription_filter`. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter#filter_pattern"
  default     = ""
}

variable "publish" {
  type        = bool
  description = "If true, publish this creation/change as a new Lambda function version."
  default     = false
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encryption. Required if data classification is not Internal or Public."
  default     = null
}

variable "use_aws_managed_s3_kms" {
  type        = bool
  description = "If true, use AWS-managed KMS (aws/s3) for S3 bucket encryption instead of customer-managed key. Lambda environment variables will still use customer-managed KMS if kms_key_arn is null."
  default     = false
}

variable "dead_letter_queue_arn" {
  description = "ARN of an SNS topic or SQS queue to notify when an invocation fails."
  type        = string
  default     = null
}

variable "bucket_versioning" {
  description = "Set whether bucket versioning is on of off for the bucket containing Lambda source code."
  type        = string
  default     = "Disabled"
}

variable "lambda_additional_iam_policy" {
  description = "Allows a custom IAM policy to be added to the default policy."
  type        = string
  default     = null
}

variable "lambda_additional_iam_managed_policy_arns" {
  description = "Allows a managed IAM policy to be added to the default policy, by ARN."
  type        = list(string)
  default     = []
}

variable "lambda_insights" {
  description = "If true, enable Lambda Insights for this function."
  type        = bool
  default     = false
}

variable "kms_role" {
  type        = string
  description = "This value is UNUSED and should be left as `null`. It remains here for backward compatibility."
  default     = null
}

variable "disable_warmer" {
  type        = bool
  description = "Disable the Lambda concurrency warmer. This is a workaround for an AWS resource config issue: `InvalidParameterValueException: Provisioned Concurrency Configs cannot be applied to unpublished function versions.`"
  default     = false
}

variable "ignore_name_length_check" {
  type        = bool
  description = "If true, ignore the pre-deploy length check for the Lambda function name. This is intended for use by existing repos which already rely on names that are too long to define a valid warmer."
  default     = false
}
