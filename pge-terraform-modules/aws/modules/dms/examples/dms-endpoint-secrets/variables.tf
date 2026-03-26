# Variables for assume_role used in terraform.tf

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
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

# Variables for source endpoint

variable "source_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
}

variable "source_endpoint_engine_name" {
  description = "Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
  type        = string
}

variable "source_endpoint_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
}

variable "source_endpoint_database_name" {
  description = "Name of the endpoint database."
  type        = string
}

variable "source_endpoint_secrets_manager_arn" {
  description = "Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver."
  type        = string
}

variable "source_certificate_arn" {
  description = "ARN of the source SSL certificate"
  type        = string
}




# Variables for target endpoint

variable "target_endpoint_id" {
  description = "Database endpoint identifier. Identifiers must contain from 1 to 255 alphanumeric characters or hyphens, begin with a letter, contain only ASCII letters, digits, and hyphens, not end with a hyphen, and not contain two consecutive hyphens."
  type        = string
}

variable "target_endpoint_engine_name" {
  description = "Type of engine for the endpoint. Valid values are aurora, aurora-postgresql, azuredb, db2, docdb, dynamodb, mariadb,  mysql, opensearch, oracle, postgres, sqlserver, sybase. Please note that some of engine names are available only for target endpoint type (e.g. redshift)."
  type        = string
}

variable "target_endpoint_ssl_mode" {
  description = "SSL mode to use for the connection. Valid values are: none, require, verify-ca, verify-full. As per SAF, for each DMS endpoint where there is a port required, make sure the SSLMode is not 'None'."
  type        = string
}

variable "target_endpoint_database_name" {
  description = "Name of the endpoint database."
  type        = string
}

variable "target_endpoint_secrets_manager_arn" {
  description = "Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver."
  type        = string
}

variable "target_certificate_arn" {
  description = "ARN of the target SSL certificate"
  type        = string
}

# Variables for KMS

variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

# Variables for IAM

variable "iam_role_name" {
  type        = string
  description = "Enter the role name for access endpoints"
}

variable "role_service" {
  type        = list(string)
  description = "Aws service of the iam role"
}

variable "iam_policy_arns" {
  description = "Policy arn for the iam role"
  type        = list(string)
}

# Variables for replication instance with subnet_group

variable "replication_subnet_group_description" {
  type        = string
  description = "The description for the subnet group."
}

variable "replication_subnet_group_id" {
  type        = string
  description = "The name for the replication subnet group. This value is stored as a lowercase string."
}

variable "role_name_access_endpoint" {
  type        = string
  description = "Enter the role name for access endpoints"
}

variable "role_name_cloudwatch_logs" {
  type        = string
  description = "Enter the role name for cloudwatch logs"
}

variable "role_name_vpc" {
  type        = string
  description = "Enter the role name for vpc"
}

variable "instance_allocated_storage" {
  type        = number
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance."
}

variable "instance_apply_immediately" {
  type        = bool
  description = "Indicates whether the changes should be applied immediately or during the next maintenance window. Only used when updating an existing resource."
}

variable "instance_version_upgrade" {
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the replication instance during the maintenance window."
}

variable "instance_allow_major_version_upgrade" {
  type        = bool
  description = "(Optional, Default: false) Indicates that major version upgrades are allowed."
  default     = false
}

variable "instance_availability_zone" {
  type        = string
  description = "The EC2 Availability Zone that the replication instance will be created in."
}

variable "instance_engine_version" {
  type        = string
  description = "The engine version number of the replication instance."
}

variable "instance_multi_az" {
  type        = bool
  description = "Specifies if the replication instance is a multi-az deployment. You cannot set the availability_zone parameter if the multi_az parameter is set to true."
}

variable "instance_preferred_maintenance" {
  type        = string
  description = "The weekly time range during which system maintenance can occur, in Universal Coordinated Time (UTC)."
}

variable "instance_publicly_accessible" {
  type        = bool
  description = "Specifies the accessibility options for the replication instance. A value of true represents an instance with a public IP address. A value of false represents an instance with a private IP address."
}

variable "instance_replication_instance_class" {
  type        = string
  description = "The compute and memory capacity of the replication instance as specified by the replication instance class."
}

variable "instance_replication_id" {
  type        = string
  description = "The replication instance identifier."
  validation {
    condition = alltrue([
      length(var.instance_replication_id) >= 1 && length(var.instance_replication_id) <= 63
    ])
    error_message = "Must contain from 1 to 63 alphanumeric characters or hyphens. and can contain only the following characters:a-z,A-Z,0-9,_(underscore),-(dash),.(dot)."
  }
}

#variables for security_group_project
variable "cidr_egress_rules_replication_instance" {
  description = "CIDR-based egress rules for DMS replication instance security group"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "cidr_ingress_rules_replication_instance" {
  description = "CIDR-based ingress rules for DMS replication instance security group"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
}

variable "sg_name_replication_instance" {
  description = "name of the security group"
  type        = string
}

variable "sg_description_replication_instance" {
  description = "vpc id for security group"
  type        = string
}

#support resource
variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id_1 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id_2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id_3 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

# Variables for dms replication task

variable "migration_type" {
  description = "The migration type. Can be one of full-load | cdc | full-load-and-cdc."
  type        = string
}

variable "replication_task_id" {
  description = "The replication task identifier.Must contain from 1 to 255 alphanumeric characters or hyphens.First character must be a letter.Cannot end with a hyphen.Cannot contain two consecutive hyphens."
  type        = string
}

# Variables for event_subscription

variable "event_enabled" {
  type        = bool
  description = "Whether the event subscription should be enabled."
  default     = null
}

variable "event_categories" {
  type        = list(string)
  description = "List of event categories to listen for, see DescribeEventCategories for a canonical list."
  default     = null
}

variable "event_name" {
  type        = string
  description = "Name of event subscription."
}

variable "source_ids" {
  type        = list(string)
  description = "Ids of sources to listen to."
}

variable "source_type" {
  type        = string
  description = "Type of source for events. Valid values: replication-instance or replication-task"
}

# Variables for SNS

variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

