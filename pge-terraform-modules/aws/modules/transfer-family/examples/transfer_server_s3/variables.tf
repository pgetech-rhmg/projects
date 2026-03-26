#Variables for provider
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "kms_role" {
  description = "AWS KMS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#Variables for ssm parameter
variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id1 stored in ssm parameter"
  type        = string
}

# Variables for tags
variable "optional_tags" {
  description = "Optional tags"
  type        = map(string)
  default     = {}
}

variable "AppID" {
  description = "Identify the application this asset belongs to by its AMPS APP ID.Format = APP-####"
  type        = number
}

variable "Environment" {
  description = "The environment in which the resource is provisioned and used, such as Dev, Test, QA, Prod."
  type        = string
}

variable "DataClassification" {
  description = "Classification of data - can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
  type        = string
}

variable "CRIS" {
  description = "Cyber Risk Impact Score High, Medium, Low (only one)"
  type        = string
}

variable "Notify" {
  description = "Who to notify for system failure or maintenance. Should be a group or list of email addresses."
  type        = list(string)
}

variable "Owner" {
  description = "List three owners of the system, as defined by AMPS Director, Client Owner and IT Leadeg LANID1_LANID2_LANID3"
  type        = list(string)
}

variable "Compliance" {
  description = "Compliance Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

#Common variable for name
variable "name" {
  description = "A common name for resources."
  type        = string
}

#Variables for transfer server
variable "endpoint_type" {
  description = "The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC_ENDPOINT), your SFTP server isn't accessible over the public internet."
  type        = string
}

variable "directory_id" {
  description = "The directory service ID of the directory service you want to connect to with an identity_provider_type of AWS_DIRECTORY_SERVICE."
  type        = string
}

#Variables for iam
variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
}

#Variables for transfer workflow
variable "source_file_location" {
  description = "Specifies which file to use as input to the workflow step: either the output from the previous step, or the originally uploaded file for the workflow."
  type        = string
}

variable "type1" {
  description = "One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG."
  type        = string
}

variable "type2" {
  description = "One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG."
  type        = string
}

variable "type3" {
  description = "One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG."
  type        = string
}

variable "type4" {
  description = "One of the following step types are supported. COPY, CUSTOM, DELETE, and TAG."
  type        = string
}

variable "timeout_seconds" {
  description = "Timeout, in seconds, for the step."
  type        = number
}

#Variables for S3 object
variable "bucket_object_key" {
  description = "Name of the object once it is in the bucket."
  type        = string
}

#Variables for Lambda
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

variable "local_zip_source_directory" {
  description = "Package entire contents of this directory into the archive"
  type        = string
}

#Variables for transfer access
variable "external_id" {
  description = "The SID of a group in the directory connected to the Transfer Server."
  type        = string
}