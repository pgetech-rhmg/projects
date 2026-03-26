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

#variables for aws_lambda_layer_version
variable "layer_version_layer_name" {
  description = "Unique name for your Lambda Layer"
  type        = string
}

variable "layer_version_compatible_architectures" {
  description = "List of Architectures this layer is compatible with. Currently x86_64 and arm64 can be specified"
  type        = string
}

variable "layer_version_compatible_runtimes" {
  description = "A list of Runtimes this layer is compatible with. Up to 5 runtimes can be specified"
  type        = list(string)
}

variable "layer_version_description" {
  description = "Description of what your Lambda Layer does"
  type        = string
}

#variables for aws_lambda_layer_version_permission
variable "layer_version_permission_action" {
  description = "Action, which will be allowed. lambda:GetLayerVersion value is suggested by AWS documantation"
  type        = string
}

variable "layer_version_permission_statement_id" {
  description = "The name of Lambda Layer Permission, for example dev-account - human readable note about what is this permission for"
  type        = string
}

variable "layer_version_permission_principal" {
  description = "AWS account ID which should be able to use your Lambda Layer. * can be used here, if you want to share your Lambda Layer widely"
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

variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variable for aws_s3_bucket
variable "s3_bucket_name" {
  description = "Name of the s3 Bucket"
  type        = string
}

#variable for aws_s3_bucket_object
variable "bucket_object_key" {
  description = "Name of the s3 Bucket"
  type        = string
}

variable "bucket_object_source" {
  description = "Name of the s3 Bucket"
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