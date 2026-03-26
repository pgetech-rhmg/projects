variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

#variables for Tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
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


#variables for code_repository
variable "name" {
  description = " The name of the model (must be unique)."
  type        = string
}

variable "image" {
  description = " The registry path where the inference code image is stored in Amazon ECR. aws_account_id.dkr.ecr.region.domain/repository[:tag] or [@digest]"
  type        = string
}

variable "environment" {
  description = "Environment variables for the Docker container. A list of key value pairs."
  type        = map(string)
}

variable "model_data_url" {
  description = "The URL for the S3 location where model artifacts are stored.The path must point to a single gzip compressed tar archive (.tar.gz suffix)."
  type        = string
}

variable "container_hostname" {
  description = "The DNS host name for the container."
  type        = string
}

variable "mode" {
  description = "The container hosts value SingleModel/MultiModel. The default value is SingleModel."
  type        = string
}

variable "security_group_ids" {
  description = "Identifiers of the security groups for the model"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Identifiers of the subnet_ids for the model."
  type        = list(string)
}

#variables for aws_iam_role
variable "role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}