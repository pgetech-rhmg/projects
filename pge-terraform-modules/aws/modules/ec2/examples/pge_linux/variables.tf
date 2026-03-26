
variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "instance_profile_role" {
  description = "Managed IAM role for the instance profile creation"
  type        = string
  default     = null
}


variable "kms_name" {
  type        = string
  description = "KMS key name for S3 bucket encryption"
}
variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "Name" {
  description = "Name to be used on EC2 instance created"
  type        = string
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

variable "Compliance" {
  type        = list(string)
  description = "Compliance	Identify assets with compliance requirements (SOX, HIPAA, etc.) Note: not adding NERC workloads to cloud"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
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

variable "cidr_ingress_rules" {
  description = "Ingress rule for the CIDR network range"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

variable "cidr_egress_rules" {
  description = "Egress rule for the CIDR network range"
  type = list(object({
    from             = number
    to               = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    description      = string
  }))
  default = []
}

variable "optional_tags" {
  description = "Optional tags for resource"
  type        = map(string)
  default     = {}
}

variable "InstanceType" {
  type        = string
  description = "EC2 Instance type"
}

variable "AvailabilityZone" {
  description = "AZ to start the instance in"
  type        = string
}

variable "metadata_http_endpoint" {
  description = "Whether the metadata service is available. Valid values include enabled or disabled"
  type        = string
}