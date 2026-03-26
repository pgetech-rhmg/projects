# Variables for assume_role used in terraform.tf

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_role" {
  description = "AWS role"
  type        = string
}

variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
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

variable "domain_name" {
  description = "OpenSearch Domain name"
  type        = string
}

variable "engine_version" {
  description = "Opensearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "vpc_options" {
  description = "Configuration block for VPC options"
  type        = list(any)
}

variable "advanced_security_options" {
  description = ""
  type        = list(any)
}

variable "domain_endpoint_options" {
  description = ""
  type        = list(any)
}

variable "cluster_config" {
  description = "Configuration block for Cluster"
  type        = list(any)
  default     = []
}

variable "node_to_node_encryption_options" {
  description = "Configuration block for encryption options"
  type        = list(any)
}

variable "ebs_options" {
  description = "Configuration block for EBS options"
  type        = list(any)
  default     = []
}

variable "log_publishing_options" {
  description = "Configuration block for log publishing options"
  type        = list(any)
  default     = []
}

variable "encrypt_at_rest_options" {
  description = "Configuration block for encryption at rest options"
  type        = list(any)
}

variable "advanced_options" {
  description = "Key-value string pairs to specify advanced configuration options"
  type        = map(string)
}

variable "security_group_ids" {
  type        = list(any)
  description = "(optional) describe your variable"
}

variable "subnet_ids" {
  type        = list(any)
  description = "(optional) describe your variable"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}