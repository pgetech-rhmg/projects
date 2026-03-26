# assume_role used in terraform.tf

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

# tags

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

# single_node

variable "node_type" {
  description = "The instance class used. See AWS documentation for information on supported node types for Redis and guidance on selecting node types for Redis"
  type        = string
}

variable "redis_engine_version" {
  description = " Version number of the cache engine to be used. If not set, defaults to the latest version. When the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute engine_version_actual."
  type        = string
}

variable "final_snapshot" {
  description = "The name of your final snapshot. If omitted, no final snapshot will be made."
  type        = string
}

variable "snapshot_retention" {
  description = "Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off. snapshot_retention_limit is not supported on cache.t1.micro cache nodes"
  type        = number
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00"
  type        = string
}

variable "snapshot_window" {
  description = "Daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. Example: 05:00-09:00"
  type        = string
}

variable "cluster_id" {
  description = "Replication group identifier. This parameter is stored as a lowercase string."
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

# security_group

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


# kms_key

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

# aws_elasticache_global_replication_group

variable "global_suffix" {
  description = "The suffix name of a Global Datastore. If global_replication_group_id_suffix is changed, creates a new resource."
  type        = string
}
