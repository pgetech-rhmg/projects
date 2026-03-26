variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
}

variable "secretsmanager_description" {
  description = "Description of the secret"
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


variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
}

variable "rotation_enabled" {
  description = "Specifies if rotation is set or not"
  type        = bool
}

variable "secret_string" {
  type        = string
  description = "Specifies text data that you want to encrypt and store in this version of the secret"
}

variable "rotation_after_days" {
  description = "A structure that defines the rotation configuration for this secret"
  type        = number
}

variable "vpc_id_name" {
  type        = string
  description = "The name given in the parameter store for the vpc id"
}

variable "subnet_id_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id"
}

variable "policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}

#variables for kms_key
variable "kms_name" {
  type        = string
  description = "Unique name of kms for encrypting secret manager"
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

#variables for lambda function
variable "lambda_function_name" {
  type        = string
  description = "Secretsmanager lambda function name"
}

variable "lambda_description" {
  type        = string
  description = "Secretsmanager lambda function description"
}

variable "lambda_handler_name" {
  type        = string
  description = "Secretsmanager lambda handler"
}

variable "lambda_runtime" {
  type        = string
  description = "Secretsmanager lambda runtime"
}

variable "source_dir" {
  description = "Package entire contents of this directory into the archive."
  type        = string
}

variable "timeout" {
  type        = number
  description = "Lambda function timeout value"
}

variable "publish" {
  type        = bool
  description = "Whether to publish creation/change as new Lambda Function Version"
}

variable "action" {
  description = "Action for lambda policy"
  type        = string
}

variable "principal" {
  description = "Principal id for lambda policy"
  type        = string
}

variable "environment_variables" {
  description = "Map of environment variables that are accessible from the function code during execution"
  type        = map(string)
}

#aws_lambda_iam_role
variable "role_name" {
  description = "Name of the iam role"
  type        = string
}

variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#variables for security_group_lambda
variable "sg_name_lambda" {
  description = "Name of the security group"
  type        = string
}

variable "cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

#variable for tags
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
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
}

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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