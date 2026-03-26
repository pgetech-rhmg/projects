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

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

variable "ssm_parameter_subnet_id2" {
  description = "enter the value of subnet id2 stored in ssm parameter"
  type        = string
}

variable "ssm_parameter_subnet_id3" {
  description = "enter the value of subnet id3 stored in ssm parameter"
  type        = string
}

# variables for notebook_instance
variable "name" {
  description = "The name of the notebook instance (must be unique)."
  type        = string
}

variable "instance_type" {
  description = "The name of ML compute instance type."
  type        = string
}

variable "platform_identifier" {
  description = "The platform identifier of the notebook instance runtime environment. This value can be either notebook-al1-v1, notebook-al2-v1, or notebook-al2-v2, depending on which version of Amazon Linux you require."
  type        = string
}

variable "volume_size" {
  description = "The size, in GB, of the ML storage volume to attach to the notebook instance. The default value is 5 GB."
  type        = number
}

variable "direct_internet_access" {
  description = "Set to Disabled to disable internet access to notebook. Requires security_groups and subnet_id to be set. Supported values: Enabled (Default) or Disabled. If set to Disabled, the notebook instance will be able to access resources only in your VPC, and will not be able to connect to Amazon SageMaker training and endpoint services unless your configure a NAT Gateway in your VPC."
  type        = string
}

variable "lifecycle_config_name" {
  description = "The name of a lifecycle configuration to associate with the notebook instance."
  type        = string
}

variable "root_access" {
  description = "Whether root access is Enabled or Disabled for users of the notebook instance. The default value is Enabled."
  type        = string
}

variable "metadata_service_version" {
  description = "Indicates the minimum IMDS version that the notebook instance supports. When passed 1 is passed. This means that both IMDSv1 and IMDSv2 are supported. Valid values are 1 and 2."
  type        = number
}

# variables for IAM
variable "role_service" {
  description = "AWS service of the iam role"
  type        = list(string)
}