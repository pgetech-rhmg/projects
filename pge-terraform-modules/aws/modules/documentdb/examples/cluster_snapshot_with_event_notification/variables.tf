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
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id3 stored in ssm parameter"
  type        = string
}

#variables for the module docdb_cluster
variable "cluster_engine_version" {
  description = "The database engine version. Updating this argument results in an outage."
  type        = string
}

variable "cluster_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier."
  type        = string
}

variable "cluster_timeouts" {
  description = "aws_docdb_cluster provides the following Timeouts configuration options: create, update, delete"
  type        = map(string)
}

#Common variable for name
variable "name" {
  description = "The common name for all the name arguments in resources."
  type        = string
}

#Variables for cluster parameter group
variable "docdb_cluster_parameter_group_family" {
  description = "The family of the documentDB cluster parameter group."
  type        = string
}

variable "parameter" {
  description = "A list of documentDB parameters to apply"
  type        = list(map(string))
}

#Variables for event subscription
variable "source_type" {
  description = "The type of source that will be generating the events. Valid options are db-instance, db-security-group, db-parameter-group, db-snapshot, db-cluster or db-cluster-snapshot. If not set, all sources will be subscribed to."
  type        = string
}

variable "event_categories" {
  description = "A list of event categories for a source_type that you want to subscribe to. If the end user is not passing any values to this variable, then it will take all the possible values."
  type        = list(string)
}

#Variables for sns topic
variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
}

#Variables for cluster_instance
variable "cluster_instance_instance_class" {
  description = "The instance class to use."
  type        = string
}

#Variables for KMS
variable "description" {
  description = "The description of the key as viewed in AWS console."
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

variable "Compliance" {
  description = "Compliance    Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}