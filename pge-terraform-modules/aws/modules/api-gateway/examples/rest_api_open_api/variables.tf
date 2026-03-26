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

#variable for module api_gateway_rest_api
variable "rest_api_name" {
  description = "Name of the REST API."
  type        = string
}


variable "pVpcEndpoint" {
  description = "Vpc-endpoint for the resource policy"
  type        = string
}

#variable for api_gateway_deployment_and_stage
variable "stage_name" {
  description = "The name of the stage"
  type        = string
}

variable "stage_cache_cluster_enabled" {
  description = "Specifies whether a cache cluster is enabled for the stage."
  type        = bool
}

variable "stage_cache_cluster_size" {
  description = "The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
  type        = number
}

# api_gateway_method_settings
variable "method_settings_method_path" {
  description = "Method path defined as {resource_path}/{http_method} for an individual method override."
  type        = string
}

variable "settings_logging_level" {
  description = "Specifies the logging level for this method, which effects the log entries pushed to Amazon CloudWatch Logs."
  type        = string
}

#api_gateway_api_key
variable "api_key_name" {
  description = "The name of the API key."
  type        = string
}

#variables for api_gateway_usage_plan
variable "usage_plan_name" {
  description = "The name of the usage plan."
  type        = string
}

variable "usage_plan_description" {
  description = " The description of a usage plan."
  type        = string
}

# variables for usage_plan_key
variable "usage_plan_key_type" {
  description = "The type of the API key resource. Currently, the valid key type is API_KEY."
  type        = string
}

#variable for optional_tags
variable "optional_tags" {
  description = "optional_tags"
  type        = map(string)
  default     = {}
}

#variable tags
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