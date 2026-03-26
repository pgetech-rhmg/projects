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

#Variables for kms
variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

#Variables for Tags
variable "optional_tags" {
  description = "optional_tags"
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
  description = "Classification of data can be made conditionally required based on Compliance.One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
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


#Variables for flow_definition
variable "name" {
  description = "The name of the Code Repository (must be unique)."
  type        = string
}

variable "task_availability_lifetime_in_seconds" {
  description = "The length of time that a task remains available for review by human workers."
  type        = number
}

variable "task_count" {
  description = "The number of distinct workers who will perform the same task on each object."
  type        = number
}

variable "task_keywords" {
  description = "An array of keywords used to describe the task so that workers can discover the task."
  type        = list(string)
}

variable "task_time_limit_in_seconds" {
  description = "The amount of time that a worker has to complete a task."
  type        = number
}

variable "task_title" {
  description = "A title for the human worker task."
  type        = string
}

variable "workteam_arn" {
  description = "The Amazon Resource Name (ARN) of the human task user interface. Amazon Resource Name (ARN) of a team of workers."
  type        = string
}

variable "human_loop_activation_config" {
  description = "An object containing information about the events that trigger a human workflow."
  type        = map(any)
}

variable "human_loop_request_source" {
  description = "Container for configuring the source of human task requests. Use to specify if Amazon Rekognition or Amazon Textract is used as an integration source."
  type        = map(any)
}

#Variables for human_task_ui
variable "content" {
  description = "The content of the Liquid template for the worker user interface."
  type        = string
}

#Variables for iam_role
variable "aws_service" {
  description = "A list of AWS services allowed to assume this role. Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
}