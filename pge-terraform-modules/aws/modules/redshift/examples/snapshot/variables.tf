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
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
  type        = list(string)
}


#Variables for parameter_group
variable "name" {
  description = "The name of the Redshift parameter group."
  type        = string
}

#variables for ssm parameter Store
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

variable "snapshot_schedule_definitions" {
  description = "The definition of the snapshot schedule."
  type        = list(string)
}



#Variables for Redshift Event Subscription
variable "enabled" {
  description = "A boolean flag to enable/disable the subscription.Defaults to true."
  type        = bool
}

variable "source_type" {
  description = "The type of source that will be generating the events."
  type        = string
}

variable "source_ids" {
  description = "A list of identifiers of the event sources for which events will be returned. If not specified, then all sources are included in the response."
  type        = list(string)
}

variable "event_categories" {
  description = "A list of event categories for a SourceType that you want to subscribe to."
  type        = list(string)
}
#Variables for sns topic
variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = string
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
}



#Variables for kms
variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "template_file_name" {
  description = "Custom KMS policy file name"
  type        = string
}

#variables for cluster-Snapshot copy grant
variable "destination_region" {
  description = "The destination region that you want to copy snapshots to."
  type        = string
}

variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

variable "retention_period" {
  description = "The number of days to retain automated snapshots in the destination region after they are copied from the source region. Defaults to 7."
  type        = number
}



# Variables for Cluster
variable "node_type" {
  description = "The node type to be provisioned for the cluster."
  type        = string
}

variable "cluster_type" {
  description = "The cluster type to use. Either single-node or multi-node"
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster."
  type        = bool
}

variable "cluster_role_service" {
  description = "Aws service of the iam role"
  type        = list(string)
}

#Variables for S3
variable "s3_key_prefix" {
  description = "The prefix applied to the log file names."
  type        = string
}


#Variable for Time Sleep
variable "create_duration" {
  description = "Time duration to delay resource creation. For example, 30s for 30 seconds or 5m for 5 minutes. Updating this value by itself will not trigger a delay."
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

