variable "tags" {
  type        = map(any)
  description = "The list of PG&E tags required for AWS assets"
}

variable "lambda_name" {
  type        = string
  description = "The name of the particular AWS Lambda"
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS Topic for the SQS queue"
}

variable "kms_master_key_id" {
  type        = string
  description = "The AWS KMS to use in SQS"
  default     = "alias/aws/sqs"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}