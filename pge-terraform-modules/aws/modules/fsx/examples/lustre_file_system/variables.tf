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
variable "file_system_type" {
  description = "The type of file system.Valid values are windows & lustre."
  type        = string
}

variable "storage_capacity" {
  description = "Storage capacity (GiB) of the file system."
  type        = number
}

#KMS role

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "deployment_type" {
  description = "Specifies the file system deployment type."
  type        = string
}

variable "storage_type" {
  description = "Specifies the storage type, Valid values are SSD and HDD."
  type        = string
}

variable "per_unit_storage_throughput" {
  description = "Describes the amount of read and write throughput for each 1 tebibyte of storage, in MB/s/TiB."
  type        = string
}

variable "log_configuration_level" {
  description = "Sets which data repository events are logged by Amazon FSx."
  type        = string
}

variable "lustre_data_compression_type" {
  description = "Sets the data compression configuration for the file system. Valid values are LZ4 and NONE."
  type        = string
}

variable "lustre_file_system_type_version" {
  description = "Sets the Lustre version for the file system that you're creating. Valid values are 2.10 for SCRATCH_1, SCRATCH_2 and PERSISTENT_1 deployment types. Valid values for 2.12 include all deployment types."
  type        = string
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