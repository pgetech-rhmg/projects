variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

##############################

variable "vpc_id_name" {
  type        = string
  description = "The name given in the parameter store for the vpc id"
}

variable "subnet_id1_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 1"
}

##############################
#secrets manager variables

variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
}

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 30
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
}

variable "plaintext_secret" {
  type        = string
  default     = ""
  description = "Specifies text data that you want to encrypt and store in this version of the secret"
}

variable "key_value_secret" {
  type        = map(string)
  default     = {}
  description = "Specifies key value data that you want to encrypt and store in this version of the secret"
}

variable "store_as_key_value" {
  type        = bool
  default     = false
  description = "specifies storing secret as plaintext or key value pair"
}

##############################

#variables for Lambda_function

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "function_name" {
  description = "Unique name for your Lambda Function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Function does"
  type        = string
}

variable "runtime" {
  description = " Identifier of the function's runtime"
  type        = string
}

variable "source_dir" {
  description = "Package entire contents of this directory into the archive."
  type        = string
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda function timeout value"
}

variable "publish" {
  type        = bool
  description = "Whether to publish creation/change as new Lambda Function Version"
}

#variables for kms_key
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#variables for security_group
# variable "lambda_cidr_ingress_rules" {
#   type = list(object({
#     from             = number
#     to               = number
#     protocol         = string
#     cidr_blocks      = list(string)
#     ipv6_cidr_blocks = list(string)
#     description      = string
#   }))
# }

variable "lambda_cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "lambda_sg_name" {
  description = "name of the security group"
  type        = string
}

variable "lambda_sg_description" {
  description = "vpc id for security group"
  type        = string
}

#variables for aws_lambda_iam_role
variable "iam_name" {
  description = "Name of the iam role"
  type        = string
}

variable "iam_aws_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

#variables for sns

variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
  default     = null
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
  default     = null
}

#variables for cloudwatch event rule
variable "cloudwatch_event_rule_name" {
  description = "cloudwatch event rule name to create cloudwatch event with cron schedule"
  type        = string
}

variable "cloudwatch_event_rule_description" {
  description = "cloudwatch event rule name to create cloudwatch event with cron schedule"
  type        = string
}

variable "cron_schedule_expression" {
  description = "schedule expression to trigger cloud watch event rule"
  type        = string
}

#variables for Tags
variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  type        = string
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
}

variable "DataClassification" {
  type        = string
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "CRIS" {
  type        = string
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
}

variable "Notify" {
  type        = list(string)
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
}

variable "Owner" {
  type        = list(string)
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}
