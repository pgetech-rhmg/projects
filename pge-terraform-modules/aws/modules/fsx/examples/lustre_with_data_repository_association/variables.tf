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

#variables  for lustre_file_system
variable "storage_capacity" {
  description = "Storage capacity (GiB) of the file system."
  type        = number
}

variable "per_unit_storage_throughput" {
  description = "Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB."
  type        = string
}

variable "log_configuration_level" {
  description = "Sets which data repository events are logged by Amazon FSx."
  type        = string
}

#variables for data repository association
variable "file_system_path" {
  description = "A path on the file system that points to a high-level directory (such as /ns1/) or subdirectory (such as /ns1/subdir/) that will be mapped 1-1 with data_repository_path."
  type        = string
}

variable "auto_export_policy_events" {
  description = "A list of file event types to automatically export to your linked S3 bucket. Valid values are NEW, CHANGED, DELETED."
  type        = list(string)
}

variable "auto_import_policy_events" {
  description = "A list of file event types automatically import from the linked S3 bucket. Valid values are NEW, CHANGED, DELETED. Max of 3."
  type        = list(string)
}

variable "data_repository_association_timeouts" {
  description = "Provide the timeouts configurations."
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