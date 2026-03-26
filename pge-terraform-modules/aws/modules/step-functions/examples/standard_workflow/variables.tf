#Variables for provider 
variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "kms_key_type" {
  description = "KMS key type"
  type        = string
  default     = "AWS_OWNED_KEY" # change it to CUSTOMER_MANAGED_KMS_KEY when encryption is trurned on 
}

variable "account_num" {
  description = "Target AWS account number, mandatory."
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#variable for standard_workflow
variable "state_machine_definition" {
  description = "Name of the file which contains the state machine definition."
  type        = string
}

#Common variable for name
variable "name" {
  description = "The common name for all the name arguments in resources."
  type        = string
}

#variables for module standard_workflow
variable "tracing_configuration_enabled" {
  description = "When set to true, AWS X-Ray tracing is enabled."
  type        = bool
}

#variable for cloudwatch_log-group
variable "cloudwatch_log_name_prefix" {
  description = "A name for the log group."
  type        = string
}

#variables for Lambda_function
variable "handler" {
  description = "Function entrypoint in your code."
  type        = string
}

variable "runtime" {
  description = "Identifier of the function's runtime."
  type        = string
}

variable "local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive."
  type        = string
}

#variables for aws_lambda_iam_role
variable "lambda_iam_role_name" {
  description = "Name of the IAM role."
  type        = string
}

variable "lambda_iam_aws_service" {
  description = "AWS service of the IAM role."
  type        = list(string)
}

variable "lambda_iam_policy_arns" {
  description = "Policy arn for the IAM role."
  type        = list(string)
}

#variables for aws_state_machine_iam_role
variable "state_machine_iam_role_name" {
  description = "Name of the IAM role."
  type        = string
}

variable "state_machine_iam_aws_service" {
  description = "AWS service of the IAM role."
  type        = list(string)
}

variable "state_machine_iam_policy_arns" {
  description = "Policy arn for the IAM role."
  type        = list(string)
}

variable "publish" {
  description = "Boolean flag to control whether to publish a version of the state machine during creation."
  type        = bool
  default     = false
}

#parameter store
variable "vpc_id_name" {
  description = "The name given in the parameter store for the vpc id."
  type        = string
}

variable "subnet_id1_name" {
  description = "The name given in the parameter store for the subnet id 1."
  type        = string
}

#variables for vpc-endpoint
variable "private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC."
  type        = bool
}

variable "service_name" {
  description = "The service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service>."
  type        = string
}

#variables for vpc-endpoint security group
variable "vpce_security_group_name" {
  description = "Name of the security group."
  type        = string
}

#Variables for Tags
variable "optional_tags" {
  description = "Optional_tags."
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####."
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)."
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)."
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3."
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud."
  type        = list(string)
}


# KMS vars

variable "kms_key_id" {
  description = "The KMS key to be used for encryption. Can be a key ID, alias, or ARN of the key ID or alias."
  type        = string
  default     = null
}


variable "kms_name" {
  type        = string
  description = "KMS key name"
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}