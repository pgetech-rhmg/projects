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

variable "kms_role" {
  description = "AWS kms role to assume"
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
# variables for secrets manager
variable "secretsmanager_name" {
  description = "Name of the new secret"
  type        = string
}

variable "secretsmanager_description" {
  description = "Description of the secret"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 30
}

variable "secret_version_enabled" {
  description = "Specifies if versioning is set or not"
  type        = bool
}

variable "ssm_parameter_activation_key" {
  description = "enter the value of activation key stored in ssm parameter"
  type        = string
}

variable "fsx_file_system_association_username" {
  description = "Enter the name of secrets manager for fsx filesystem association username."
  type        = string
}

variable "fsx_file_system_association_password" {
  description = "Enter the name of secrets manager for fsx filesystem association password."
  type        = string
}

# variables for Fsx file system
variable "name" {
  description = "Name of the gateway."
  type        = string
}

variable "gateway_timezone" {
  description = "Time zone for the gateway. The time zone is of the format 'GMT', 'GMT-hr:mm', or 'GMT+hr:mm'. For example, GMT-4:00 indicates the time is 4 hours behind GMT. The time zone is used, for example, for scheduling snapshots and your gateway's maintenance schedule."
  type        = string
}

variable "gateway_type" {
  description = "Type of the gateway. The default value is STORED."
  type        = string
}

variable "gateway_vpc_endpoint" {
  description = "VPC endpoint address to be used when activating your gateway. This should be used when your instance is in a private subnet. Requires HTTP access from client computer running terraform."
  type        = string
}

variable "smb_security_strategy" {
  description = "Specifies the type of security strategy. Valid values are: ClientSpecified, MandatorySigning, and MandatoryEncryption."
  type        = string
}

# variables for cache
variable "disk_node" {
  description = "Device node of the local disk to retrieve."
  type        = string
}

# variables for module smb_file_share
variable "cache_stale_timeout_in_seconds" {
  description = "Refreshes a file share's cache by using Time To Live (TTL). TTL is the length of time since the last refresh after which access to the directory would cause the file gateway to first refresh that directory's contents from the Amazon S3 bucket. Valid Values: 300 to 2,592,000 seconds (5 minutes to 30 days)."
  type        = number
}

# varaibles cloudwatch logs
variable "logs_name" {
  description = "To identify the log group name"
  type        = string
}

# variables  for windows_file_system
variable "file_system_type" {
  description = "The type of file system.Valid values are windows & lustre."
  type        = string
}

variable "storage_capacity" {
  description = "Storage capacity (GiB) of the file system."
  type        = number
}

variable "deployment_type" {
  description = "Specifies the file system deployment type."
  type        = string
}

variable "storage_type" {
  description = "Specifies the storage type, Valid values are SSD and HDD."
  type        = string
}

variable "throughput_capacity" {
  description = "Throughput (megabytes per second) of the file system in power of 2 increments."
  type        = number
}

variable "windows_shared_active_directory_id" {
  description = "The ID for an existing Microsoft Active Directory instance that the file system should join when it's created."
  type        = string
}

variable "file_access_audit_log_level" {
  description = "Sets which attempt type is logged by Amazon FSx for file and folder accesses. Valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE, and DISABLED."
  type        = string
}

variable "file_share_access_audit_log_level" {
  description = "Sets which attempt type is logged by Amazon FSx for file share accesses. Valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE, and DISABLED."
  type        = string
}

variable "skip_final_backup" {
  description = "When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false."
  type        = bool
}

variable "file_system_timeouts" {
  description = "windows_file_system provides the following Timeouts configuration options: create, update, delete."
  type        = map(string)
}

variable "domain_name" {
  description = "The name of the domain that you want the gateway to join."
  type        = string
}

variable "password" {
  description = "The password of the user who has permission to add the gateway to the Active Directory domain."
  type        = string
}

variable "username" {
  description = "The user name of user who has permission to add the gateway to the Active Directory domain."
  type        = string
}

variable "timeouts" {
  description = <<-DOC
  {
    create : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"
    update : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 10m"
    delete : "The timeouts should be in the format 1200m for 120 minutes, 10s for ten seconds, or 2h for two hours. Default 15m"
  }
  DOC
  type = object({
    create = string
    update = string
    delete = string
  })
}

# variables for module iam 
variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
}

# variables for ssm parameter Store
variable "ssm_parameter_vpc_id" {
  description = "enter the value of vpc id stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id1" {
  description = "enter the value of subnet id1 stored in ssm parameter"
  type        = string
}