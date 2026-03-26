variable "account_num" {
  description = "Target AWS account number, mandatory"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}


variable "acm_domain_name" {
  description = "The domain name for which the certificate should be issued"
  type        = string

}

variable "internal" {
  description = "If true, the LB will be internal. Defaults to `false`"
  type        = bool
  default     = false
}
####################################### variables of tags ######################################

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

##############variables for nlb###########################################
variable "nlb_name" {
  description = "Name of the nlb on AWS"
  type        = string
}


####################################### variables of security group ######################################
variable "nlb_sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "nlb_sg_description" {
  description = "Security group for example usage with alb"
  type        = string
}

variable "nlb_cidr_ingress_rules" {
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

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}


variable "sg_description" {
  description = "Security group for example usage with EC2"
  type        = string
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

###################################### variables of ec2 ######################################

variable "ec2_name" {
  type        = string
  description = "Name to be used on EC2 instance created"
}

variable "policy" {
  description = "Policy template file in json format "
  type        = string
  default     = "s3_policy.json"
}


variable "ec2_instance_type" {
  type        = string
  description = "type of the ec2 instance"
}

variable "ec2_az" {
  type        = string
  description = "List of availability zone for ec2"
}

variable "bucket_name" {
  description = "Name of the s3 bucket to store alb logs on AWS"
  type        = string
}

#variables for records

variable "account_num_r53" {
  type        = string
  description = "Target route53 AWS account number, mandatory"

}


variable "aws_r53_role" {
  type        = string
  description = "AWS role to assume to work with r53 account_number"

}

#Variables for Kms
variable "kms_name" {
  type        = string
  description = "Unique name"
}

variable "kms_role" {
  description = "AWS role to administer the KMS key."
  type        = string
}

variable "template_file_name" {
  description = "Policy template file in json format "
  type        = string
}

variable "kms_description" {
  type        = string
  description = "The description of the key as viewed in AWS console."
}