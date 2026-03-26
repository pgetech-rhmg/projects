#Variables used for assume_role used in terraform.tf

variable "aws_region" {
  description = "AWS region to create the resource.For CLOUDFRONT, you must create your WAFv2 resources in the us-east-1,(N. Virginia) Region."
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

# Variables for Tags

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

# Variables for cluster

variable "cluster_id" {
  description = "Group identifier. ElastiCache converts this name to lowercase. Changing this value will re-create the resource."
  type        = string
}

variable "nodetype" {
  description = "The instance class used. See AWS documentation for information on supported node types for Redis and guidance on selecting node types for Redis"
  type        = string
}

variable "slow_logs_log_delivery_destination" {
  description = "Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource"
  type        = string
}

variable "slow_logs_log_delivery_destination_type" {
  description = "For CloudWatch Logs use cloudwatch-logs or for Kinesis Data Firehose use kinesis-firehose"
  type        = string
}

variable "slow_logs_log_delivery_log_format" {
  description = "Valid values are json or text"
  type        = string
}

variable "final_snapshot" {
  description = "The name of your final snapshot when the replication group is deleted."
  type        = string
}

variable "apply_immediately" {
  description = "Whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "redis_engine_version" {
  description = " Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine_version_actual."
  type        = string
  default     = null
}

#Variables for replication group
variable "num_node_groups" {
  description = "Number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications. Required unless global_replication_group_id is set."
  type        = string
}

variable "replicas_per_node_group" {
  description = "Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will trigger an online resizing operation before other settings modifications."
  type        = string
}

variable "ssm_parameter_name_auth_token" {
  description = "Enter the SSM parameter name for the auth_token. Auth_token is the password used to access a password protected server."
  type        = string
}

variable "ssm_parameter_name_vpc_id" {
  description = "Enter the SSM Parameter name for the vpc_id."
  type        = string
}

variable "ssm_parameter_name_private_subnet1" {
  description = "Enter the SSM Parameter name for the private subnet id-1."
  type        = string
}

variable "ssm_parameter_name_private_subnet2" {
  description = "Enter the SSM Parameter name for the private subnet id-2."
  type        = string
}

# Variables for security group

variable "sg_name" {
  description = "name of the security group associated with lambda"
  type        = string
}

variable "sg_description" {
  description = "description for security group associated with lambda"
  type        = string
}

variable "cidr_ingress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    description      = string
    prefix_list_ids  = list(string)
  }))
}

variable "cidr_egress_rules" {
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    description      = string
    prefix_list_ids  = list(string)
  }))
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