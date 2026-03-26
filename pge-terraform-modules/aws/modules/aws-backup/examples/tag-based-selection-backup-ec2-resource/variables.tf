variable "account_num" {
  description = "Target AWS account number, mandatory. "
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume."
  type        = string
}

variable "Order" {
  description = "Order as a tag to be associated with an AWS resource"
  type        = number
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

####################################################
# Variables for Tags
####################################################

#Variables for Tag


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

variable "optional_tags" {
  description = "optional_tags."
  type        = map(string)
  default     = {}
}

variable "aws_backup_tags" {
  description = "Tags assigned to resources for backup"
  type        = map(string)
  default     = {}
}


###########################################################
# variables for Backup vault
###########################################################

variable "vault_name" {
  description = "Name of the backup vault to create"
  type        = string
}

variable "create_vault_notifications" {
  description = "Change to true if vault notifications needs to be enabled"
  type        = bool
}

variable "backup_vault_events" {
  description = "An array of events that indicate the status of jobs to back up resources to the backup vault."
  type        = list(string)
}

###########################################################
# variables for Backup plan
###########################################################

variable "aws_backup_plan_name" {
  description = "The display name of a backup plan"
  type        = string
}

variable "aws_backup_plan_rule" {
  description = "Enable Windows VSS backup option and create a VSS Windows backup"
  type        = list(any)
}

###########################################################
# variables for Backup Selection
###########################################################

variable "backup_selection_name" {
  description = "The display name of a resource selection document."
  type        = string
}

variable "selection_tags" {
  description = "An array of tag condition objects used to filter resources based on tags for assigning to a backup plan"
  type        = any
}

###########################################################
# variables for IAM role
###########################################################


variable "iam_role_name" {
  description = "IAM Role Name"
  type        = string
  default     = null
}

variable "aws_service" {
  description = "A list of AWS services allowed to assume this role.  Required if the trusted_aws_principals variable is not provided."
  type        = list(string)
  validation {
    condition     = length(var.aws_service) == length(distinct(var.aws_service))
    error_message = "All elements of aws_service must be unique."
  }
}

variable "policy_arns_list" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

###########################################################

### KMS ###

variable "kms_key" {
  type        = string
  description = "The KMS key to encrypt data in store."
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}

###########################################################################

variable "ebs_availability_zone" {
  description = "The names of the availability zone"
  type        = string
}

variable "ebs_size" {
  description = "The size of the drive in GiBs"
  type        = string
}

variable "ebs_type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1."
  type        = string
}

variable "ebs_device_name" {
  description = "The device name to expose to the instance."
  type        = string
}


###########################################################################


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

###########################################################################

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

###########################################################################


variable "snstopic_name" {
  description = "name of the SNS topic"
  type        = string
}

variable "snstopic_display_name" {
  description = "The display name of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "Endpoint to send data to. The contents vary with the protocol"
  type        = list(string)
}

variable "protocol" {
  description = "Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application"
  type        = string
}

variable "sns_policy_file_name" {
  description = "Valid JSON document representing a resource policy"
  type        = string
}
