#Variables for provider 
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
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

#variables  for windows_file_system
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

#Common variable for name
variable "name" {
  description = "The common name for all the name arguments in resources."
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

#KMS role
variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}