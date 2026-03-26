variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_role" {
  type        = string
  description = "AWS role to assume"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

##############################################################################################

variable "vpc_id_name" {
  type        = string
  description = "The name given in the parameter store for the vpc id"
}

variable "subnet_id1_name" {
  type        = string
  description = "The name given in the parameter store for the subnet id 1"
}

variable "golden_ami_name" {
  type        = string
  description = "The name given in the parameter store for the golden ami"
}

###############################################################################################

variable "ebs_availability_zone" {
  description = "The names of the availability zone"
  type        = string
}

variable "ebs_snapshot_id" {
  description = "A snapshot to base the EBS volume."
  type        = string
}

variable "ebs_device_name" {
  description = "The device name to expose to the instance."
  type        = string
}

variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

variable "Optional_tags" {
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
  description = "Classification of data - can be made conditionally required based on Compliance. One of the following: Public, Internal, Confidential, Restricted, Privileged (only one)"
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

variable "ec2_name" {
  type        = string
  description = "Name to be used on EC2 instance created"
}

variable "ec2_instance_type" {
  type        = string
  description = "type of the ec2 instance"
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "sg_description" {
  description = "Security group for example usage with EBS"
  type        = string
}

variable "cidr_ingress_rules" {
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

variable "cidr_egress_rules" {
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

variable "ec2_az" {
  type        = string
  description = "List of availability zone for ec2"
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}