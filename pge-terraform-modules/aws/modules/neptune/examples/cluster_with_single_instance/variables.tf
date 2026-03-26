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
  description = "AWS kms role to assume"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "Compliance" {
  description = "Compliance    Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}

#common variable for name
variable "name" {
  description = "A common name for resources."
  type        = string
}

#variable for cluster 
variable "engine_version" {
  description = "(Optional) The neptune engine version."
  type        = string
}

variable "skip_final_snapshot" {
  description = "(Optional) Determines whether a final Neptune snapshot is created before the Neptune cluster is deleted. If true is specified, no Neptune snapshot is created. If false is specified, a Neptune snapshot is created before the Neptune cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  type        = bool
  default     = false
}

#variable for cluster instance
variable "instance_class" {
  description = "The instance class to use."
  type        = string
}

#Variables for Cluster endpoint
variable "neptune_cluster_endpoint_type" {
  description = "The type of the endpoint. One of: READER, WRITER, ANY."
  type        = string
}

#Variables for Cluster parameter group
variable "neptune_streams_value" {
  description = "The value of the neptune cluster parameter neptune_streams."
  type        = string
}

variable "neptune_lookup_cache_value" {
  description = "The value of the neptune cluster parameter neptune_lookup_cache."
  type        = string
}

variable "neptune_result_cache_value" {
  description = "The value of the neptune instance parameter neptune_result_cache"
  type        = string
}

variable "neptune_ml_iam_role_value" {
  description = "The value of the neptune cluster parameter neptune_ml_iam_role."
  type        = string
}

variable "neptune_ml_endpoint_value" {
  description = "The value of the neptune cluster parameter neptune_ml_endpoint."
  type        = string
}

#Variables for Instance parameter group
variable "neptune_dfe_query_engine_value" {
  description = "The value of the neptune instance parameter neptune_dfe_query_engine.Allowed values are as follows: enabled and viaQueryHint (the default) "
  type        = string
}

variable "neptune_query_timeout_value" {
  description = "The value of the neptune instance parameter neptune_query_timeout.This DB instance parameter specifies a timeout duration for graph queries, in milliseconds, for one instance. Valid values: 10 to 2,147,483,647 (231 - 1)"
  type        = number
}

#Variables for subnet group - ssm parameter
variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id1 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id3 stored in ssm parameter"
  type        = string
}

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
  default     = ""
}