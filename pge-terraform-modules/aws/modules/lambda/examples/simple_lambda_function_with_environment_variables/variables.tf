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

variable "environment_variables" {
  description = "Map of environment variables that are accessible from the function code during execution"
  type        = map(string)
}

variable "source_dir" {
  description = "Package entire contents of this directory into the archive."
  type        = string
}

#variables for lambda_layer
variable "layer_version_layer_name" {
  description = "Unique name for your Lambda Layer"
  type        = string
}

variable "layer_version_compatible_architectures" {
  description = "List of Architectures this layer is compatible with. Currently x86_64 and arm64 can be specified"
  type        = string
}

variable "layer_version_compatible_runtimes" {
  description = "A list of Runtimes this layer is compatible with. Up to 15 runtimes can be specified"
  type        = list(string)
}

variable "layer_version_local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive"
  type        = string
}
#variables for aws_lambda_alias
variable "lambda_alias_name" {
  description = "Name for the alias you are creating"
  type        = string
}

variable "lambda_alias_description" {
  description = "Description of the alias"
  type        = string
}

#variables for aws_lambda_layer_version_permission
variable "layer_version_permission_action" {
  description = "Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation"
  type        = string
}

variable "layer_version_permission_principal" {
  description = "AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely"
  type        = string
}

variable "layer_version_permission_statement_id" {
  description = "The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for"
  type        = string
}

#variables for aws_lambda_event_source_mapping
variable "starting_position" {
  description = "The position in the stream where AWS Lambda should start reading. Must be one of AT_TIMESTAMP (Kinesis only), LATEST or TRIM_HORIZON if getting events from Kinesis, DynamoDB or MSK. Must not be provided if getting events from SQS"
  type        = string
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
variable "lambda_cidr_ingress_rules" {
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