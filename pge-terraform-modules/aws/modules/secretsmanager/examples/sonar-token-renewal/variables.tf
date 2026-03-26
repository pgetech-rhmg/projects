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

variable "kms_key_id" {
  description = "ARN or Id of the AWS KMS customer master key"
  type        = string
  default     = ""
}

variable "template_file_name" {
  description = "Custom policy filename for the kms"
  type        = string
  default     = ""
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 30
}

variable "replica_kms_key_id" {
  description = "ARN, Key ID, or Alias"
  type        = string
  default     = null
}

variable "replica_region" {
  description = "Region for replicating the secret"
  type        = string
  default     = null
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
}

variable "rotation_enabled" {
  description = "Specifies if rotation is set or not"
  type        = bool
}

# variable "secret_string" {
#   type        = any
#   description = "Specifies text data that you want to encrypt and store in this version of the secret"
# }

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

variable "rotation_after_days" {
  description = "A structure that defines the rotation configuration for this secret"
  type        = number
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

variable "sonar_host" {
  description = "sonarqube host name."
  type        = string
}

variable "sonar_token_name_new" {
  description = "new sonarqube token name to create on Sonarqube host, should be different from previous token (date will get added to the string you provide)"
  type        = string
}

variable "secrets_manager_token_keyname" {
  default     = null
  description = "token key name from secrets manager if you store token as key value pair"
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

#variables for lambda_layer
variable "layer_version_compatible_architectures" {
  description = "List of Architectures this layer is compatible with. Currently x86_64 and arm64 can be specified"
  type        = string
  default     = "x86_64"
}
variable "layer_version_compatible_runtimes" {
  description = "A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified"
  type        = list(string)
  default     = ["python3.11"]
}
#variables for aws_lambda_layer_version_permission
variable "layer_version_permission_action" {
  description = "Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation"
  type        = string
  default     = "lambda:GetLayerVersion"
}
variable "layer_version_permission_principal" {
  description = "AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely"
  type        = string
  default     = "*"
}
variable "layer_version_permission_statement_id" {
  description = "The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for"
  type        = string
  default     = "dev-account"
}