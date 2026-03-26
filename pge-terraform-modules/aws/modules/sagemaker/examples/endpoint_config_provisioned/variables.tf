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

# variables for endpoint_configuration
variable "name" {
  description = "The name of the endpoint configuration. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "initial_instance_count" {
  description = "Initial number of instances used for auto-scaling."
  type        = number
}

variable "instance_type" {
  description = "The type of instance to start."
  type        = string
}

variable "model_name" {
  description = "The name of the model to use."
  type        = string
}

variable "variant_name" {
  description = "The name of the variant. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "async_inference_config" {
  description = "Specifies configuration for how an endpoint performs asynchronous inference. This is a required field in order for your Endpoint to be invoked."
  type        = any
}

# variables for kms
variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}