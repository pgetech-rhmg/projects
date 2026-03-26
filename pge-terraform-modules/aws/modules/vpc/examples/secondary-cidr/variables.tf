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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
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

variable "Order" {
  type        = number
  description = "Order as a tag to be associated with an AWS resource"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}

variable "account_num" {
  description = "AWS Account Number where the resources will be created"
  type        = string
  default     = ""
}
variable "aws_role" {
  description = "The name of the role to assume in the target account."
  type        = string
  default     = "CloudAdmin"
}
###### Secondary cidr #####
variable "parameter_vpc_id_name" {
  type        = string
  default     = null
  description = "SSM Parameter name where the VPC ID is stored"
}

variable "subnet_a_cidr" {
  default     = null
  type        = string
  description = "The IPv4 CIDR block assigned to the subnet_a"
}

variable "subnet_b_cidr" {
  type        = string
  default     = null
  description = "The IPv4 CIDR block assigned to the subnet_b"
} 
variable "subnet_c_cidr" {
  type        = string
  default     = null
  description = "The IPv4 CIDR block assigned to the subnet_c"
} 

variable "subnet_a_name"  {
  type        = string
  default     = "subnet-azA"
  description = "The name tag to assign to subnet A"
}

variable "subnet_b_name"  {
  type        = string
  default     = "subnet-azB"
  description = "The name tag to assign to subnet B"
}

variable "subnet_c_name"  {
  type        = string
  default     = "subnet-azC"
  description = "The name tag to assign to subnet C"
}


variable "parameter_subnet_idb" {
  type        = string
  default     = null
  description = "SSM parameter name to store subnet id b of secondary cidr"
}

variable "parameter_subnet_idc" {
  type        = string
  default     = null
  description = "SSM parameter name to store subnet id c of secondary cidr"
}

variable "parameter_subnet_ida" {
  type        = string
  default     = null
  description = "SSM parameter name to store subnet id a of secondary cidr"
}

variable "parameter_transit_gateway" {
  type        = string
  default     = null
  description = "Id of the transit gate-way"
}

variable "parameter_sec_vpc_cidr" {
  type        = string
  default     = "100.64.0.0/16"
  description = "secondary IP cidr assigned to the VPC"
}

variable "create_vpc_sec_cidr" {
  type        = bool
  default     = false
  description = "create secondary cidr integration with vpc if true"
}
